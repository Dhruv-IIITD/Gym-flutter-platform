import 'package:flutter/foundation.dart';

class LogEntry {
  final String tag;
  final String message;
  final DateTime timestamp;

  LogEntry(this.tag, this.message) : timestamp = DateTime.now();

  @override
  String toString() => '[$tag] ${timestamp.toIso8601String()} $message';
}

class WtfLogger {
  static final List<LogEntry> _recentLogs = [];
  static const int _maxLogs = 20;

  static List<LogEntry> get recentLogs => List.unmodifiable(_recentLogs);

  static void _log(String tag, String message) {
    final entry = LogEntry(tag, message);
    _recentLogs.add(entry);
    if (_recentLogs.length > _maxLogs) {
      _recentLogs.removeAt(0);
    }
    if (kDebugMode) {
      debugPrint(entry.toString());
    }
  }

  static void chat(String message) => _log('CHAT', message);
  static void rtc(String message) => _log('RTC', message);
  static void schedule(String message) => _log('SCHEDULE', message);
  static void auth(String message) => _log('AUTH', message);
}
