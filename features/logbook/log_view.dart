import 'package:flutter/material.dart';
import 'models/log_model.dart';
import 'log_controller.dart';
import 'widgets/log_widget.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final LogController _controller = LogController();
  final List<String> categories = ["Pekerjaan", "Pribadi", "Urgent"];
  String selectedCategory = "Pribadi";

  void _showAddLogDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Tambah Catatan Baru"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "Judul"),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: "Deskripsi"),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: "Kategori"),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) =>
                    setDialogState(() => selectedCategory = val!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isNotEmpty) {
                  _controller.addLog(
                    titleCtrl.text,
                    descCtrl.text,
                    selectedCategory,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditLogDialog(LogModel log) {
    final titleCtrl = TextEditingController(text: log.title);
    final descCtrl = TextEditingController(text: log.description);
    String tempCategory = log.category;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Edit Catatan"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "Judul"),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: "Deskripsi"),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: tempCategory,
                decoration: const InputDecoration(labelText: "Kategori"),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setDialogState(() => tempCategory = val!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                _controller.updateLog(
                  log,
                  titleCtrl.text,
                  descCtrl.text,
                  tempCategory,
                );
                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Log View"), elevation: 0),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: _controller.filterLogs,
                decoration: InputDecoration(
                  hintText: "Cari judul catatan...",
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.blueAccent,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable: _controller.filteredLogs,
              builder: (context, logs, _) {
                if (logs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_late_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Belum ada catatan",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];

                    return Dismissible(
                      key: Key(log.date),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        _controller.removeLog(log);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Catatan dihapus"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: LogWidget(
                        log: log,
                        onDelete: () => _controller.removeLog(log),
                        onEdit: () => _showEditLogDialog(log),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLogDialog,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
