import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_app/core/utils/performance_monitor.dart';

void main() {
  group('PerformanceMonitor', () {
    test('should track app startup', () {
      expect(() => PerformanceMonitor.trackAppStartup(), returnsNormally);
      expect(() => PerformanceMonitor.completeAppStartup(), returnsNormally);
    });

    test('should track navigation', () {
      expect(
        () => PerformanceMonitor.trackNavigation('/home'),
        returnsNormally,
      );
    });

    test('should track API calls', () {
      expect(() => PerformanceMonitor.trackApiCall('GET'), returnsNormally);
    });

    test('should track database operations', () {
      expect(
        () => PerformanceMonitor.trackDatabaseOperation('SELECT'),
        returnsNormally,
      );
    });

    test('should generate performance summaries', () async {
      // This test would normally verify database integration
      // For now, we test that the method doesn't throw
      expect(() => PerformanceMonitor.getPerformanceSummary(), returnsNormally);
    });
  });
}
