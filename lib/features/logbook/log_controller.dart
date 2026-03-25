import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;
import 'models/log_model.dart';
import 'package:logbook_app_029/services/mongo_service.dart';
import 'package:logbook_app_029/helpers/log_helper.dart';
import 'package:logbook_app_029/services/access_control_service.dart';

class LogController {
  final Box<LogModel> _myBox = Hive.box<LogModel>('offline_logs');

  final ValueNotifier<List<LogModel>> _allLogs = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogs = ValueNotifier([]);

  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);

  LogController();

  void filterLogs(String query) {
    if (query.isEmpty) {
      filteredLogs.value = _allLogs.value;
      logsNotifier.value = _allLogs.value;
    } else {
      final results = _allLogs.value
          .where(
            (log) =>
                log.title.toLowerCase().contains(query.toLowerCase()) ||
                log.description.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
      filteredLogs.value = results;
      logsNotifier.value = results;
    }
  }

  Future<void> loadLogs(String teamId, String currentUserId) async {
    // Load data lokal dulu agar Offline-First berjalan
    final localData = _myBox.values
        .where((log) => log.teamId == teamId)
        .toList();

    final visibleLogs = localData.where((log) {
      return log.authorId == currentUserId || log.isPublic == true;
    }).toList();

    _allLogs.value = visibleLogs;
    logsNotifier.value = visibleLogs;

    try {
      // ambil data dari Cloud
      final cloudData = await MongoService().getLogs(teamId);

      final cloudIds = cloudData.map((e) => e.id).toSet();

      // Cek satu-satu data lokal, apakah ada yang belum terkirim ke Cloud?
      for (var localLog in localData) {
        if (!cloudIds.contains(localLog.id)) {
          await MongoService().insertLog(localLog);
          cloudData.add(localLog);
          await LogHelper.writeLog(
            "SYNC: Catatan offline '${localLog.title}' berhasil diunggah ke Atlas",
            level: 2,
          );
        }
      }
      await _myBox.clear();
      await _myBox.addAll(cloudData);

      final visibleCloudData = cloudData.where((log) {
        return log.authorId == currentUserId || log.isPublic == true;
      }).toList();

      _allLogs.value = visibleCloudData;
      logsNotifier.value = visibleCloudData;

      await LogHelper.writeLog(
        "SYNC: Data berhasil diperbarui dari Atlas",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "OFFLINE: Menggunakan data cache lokal",
        level: 2,
      );
    }
  }

  // Objek LogModel baru yang dikirim dari UI Editor. (input)
    // 1. Simpan data langsung ke database lokal (Hive) agar UI seketika ter-update. (proses)
    // 2. Mencoba kirim ke Cloud (MongoDB). Jika tidak ada internet (Timeout), tangkap errornya (catch). (proses)
    // Catatan berhasil tampil di layar utama (meski offline), dengan status awan oranye (pending cloud upload). (output)
  Future<void> addLog(
    String title,
    String desc,
    String category,
    String authorId,
    String teamId, {
    bool isPublic = false,
  }) async {
    final newLog = LogModel(
      id: ObjectId().oid,
      title: title,
      description: desc,
      category: category,
      date: DateTime.now().toString(),
      authorId: authorId,
      teamId: teamId,
      isPublic: isPublic,
    );

    // Menyimpan data langsung ke memori lokal HP (Hive).
    // Menjamin data aman (Offline-First) dan UI langsung ter-update meskipun tidak ada internet.
    await _myBox.add(newLog);
    _allLogs.value = [..._allLogs.value, newLog];
    logsNotifier.value = _allLogs.value;

    try {
      await MongoService().insertLog(newLog);
      await LogHelper.writeLog(
        "SUCCESS: Data tersinkron ke Cloud",
        source: "log_controller.dart",
      );
    } catch (e) {
      // Menangkap error jaringan (timeout) saat koneksi terputus.
      // Mencegah aplikasi Crash. Aplikasi hanya diam-diam mencatat di log bahwa data tertunda.
      await LogHelper.writeLog(
        "WARNING: Data tersimpan lokal, akan sinkron saat online",
        level: 1,
      );
    }
  }

  Future<void> removeLog(
    LogModel log, {
    String? userRole,
    String? userId,
  }) async {
    if (log.id == null) return;

    bool isOwner = log.authorId == userId;

    if (!isOwner) {
      await LogHelper.writeLog(
        "SECURITY BREACH: Hanya pemilik yang boleh menghapus!",
        level: 1,
      );
      return;
    }

    try {
      final indexInBox = _myBox.values.toList().indexWhere(
        (item) => item.id == log.id,
      );
      if (indexInBox != -1) await _myBox.deleteAt(indexInBox);

      await MongoService().deleteLog(log.id!);

      _allLogs.value = _allLogs.value
          .where((item) => item.id != log.id)
          .toList();
      logsNotifier.value = _allLogs.value;

      await LogHelper.writeLog(
        "SUCCESS: Data berhasil dihapus dari Cloud",
        source: "log_controller.dart",
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal hapus data - $e",
        level: 1,
        source: "log_controller.dart",
      );
    }
  }

  Future<void> updateLog(
    LogModel oldLog,
    String title,
    String desc,
    String category,
    String userId, {
    bool? isPublic,
  }) async {
    if (oldLog.id == null) return;

    if (oldLog.authorId != userId) {
      await LogHelper.writeLog(
        "SECURITY BREACH: Unauthorized update attempt",
        level: 1,
      );
      return;
    }

    final updatedLog = LogModel(
      id: oldLog.id,
      title: title,
      description: desc,
      category: category,
      date: DateTime.now().toString().split('.')[0],
      authorId: oldLog.authorId,
      teamId: oldLog.teamId,
      isPublic: isPublic ?? oldLog.isPublic,
    );

    try {
      // Update di lokal (Hive)
      final indexInBox = _myBox.values.toList().indexWhere(
        (item) => item.id == oldLog.id,
      );
      if (indexInBox != -1) await _myBox.putAt(indexInBox, updatedLog);

      // Update di Cloud (MongoDB)
      await MongoService().updateLog(updatedLog);

      final index = _allLogs.value.indexWhere((item) => item.id == oldLog.id);
      if (index != -1) {
        _allLogs.value[index] = updatedLog;
        _allLogs.value = List.from(_allLogs.value);
        logsNotifier.value = _allLogs.value;
      }

      await LogHelper.writeLog(
        "SUCCESS: Sinkronisasi Update Berhasil",
        source: "log_controller.dart",
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal update Cloud - $e",
        level: 1,
        source: "log_controller.dart",
      );
    }
  }

  Future<void> loadFromDisk() async {
    _allLogs.value = _myBox.values.toList();
    logsNotifier.value = _allLogs.value;
  }
}
