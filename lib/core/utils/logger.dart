import 'package:flutter/foundation.dart';

/// A simple, unified logging utility for the application.
/// Prints logs to the console only when the app is running in [kDebugMode].
class AppLogger {
  AppLogger._();

  /// Logs a debug message (usually for developer diagnostics).
  static void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log('DEBUG', message, tag: tag, error: error, stackTrace: stackTrace, emoji: '🐛');
  }

  /// Logs an informational message.
  static void info(String message, {String? tag}) {
    _log('INFO', message, tag: tag, emoji: 'ℹ️');
  }

  /// Logs a warning message (non-fatal, but potential issue).
  static void warning(String message, {String? tag, Object? error}) {
    _log('WARNING', message, tag: tag, error: error, emoji: '⚠️');
  }

  /// Logs an error message (failure or exception).
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log('ERROR', message, tag: tag, error: error, stackTrace: stackTrace, emoji: '❌');
  }

  static void _log(
    String level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    required String emoji,
  }) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      final time = DateTime.now().toIso8601String().split('T').last.substring(0, 8);
      
      final logMessage = '$emoji [$time] $level $tagStr: $message';
      debugPrint(logMessage);
      
      if (error != null) {
        debugPrint('   └─ Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('   └─ StackTrace: \n$stackTrace');
      }
    }
  }
}
