import 'package:flutter/foundation.dart';

enum LogLevel { info, warn, error }

class LogEntry {
  final DateTime time;
  final LogLevel level;
  final String message;
  final Object? error;
  final StackTrace? stack;

  LogEntry({
    required this.time,
    required this.level,
    required this.message,
    this.error,
    this.stack,
  });

  String format() {
    final t = time.toIso8601String().substring(11, 23);
    final tag = level.name.toUpperCase().padRight(5);
    final base = '$t $tag $message';
    if (error == null) return base;
    return '$base\n  -> $error';
  }

  String formatFull() {
    final base = format();
    if (stack == null) return base;
    return '$base\n$stack';
  }
}

class AppLogger {
  AppLogger._();
  static final AppLogger instance = AppLogger._();

  static const _maxEntries = 500;

  final ValueNotifier<List<LogEntry>> entries =
      ValueNotifier<List<LogEntry>>(<LogEntry>[]);

  void info(String message) => _add(LogLevel.info, message);

  void warn(String message, [Object? error, StackTrace? stack]) =>
      _add(LogLevel.warn, message, error, stack);

  void error(String message, [Object? error, StackTrace? stack]) =>
      _add(LogLevel.error, message, error, stack);

  void _add(LogLevel level, String message, [Object? error, StackTrace? stack]) {
    final entry = LogEntry(
      time: DateTime.now(),
      level: level,
      message: message,
      error: error,
      stack: stack,
    );
    final next = List<LogEntry>.from(entries.value)..add(entry);
    if (next.length > _maxEntries) {
      next.removeRange(0, next.length - _maxEntries);
    }
    entries.value = next;
    debugPrint(entry.format());
    if (stack != null && level == LogLevel.error) {
      debugPrint(stack.toString());
    }
  }

  void clear() {
    entries.value = <LogEntry>[];
  }
}
