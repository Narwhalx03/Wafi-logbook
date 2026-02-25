import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/log_model.dart';

class LogController {
  final ValueNotifier<List<LogModel>> _allLogs = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogs = ValueNotifier([]);
  static const String _storageKey = 'user_logs_data';

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

  void addLog(String title, String desc, String category) {
    final newLog = LogModel(
      title: title,
      description: desc,
      category: category,
      date: DateTime.now().toString().split('.')[0],
    );
    _allLogs.value = [..._allLogs.value, newLog];
    filterLogs('');
    saveToDisk();
  }

  void removeLog(LogModel log) {
    _allLogs.value = _allLogs.value.where((item) => item != log).toList();
    filterLogs('');
    saveToDisk();
  }

  void updateLog(LogModel oldLog, String title, String desc, String category) {
    final index = _allLogs.value.indexOf(oldLog);
    if (index != -1) {
      _allLogs.value[index] = LogModel(
        title: title,
        description: desc,
        category: category,
        date: DateTime.now().toString().split('.')[0],
      );
      _allLogs.value = List.from(_allLogs.value);
      filterLogs('');
      saveToDisk();
    }
  }

  Future<void> saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      _allLogs.value.map((e) => e.toMap()).toList(),
    );
    await prefs.setString(_storageKey, encodedData);
  }

  Future<void> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data != null) {
      final List decoded = jsonDecode(data);
      _allLogs.value = decoded.map((e) => LogModel.fromMap(e)).toList();
      filteredLogs.value = _allLogs.value;
    }
  }
}
