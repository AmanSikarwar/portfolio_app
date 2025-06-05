import 'package:flutter/foundation.dart';
import 'logging_service.dart';
import 'error_reporting_service.dart';

// Custom exception classes for better error categorization
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final Object? originalError;
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class AuthenticationException extends AppException {
  const AuthenticationException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class DatabaseException extends AppException {
  const DatabaseException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

class ConfigurationException extends AppException {
  const ConfigurationException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

// Error handling utilities
class ErrorHandler {
  static void handleError(
    Object error, {
    StackTrace? stackTrace,
    String? context,
    bool shouldRethrow = false,
  }) {
    final errorContext = context ?? 'Unknown context';

    if (error is AppException) {
      LoggingService.error(
        'App error in $errorContext: ${error.message}',
        error: error.originalError ?? error,
        stackTrace: stackTrace ?? error.stackTrace,
      );
    } else {
      LoggingService.error(
        'Unexpected error in $errorContext: $error',
        error: error,
        stackTrace: stackTrace,
      );
    }

    // In production, report to monitoring service
    if (kReleaseMode) {
      _reportErrorToMonitoring(error, stackTrace, errorContext);
    }

    if (shouldRethrow) {
      throw error;
    }
  }

  static void _reportErrorToMonitoring(
    Object error,
    StackTrace? stackTrace,
    String context,
  ) {
    // Report to error reporting service in production
    try {
      // Import the service dynamically to avoid circular dependencies
      ErrorReportingService.reportError(
        error: error,
        stackTrace: stackTrace,
        context: context,
        severity:
            error is AppException && error.code?.contains('CRITICAL') == true
            ? ErrorSeverity.critical
            : ErrorSeverity.error,
      );
    } catch (e) {
      LoggingService.debug('Failed to report error to monitoring service: $e');
    }
  }

  static String getErrorMessage(Object error) {
    if (error is AppException) {
      return error.message;
    } else if (error is Exception) {
      return error.toString();
    } else {
      return 'An unexpected error occurred';
    }
  }

  static String getUserFriendlyMessage(Object error) {
    if (error is NetworkException) {
      return 'Network connection error. Please check your internet connection and try again.';
    } else if (error is AuthenticationException) {
      return 'Authentication failed. Please log in again.';
    } else if (error is ValidationException) {
      return error.message; // Validation messages are usually user-friendly
    } else if (error is DatabaseException) {
      return 'Data operation failed. Please try again later.';
    } else if (error is ConfigurationException) {
      return 'Application configuration error. Please contact support.';
    } else {
      return 'An unexpected error occurred. Please try again later.';
    }
  }
}

// Result wrapper for better error handling
class Result<T> {
  final T? data;
  final AppException? error;
  final bool isSuccess;

  const Result._({this.data, this.error, required this.isSuccess});

  factory Result.success(T data) => Result._(data: data, isSuccess: true);
  factory Result.failure(AppException error) =>
      Result._(error: error, isSuccess: false);

  bool get isFailure => !isSuccess;

  T get value {
    if (isSuccess && data != null) {
      return data!;
    }
    throw StateError('Tried to access value of failed result');
  }
}

// Extension for Future error handling
extension FutureErrorHandling<T> on Future<T> {
  Future<Result<T>> toResult() async {
    try {
      final result = await this;
      return Result.success(result);
    } catch (error, stackTrace) {
      if (error is AppException) {
        return Result.failure(error);
      } else {
        // Convert unknown errors to generic NetworkException
        return Result.failure(
          NetworkException(
            'Unexpected error: $error',
            originalError: error,
            stackTrace: stackTrace,
          ),
        );
      }
    }
  }
}
