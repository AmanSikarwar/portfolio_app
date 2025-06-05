import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_app/core/config/supabase_config.dart';

void main() {
  group('AppConfig Environment Variables', () {
    test('should have admin email configuration', () {
      expect(AppConfig.adminEmail, isNotNull);
      expect(AppConfig.adminEmail, isNotEmpty);
    });

    test('should have admin password configuration', () {
      expect(AppConfig.adminPassword, isNotNull);
      expect(AppConfig.adminPassword, isNotEmpty);
    });

    test('should have environment configuration', () {
      expect(AppConfig.environment, isA<Environment>());
    });

    test('should have production mode configuration', () {
      expect(AppConfig.isProduction, isA<bool>());
    });
  });
}
