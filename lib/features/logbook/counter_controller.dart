import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int counter = 0;
  int step = 1;
  List<String> history = [];

  final TextEditingController stepController = TextEditingController();

  Future<void> loadData(String username) async {
    final prefs = await SharedPreferences.getInstance();

    counter = prefs.getInt('counter_$username') ?? 0;
    history = prefs.getStringList('history_$username') ?? [];

    // Set default step ke 1 di UI
    stepController.text = "1";
    step = 1;
  }

  // Simpan data ke memori HP
  Future<void> _save(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter_$username', counter);
    await prefs.setStringList('history_$username', history);
  }

  void setStep(String value) {
    step = int.tryParse(value) ?? 1;
  }

  void increment(String username) {
    counter += step;
    _addLog("+ Tambah $step", username);
  }

  void decrement(String username) {
    counter -= step;
    _addLog("- Kurang $step", username);
  }

  void reset(String username) {
    counter = 0;
    step = 1;
    stepController.text = "1";
    history.clear();
    _save(username);
  }

  void _addLog(String action, String username) {
    String time = DateTime.now().toString().substring(11, 16);
    history.insert(0, "$action pada jam $time");

    if (history.length > 5) {
      history.removeLast();
    }

    _save(username);
  }

  void dispose() {
    stepController.dispose();
  }
}
