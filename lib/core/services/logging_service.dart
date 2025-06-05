import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error, fatal }

class LoggingService {
  static const String _tag = 'PortfolioApp';

  static void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.debug,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void info(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.info,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.warning,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void fatal(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.fatal,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final logTag = tag ?? _tag;
    final timestamp = DateTime.now().toIso8601String();

    // In production, only log warnings and above
    if (kReleaseMode && level.index < LogLevel.warning.index) {
      return;
    }

    String logMessage =
        '[$timestamp] [${level.name.toUpperCase()}] [$logTag] $message';

    if (error != null) {
      logMessage += '\nError: $error';
    }

    if (stackTrace != null) {
      logMessage += '\nStackTrace: $stackTrace';
    }

    // Use developer.log for better integration with Flutter DevTools
    developer.log(
      message,
      name: logTag,
      time: DateTime.now(),
      level: _getLevelValue(level),
      error: error,
      stackTrace: stackTrace,
    );

    // In production, you might want to send critical errors to a monitoring service
    if (kReleaseMode && level.index >= LogLevel.error.index) {
      _reportToMonitoring(logMessage, level, error, stackTrace);
    }
  }

  static int _getLevelValue(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.fatal:
        return 1200;
    }
  }

  static void _reportToMonitoring(
    String message,
    LogLevel level,
    Object? error,
    StackTrace? stackTrace,
  ) {
    // TODO: Implement integration with monitoring service (Firebase Crashlytics, Sentry, etc.)
    // For now, we'll just ensure it's logged to the console in production
    if (kReleaseMode) {
      debugPrint('PRODUCTION_LOG: $message');
    }
  }
}
