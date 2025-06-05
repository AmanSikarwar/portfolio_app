import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/portfolio_data_provider.dart';
import 'core/services/auth_service.dart';
import 'core/services/logging_service.dart';
import 'core/services/error_handler.dart';
import 'core/services/error_reporting_service.dart';
import 'core/config/app_router.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/performance_monitor.dart';
import 'presentation/providers/scroll_provider.dart';
import 'presentation/widgets/session_manager.dart';
import 'data/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start performance monitoring for app startup
  PerformanceMonitor.trackAppStartup();

  // Initialize logging service first
  LoggingService.info('Starting Portfolio App');

  // Set up global error handling for production
  ErrorReportingService.setupGlobalErrorHandling();

  try {
    // Initialize error reporting service
    await ErrorReportingService.initialize();
    LoggingService.info('Error reporting service initialized');

    // Validate configuration
    AppConfig.validateConfiguration();

    // Initialize Supabase
    await SupabaseService.initialize();
    LoggingService.info('Supabase initialized successfully');
  } catch (e, stackTrace) {
    final error = ConfigurationException(
      'Failed to initialize application',
      originalError: e,
      stackTrace: stackTrace,
    );

    LoggingService.fatal(
      'Application initialization failed',
      error: error,
      stackTrace: stackTrace,
    );

    // Report critical error to monitoring service
    ErrorReportingService.reportCriticalError(
      error: error,
      stackTrace: stackTrace,
      context: 'Application initialization',
    );

    // In production, show error screen instead of crashing
    runApp(ErrorApp(error: error));
    return;
  }

  try {
    // Initialize AuthService
    final authService = AuthService();
    authService.initialize();
    LoggingService.info('AuthService initialized successfully');

    // Initialize portfolio data provider
    final portfolioProvider = PortfolioDataProvider();

    // Complete app startup tracking
    PerformanceMonitor.completeAppStartup();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ScrollProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider.value(value: portfolioProvider),
          ChangeNotifierProvider.value(value: authService),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    final error = NetworkException(
      'Failed to initialize services',
      originalError: e,
      stackTrace: stackTrace,
    );

    LoggingService.fatal(
      'Service initialization failed',
      error: error,
      stackTrace: stackTrace,
    );

    // Report critical error to monitoring service
    ErrorReportingService.reportCriticalError(
      error: error,
      stackTrace: stackTrace,
      context: 'Service initialization',
    );

    runApp(ErrorApp(error: error));
  }
}

// Error app widget for production error handling
class ErrorApp extends StatelessWidget {
  final AppException error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portfolio App - Error',
      theme: AppTheme.darkTheme,
      home: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                const SizedBox(height: 24),
                Text(
                  'Application Error',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[400],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sorry, the application failed to start properly.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[300]),
                  textAlign: TextAlign.center,
                ),
                if (!AppConfig.isProduction) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${error.message}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // In a real app, you might want to restart or navigate to a safe screen
                    LoggingService.info('User requested app restart');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Restart App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    LoggingService.info('Building main application widget');

    return SessionManager(
      child: MaterialApp.router(
        title: 'Aman Sikarwar - Portfolio',
        themeMode: ThemeMode.dark,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: AppConfig.enableDebugMode,
        builder: (context, child) {
          // Global error handling wrapper
          ErrorWidget.builder = (FlutterErrorDetails details) {
            LoggingService.error(
              'Flutter error caught by ErrorWidget',
              error: details.exception,
              stackTrace: details.stack,
            );

            if (AppConfig.isProduction) {
              return Container(
                color: Colors.grey[900],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[400],
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Something went wrong',
                        style: TextStyle(color: Colors.grey[300], fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              // Development mode - show detailed error
              return ErrorWidget(details.exception);
            }
          };

          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }
}
