import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import '../features/logbook/models/log_model.dart';
import 'package:logbook_app_029/services/mongo_service.dart';
import 'package:logbook_app_029/helpers/log_helper.dart';

class SyncService {
  final Box<LogModel> _myBox = Hive.box<LogModel>('offline_logs');

  void initialize(String teamId) {
    // Perubahan status jaringan di HP (dari Offline menjadi Mobile Data / WiFi). (input)
    // Sistem memantau di latar belakang (background). Jika internet menyala, langsung picu fungsi _syncPendingLogs. (proses)
    // Menjalankan eksekusi upload data yang tertunda secara diam-diam tanpa mengganggu layar pengguna. (output)
    // Memantau perubahan status sinyal HP secara real-time.
    // Membangunkan sistem secara otomatis tepat saat mendeteksi internet menyala kembali (Mobile/WiFi).
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.any(
        (result) =>
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi,
      )) {
        _syncPendingLogs(teamId);
      }
    });
  }

  Future<void> _syncPendingLogs(String teamId) async {
    try {
      final cloudData = await MongoService().getLogs(teamId);
      final cloudIds = cloudData.map((e) => e.id).toSet();

      // 2. Ambil semua data Lokal untuk tim ini
      final localData = _myBox.values
          .where((log) => log.teamId == teamId)
          .toList();

      // Daftar semua ID yang ada di Cloud dan daftar semua catatan di memori lokal (Hive).(input)
      // Mencari catatan lokal yang ID-nya BELUM ADA di dalam daftar ID Cloud. (proses)
      // Kumpulan data murni yang benar-benar baru (pendingLogs) yang siap ditembakkan ke MongoDB. (output)
      // Mengunggah catatan lokal yang belum masuk ke cloud.
      // Mengambil data yang ada di lokal namun ID-nya tidak ditemukan di MongoDB, lalu menyuntikkannya ke cloud diam-diam di background.

      final pendingLogs = localData
          .where((log) => !cloudIds.contains(log.id))
          .toList();

      if (pendingLogs.isEmpty) return;

      await LogHelper.writeLog(
        "SYNC: Jaringan aktif. Menemukan ${pendingLogs.length} data tertunda. Memulai background sync...",
        level: 2,
      );

      // Unggah data yang tertunda satu per satu
      for (var log in pendingLogs) {
        try {
          await MongoService().insertLog(log);
          await LogHelper.writeLog(
            "SYNC: Data '${log.title}' berhasil diunggah.",
            level: 2,
          );
        } catch (e) {
          await LogHelper.writeLog(
            "SYNC: Gagal mengunggah '${log.title}' - $e",
            level: 1,
          );
          continue;
        }
      }
    } catch (e) {
      await LogHelper.writeLog(
        "SYNC ERROR: Gagal terhubung ke Atlas saat background sync.",
        level: 1,
      );
    }
  }
}
