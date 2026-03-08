import 'package:flutter/material.dart';
import 'models/log_model.dart';
import 'package:logbook_app_029/services/mongo_service.dart';
import 'package:logbook_app_029/helpers/log_helper.dart';

class LogController {
  final ValueNotifier<List<LogModel>> _allLogs = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogs = ValueNotifier([]);

  LogController() {
    loadFromDisk();
  }

  void filterLogs(String query) {
    if (query.isEmpty) {
      filteredLogs.value = _allLogs.value;
    } else {
      filteredLogs.value = _allLogs.value
          .where((log) => log.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  Future<void> addLog(String title, String desc, String category) async {
    final newLog = LogModel(
      title: title,
      description: desc,
      category: category,
      date: DateTime.now().toString().split('.')[0],
    );

    try {
      await MongoService().insertLog(newLog);

      _allLogs.value = [..._allLogs.value, newLog];
      filterLogs('');

      await LogHelper.writeLog(
        "SUCCESS: Data '${newLog.title}' tersimpan di Cloud",
        source: "log_controller.dart",
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal tambah data ke Cloud - $e",
        level: 1,
        source: "log_controller.dart",
      );
    }
  }

  Future<void> removeLog(LogModel log) async {
    if (log.id == null) return;

    try {
      await MongoService().deleteLog(log.id!);
      _allLogs.value = _allLogs.value
          .where((item) => item.id != log.id)
          .toList();
      filterLogs('');

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
  ) async {
    if (oldLog.id == null) return;

    final updatedLog = LogModel(
      id: oldLog.id,
      title: title,
      description: desc,
      category: category,
      date: DateTime.now().toString().split('.')[0],
    );

    try {
      await MongoService().updateLog(updatedLog);

      final index = _allLogs.value.indexWhere((item) => item.id == oldLog.id);
      if (index != -1) {
        _allLogs.value[index] = updatedLog;
        _allLogs.value = List.from(_allLogs.value);
        filterLogs('');
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
    try {
      final cloudData = await MongoService().getLogs();
      _allLogs.value = cloudData;
      filteredLogs.value = cloudData;

      await LogHelper.writeLog(
        "SUCCESS: Data berhasil dimuat dari MongoDB Atlas",
        source: "log_controller.dart",
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal mengambil data Cloud - $e",
        level: 1,
        source: "log_controller.dart",
      );
    }
  }
}
