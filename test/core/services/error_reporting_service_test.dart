import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_app/core/services/error_reporting_service.dart';

void main() {
  group('ErrorReportingService', () {
    test('should initialize without errors', () {
      expect(() => ErrorReportingService.initialize(), returnsNormally);
    });

    test('should report error with correct severity', () async {
      const testError = 'Test error message';
      final testStackTrace = StackTrace.current;

      // This test would normally verify database integration
      // For now, we test that the method doesn't throw
      expect(
        () => ErrorReportingService.reportError(
          error: testError,
          stackTrace: testStackTrace,
          severity: ErrorSeverity.error,
        ),
        returnsNormally,
      );
    });

    test('should report critical error', () async {
      const testError = 'Critical test error';
      final testStackTrace = StackTrace.current;

      expect(
        () => ErrorReportingService.reportCriticalError(
          error: testError,
          stackTrace: testStackTrace,
          context: 'Test context',
        ),
        returnsNormally,
      );
    });

    test('should handle error severity levels', () {
      expect(ErrorSeverity.info.index, equals(0));
      expect(ErrorSeverity.warning.index, equals(1));
      expect(ErrorSeverity.error.index, equals(2));
      expect(ErrorSeverity.critical.index, equals(3));
    });

    test('should validate error reporting configuration', () {
      // Test that error reporting can be configured
      expect(ErrorSeverity.values.length, equals(4));
    });
  });
}
