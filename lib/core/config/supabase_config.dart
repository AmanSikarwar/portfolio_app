import 'package:envied/envied.dart';
import 'package:flutter/foundation.dart';
import '../services/error_handler.dart';
import '../services/logging_service.dart';

part 'supabase_config.g.dart';

enum Environment { development, staging, production }

@Envied(path: '.env')
class SupabaseConfig {
  @EnviedField(varName: 'SUPABASE_URL')
  static const String supabaseUrl = _SupabaseConfig.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static const String supabaseAnonKey = _SupabaseConfig.supabaseAnonKey;

  @EnviedField(varName: 'ADMIN_EMAIL')
  static const String adminEmail = _SupabaseConfig.adminEmail;

  @EnviedField(varName: 'ADMIN_PASSWORD')
  static const String adminPassword = _SupabaseConfig.adminPassword;
}

class AppConfig {
  static Environment get environment {
    if (kReleaseMode) {
      return Environment.production;
    } else if (kProfileMode) {
      return Environment.staging;
    } else {
      return Environment.development;
    }
  }

  static bool get isProduction => environment == Environment.production;
  static bool get isDevelopment => environment == Environment.development;
  static bool get isStaging => environment == Environment.staging;

  // App configuration
  static const String appName = 'Portfolio App';
  static const String appVersion = '1.0.0';

  // API configuration
  static String get baseUrl {
    try {
      return SupabaseConfig.supabaseUrl;
    } catch (e) {
      LoggingService.error(
        'Failed to get Supabase URL from environment',
        error: e,
      );
      throw const ConfigurationException(
        'Supabase URL not configured. Please check your environment variables.',
        code: 'MISSING_SUPABASE_URL',
      );
    }
  }

  static String get anonKey {
    try {
      return SupabaseConfig.supabaseAnonKey;
    } catch (e) {
      LoggingService.error(
        'Failed to get Supabase anon key from environment',
        error: e,
      );
      throw const ConfigurationException(
        'Supabase anonymous key not configured. Please check your environment variables.',
        code: 'MISSING_SUPABASE_KEY',
      );
    }
  }

  // Feature flags
  static bool get enableDebugMode => !isProduction;
  static bool get enableLogging => true;
  static bool get enableErrorReporting => isProduction;
  static bool get enablePerformanceMonitoring => isProduction;

  // Admin credentials configuration
  static String get adminEmail {
    try {
      return SupabaseConfig.adminEmail;
    } catch (e) {
      LoggingService.warning(
        'Failed to get admin email from environment, using fallback',
        error: e,
      );
      return 'admin@amansikarwar.com'; // Fallback for development
    }
  }

  static String get adminPassword {
    try {
      return SupabaseConfig.adminPassword;
    } catch (e) {
      LoggingService.warning(
        'Failed to get admin password from environment, using fallback',
        error: e,
      );
      return 'admin123'; // Fallback for development - change in production!
    }
  }

  // Timeout configurations
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration databaseTimeout = Duration(seconds: 15);

  // Validation
  static void validateConfiguration() {
    try {
      // Ensure required configuration is available
      baseUrl; // Check if accessible
      anonKey; // Check if accessible

      LoggingService.info('App configuration validated successfully');
      LoggingService.info('Environment: ${environment.name}');
      LoggingService.info('App version: $appVersion');
    } catch (e) {
      LoggingService.fatal('Configuration validation failed', error: e);
      rethrow;
    }
  }
}
