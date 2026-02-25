import 'package:flutter/material.dart';
import '../models/log_model.dart';

class LogWidget extends StatelessWidget {
  final LogModel log;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const LogWidget({
    super.key,
    required this.log,
    required this.onDelete,
    required this.onEdit,
  });

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Urgent":
        return Colors.red.shade100;
      case "Pekerjaan":
        return Colors.blue.shade100;
      default:
        return Colors.green.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getCategoryColor(log.category),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.note),
        title: Text(
          log.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${log.description}\n${log.date} • ${log.category}"),
        isThreeLine: true,
        trailing: Wrap(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
