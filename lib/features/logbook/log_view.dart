import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/log_model.dart';
import 'log_controller.dart';
import 'widgets/log_widget.dart';
import 'package:logbook_app_029/services/mongo_service.dart';
import 'package:logbook_app_029/helpers/log_helper.dart';
import 'package:logbook_app_029/features/logbook/log_editor_page.dart';
import 'package:lottie/lottie.dart';
import 'package:logbook_app_029/services/sync_service.dart';
import 'package:logbook_app_029/features/auth/login_view.dart';

class LogPage extends StatefulWidget {
  final dynamic currentUser;
  const LogPage({super.key, this.currentUser});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final LogController _controller = LogController();
  final List<String> categories = ["Pekerjaan", "Pribadi", "Urgent"];
  String selectedCategory = "Pribadi";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _initDatabase();
      final teamId = widget.currentUser?['teamId'] ?? 'no_team';
      SyncService().initialize(teamId);
    });
  }

  Future<void> _initDatabase() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await LogHelper.writeLog(
        "UI: Memulai inisialisasi database...",
        source: "log_view.dart",
      );

      await MongoService().connect().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception("Koneksi Cloud Timeout."),
      );

      final teamId = widget.currentUser?['teamId'] ?? 'no_team';
      final userId = widget.currentUser?['uid'] ?? 'unknown_user';

      await _controller.loadLogs(teamId, userId);

      await LogHelper.writeLog(
        "UI: Koneksi MongoService BERHASIL.",
        source: "log_view.dart",
      );
    } catch (e) {
      await LogHelper.writeLog(
        "UI: Error - $e",
        source: "log_view.dart",
        level: 1,
      );
      await _controller.loadFromDisk();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToEditor({LogModel? log, int? index}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogEditorPage(
          log: log,
          index: index,
          controller: _controller,
          currentUser: widget.currentUser,
        ),
      ),
    ).then((_) => _initDatabase());
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logbook: ${widget.currentUser?['username'] ?? 'User'}"),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _initDatabase),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text(
                    "Apakah Anda yakin ingin keluar dari akun ini?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Batal",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      child: const Text(
                        "Keluar",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _controller.filterLogs,
              decoration: InputDecoration(
                hintText: "Cari judul catatan...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable: _controller.logsNotifier,
              builder: (context, logs, _) {
                if (_isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (logs.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/lottie/Searching.json',
                            width: 250,
                            height: 250,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Belum ada catatan aktivitas.",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Mulai catat kemajuan proyek Anda sekarang!",
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => _goToEditor(),
                            icon: const Icon(Icons.add),
                            label: const Text("Buat Catatan Pertama"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _initDatabase,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];

                      // ID pembuat catatan (log.authorId) vs ID pengguna yang sedang login (currentUser['uid']). (input)
                      // Membandingkan kedua ID. Jika sama, isOwner = true (punya hak akses penuh). Jika beda, isOwner = false. (proses)
                      // Nilai boolean yang akan menentukan apakah tombol Edit/Hapus & fitur Swipe akan dimunculkan di UI atau dikunci. (output)
                      // Sebagai kunci utama Kedaulatan Data (Sovereignty). Jika false, user ini tidak punya hak akses edit/hapus.
                      final bool isOwner =
                          log.authorId == widget.currentUser?['uid'];

                      return Dismissible(
                        key: Key(log.id ?? log.date),
                        // Mematikan fitur geser sepenuhnya (DismissDirection.none) jika user bukan pemilik catatan.
                        direction: isOwner
                            ? DismissDirection.endToStart
                            : DismissDirection.none,
                        background: Container(
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete_sweep,
                                color: Colors.white,
                                size: 28,
                              ),
                              Text(
                                "Hapus",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onDismissed: (_) => _controller.removeLog(
                          log,
                          userId: widget.currentUser?['uid'],
                        ),
                        // Mengirim nilai `null` jika bukan pemilik, sehingga tombol otomatis disembunyikan dari UI.
                        child: LogWidget(
                          log: log,
                          onDelete: isOwner
                              ? () => _controller.removeLog(
                                  log,
                                  userId: widget.currentUser?['uid'],
                                )
                              : null,
                          onEdit: isOwner
                              ? () => _goToEditor(log: log, index: index)
                              : null,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToEditor(),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
