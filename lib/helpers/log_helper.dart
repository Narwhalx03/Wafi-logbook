import 'dart:developer' as dev;
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LogHelper {
  static Future<void> writeLog(
    String message, {
    String source = "Unknown",
    int level = 2,
  }) async {
    final int configLevel = int.tryParse(dotenv.env['LOG_LEVEL'] ?? '2') ?? 2;
    final List<String> muteList = (dotenv.env['LOG_MUTE'] ?? '').split(',');

    if (level > configLevel || muteList.contains(source)) return;

    try {
      final String timestamp = DateFormat('HH:mm:ss').format(DateTime.now());
      final String label = _getLabel(level);
      final String color = _getColor(level);
      final String resetColor = '\x1B[0m';

      dev.log(message, name: source, time: DateTime.now(), level: level * 100);

      print('$color[$timestamp][$label][$source] -> $message$resetColor');
    } catch (e) {
      dev.log("Logging failed: $e", name: "SYSTEM", level: 1000);
    }
  }

  static String _getLabel(int level) {
    switch (level) {
      case 1:
        return "ERROR";
      case 2:
        return "INFO";
      case 3:
        return "VERBOSE";
      default:
        return "LOG";
    }
  }

  static String _getColor(int level) {
    switch (level) {
      case 1:
        return '\x1B[31m';
      case 2:
        return '\x1B[32m';
      case 3:
        return '\x1B[34m';
      default:
        return '\x1B[0m';
    }
  }
}
