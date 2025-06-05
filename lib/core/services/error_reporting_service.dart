import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/supabase_config.dart';
import 'logging_service.dart';

/// Production error reporting service for monitoring and tracking errors
class ErrorReportingService {
  static const String _tableName = 'error_reports';
  static bool _isInitialized = false;

  /// Initialize the error reporting service
  static Future<void> initialize() async {
    if (!AppConfig.enableErrorReporting) {
      LoggingService.debug(
        'Error reporting disabled - skipping initialization',
      );
      return;
    }

    try {
      _isInitialized = true;
      LoggingService.info('Error reporting service initialized');
    } catch (e) {
      LoggingService.error(
        'Failed to initialize error reporting service',
        error: e,
      );
    }
  }

  /// Report an error to the remote monitoring service
  static Future<void> reportError({
    required dynamic error,
    StackTrace? stackTrace,
    String? context,
    String? userId,
    Map<String, dynamic>? customData,
    ErrorSeverity severity = ErrorSeverity.error,
  }) async {
    // Don't report errors if not in production or not initialized
    if (!AppConfig.enableErrorReporting || !_isInitialized) {
      return;
    }

    try {
      final errorData = {
        'error_message': error.toString(),
        'error_type': error.runtimeType.toString(),
        'stack_trace': stackTrace?.toString(),
        'context': context,
        'user_id': userId,
        'severity': severity.name,
        'environment': AppConfig.environment.name,
        'app_version': AppConfig.appVersion,
        'platform': defaultTargetPlatform.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'custom_data': customData != null ? jsonEncode(customData) : null,
      };

      final response = await http
          .post(
            Uri.parse('${AppConfig.baseUrl}/rest/v1/$_tableName'),
            headers: {
              'apikey': AppConfig.anonKey,
              'Authorization': 'Bearer ${AppConfig.anonKey}',
              'Content-Type': 'application/json',
              'Prefer': 'return=minimal',
            },
            body: jsonEncode(errorData),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        LoggingService.debug('Error report sent successfully');
      } else {
        LoggingService.warning(
          'Failed to send error report: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Don't create infinite loops by reporting error reporting errors
      LoggingService.debug('Error reporting failed: $e');
    }
  }

  /// Report a critical error that needs immediate attention
  static Future<void> reportCriticalError({
    required dynamic error,
    StackTrace? stackTrace,
    String? context,
    String? userId,
    Map<String, dynamic>? customData,
  }) async {
    await reportError(
      error: error,
      stackTrace: stackTrace,
      context: context,
      userId: userId,
      customData: customData,
      severity: ErrorSeverity.critical,
    );
  }

  /// Report a warning that should be monitored
  static Future<void> reportWarning({
    required String message,
    String? context,
    String? userId,
    Map<String, dynamic>? customData,
  }) async {
    await reportError(
      error: message,
      context: context,
      userId: userId,
      customData: customData,
      severity: ErrorSeverity.warning,
    );
  }

  /// Report an info-level event for monitoring
  static Future<void> reportInfo({
    required String message,
    String? context,
    String? userId,
    Map<String, dynamic>? customData,
  }) async {
    await reportError(
      error: message,
      context: context,
      userId: userId,
      customData: customData,
      severity: ErrorSeverity.info,
    );
  }

  /// Get error statistics for admin dashboard
  static Future<Map<String, dynamic>> getErrorStatistics() async {
    if (!AppConfig.enableErrorReporting) {
      return {};
    }

    try {
      final response = await http
          .get(
            Uri.parse('${AppConfig.baseUrl}/rest/v1/rpc/get_error_statistics'),
            headers: {
              'apikey': AppConfig.anonKey,
              'Authorization': 'Bearer ${AppConfig.anonKey}',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      LoggingService.debug('Failed to fetch error statistics: $e');
    }
    return {};
  }

  /// Get recent errors for debugging
  static Future<List<Map<String, dynamic>>> getRecentErrors({
    int limit = 50,
    ErrorSeverity? severityFilter,
  }) async {
    if (!AppConfig.enableErrorReporting) {
      return [];
    }

    try {
      String query = '$_tableName?select=*&order=timestamp.desc&limit=$limit';
      if (severityFilter != null) {
        query += '&severity=eq.${severityFilter.name}';
      }

      final response = await http
          .get(
            Uri.parse('${AppConfig.baseUrl}/rest/v1/$query'),
            headers: {
              'apikey': AppConfig.anonKey,
              'Authorization': 'Bearer ${AppConfig.anonKey}',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
    } catch (e) {
      LoggingService.debug('Failed to fetch recent errors: $e');
    }
    return [];
  }

  /// Set up global error handling for unhandled exceptions
  static void setupGlobalErrorHandling() {
    if (!AppConfig.enableErrorReporting) {
      return;
    }

    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      reportCriticalError(
        error: details.exception,
        stackTrace: details.stack,
        context: 'Flutter Framework Error',
        customData: {
          'library': details.library,
          'context': details.context?.toString(),
        },
      );

      // In debug mode, also use the default error handler
      if (kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      }
    };

    // Handle platform errors (iOS/Android)
    PlatformDispatcher.instance.onError = (error, stack) {
      reportCriticalError(
        error: error,
        stackTrace: stack,
        context: 'Platform Error',
      );
      return true;
    };

    LoggingService.info('Global error handling configured for production');
  }
}

/// Error severity levels for categorizing errors
enum ErrorSeverity { info, warning, error, critical }

/// Extension to add error reporting to existing error types
extension ErrorReporting on Object {
  /// Report this error to the error reporting service
  Future<void> report({
    StackTrace? stackTrace,
    String? context,
    String? userId,
    Map<String, dynamic>? customData,
    ErrorSeverity severity = ErrorSeverity.error,
  }) async {
    await ErrorReportingService.reportError(
      error: this,
      stackTrace: stackTrace,
      context: context,
      userId: userId,
      customData: customData,
      severity: severity,
    );
  }
}
