import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'models/log_model.dart';
import 'log_controller.dart';

class LogEditorPage extends StatefulWidget {
  final LogModel? log;
  final int? index;
  final LogController controller;
  final dynamic currentUser;

  const LogEditorPage({
    super.key,
    this.log,
    this.index,
    required this.controller,
    required this.currentUser,
  });

  @override
  State<LogEditorPage> createState() => _LogEditorPageState();
}

class _LogEditorPageState extends State<LogEditorPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String _selectedCategory = "Software";
  final List<String> _categories = ["Mechanical", "Electronic", "Software"];

  bool _isPublic = false;

  @override
  void initState() {
    super.initState();
    if (widget.log != null) {
      _titleController.text = widget.log!.title;
      _descController.text = widget.log!.description;
      _isPublic = widget.log!.isPublic;

      if (_categories.contains(widget.log!.category)) {
        _selectedCategory = widget.log!.category;
      }
    }
  }
  // Teks Judul, Kategori (Dropdown), dan Deskripsi (Markdown) dari pengguna. (input)
  // Memvalidasi apakah ini data baru atau update. Jika baru, kirim data mentah ke LogController untuk diubah menjadi LogModel. (proses)
  // Data terkirim ke Controller, lalu menutup layar editor (Navigator.pop) untuk kembali ke Dashboard. (output)
  // Kegunaannya Mengambil teks dari form dan memanggil controller untuk dikirim ke MongoDB saat online.
  void _saveLog() {
    final authorId = widget.currentUser?['uid'] ?? 'unknown';
    final teamId = widget.currentUser?['teamId'] ?? 'no_team';

    if (widget.log == null) {
      widget.controller.addLog(
        _titleController.text,
        _descController.text,
        _selectedCategory,
        authorId,
        teamId,
        isPublic: _isPublic,
      );
    } else {
      widget.controller.updateLog(
        widget.log!,
        _titleController.text,
        _descController.text,
        _selectedCategory,
        authorId,
        isPublic: _isPublic,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Editor Catatan"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Edit"),
              Tab(text: "Preview"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: "Judul"),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(labelText: "Kategori"),
                    items: _categories.map((String category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        if (newValue != null) _selectedCategory = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: "Deskripsi (Bisa pakai Markdown)",
                    ),
                    onChanged: (text) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text("Catatan Publik?"),
                    subtitle: const Text(
                      "Anggota tim bisa melihat jika ini diaktifkan.",
                    ),
                    value: _isPublic,
                    onChanged: (val) => setState(() => _isPublic = val),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveLog,
                    child: const Text("Simpan"),
                  ),
                ],
              ),
            ),
 
            // Teks mentah berisi simbol (misal: **teks**, # Judul) dari TextEditingController. (input)
            // Package flutter_markdown menerjemahkan simbol tersebut menjadi gaya visual (tebal/miring). (proses)
            // Tampilan teks yang sudah diformat rapi di layar Preview. (output)
            Padding(
              padding: const EdgeInsets.all(16.0),
              // agar teks bisa dibaca dengan gaya (bold, italic, heading) di tab Preview.
              child: MarkdownBody(
                data: _descController.text.isEmpty
                    ? "*Belum ada deskripsi*"
                    : _descController.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
