import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/supabase_config.dart';
import '../services/logging_service.dart';

class PerformanceMonitor {
  static final Map<String, Stopwatch> _timers = {};
  static final List<PerformanceMetric> _metrics = [];

  static void startTimer(String label) {
    _timers[label] = Stopwatch()..start();
  }

  static void endTimer(String label) {
    final timer = _timers[label];
    if (timer != null) {
      timer.stop();
      final metric = PerformanceMetric(
        label: label,
        duration: timer.elapsedMilliseconds,
        timestamp: DateTime.now(),
      );
      _metrics.add(metric);

      if (kDebugMode) {
        print('⚡ Performance: $label took ${timer.elapsedMilliseconds}ms');
      }

      _timers.remove(label);
    }
  }

  static void trackMemoryUsage(String context) {
    if (kDebugMode) {
      final memory =
          WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
      print(
        '📊 Memory context: $context - Size: ${memory.width}x${memory.height}',
      );
    }
  }

  static List<PerformanceMetric> getMetrics() => List.from(_metrics);

  static void clearMetrics() => _metrics.clear();

  static double getAverageTime(String label) {
    final labelMetrics = _metrics.where((m) => m.label == label);
    if (labelMetrics.isEmpty) return 0;

    final total = labelMetrics.fold<int>(0, (sum, m) => sum + m.duration);
    return total / labelMetrics.length;
  }

  /// Send performance metrics to production monitoring service
  static Future<void> reportToProduction() async {
    if (!AppConfig.enablePerformanceMonitoring || _metrics.isEmpty) {
      return;
    }

    try {
      final metricsData = _metrics
          .map(
            (metric) => {
              'label': metric.label,
              'duration': metric.duration,
              'timestamp': metric.timestamp.toIso8601String(),
              'environment': AppConfig.environment.name,
              'app_version': AppConfig.appVersion,
            },
          )
          .toList();

      final response = await http
          .post(
            Uri.parse('${AppConfig.baseUrl}/rest/v1/performance_metrics'),
            headers: {
              'apikey': AppConfig.anonKey,
              'Authorization': 'Bearer ${AppConfig.anonKey}',
              'Content-Type': 'application/json',
              'Prefer': 'return=minimal',
            },
            body: jsonEncode(metricsData),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        LoggingService.debug(
          'Performance metrics sent to production monitoring',
        );
        _metrics.clear(); // Clear metrics after successful upload
      }
    } catch (e) {
      LoggingService.debug('Failed to send performance metrics: $e');
    }
  }

  /// Track app startup time
  static void trackAppStartup() {
    startTimer('app_startup');
  }

  /// Complete app startup tracking
  static void completeAppStartup() {
    endTimer('app_startup');

    // Report critical startup metrics in production
    if (AppConfig.enablePerformanceMonitoring) {
      final startupMetric = _metrics.lastWhere(
        (m) => m.label == 'app_startup',
        orElse: () => PerformanceMetric(
          label: 'app_startup',
          duration: 0,
          timestamp: DateTime.now(),
        ),
      );

      // Report slow startup times
      if (startupMetric.duration > 3000) {
        // 3 seconds
        LoggingService.warning(
          'Slow app startup detected: ${startupMetric.duration}ms',
        );
      }
    }
  }

  /// Track route navigation performance
  static void trackNavigation(String routeName) {
    startTimer('navigation_$routeName');
  }

  /// Complete route navigation tracking
  static void completeNavigation(String routeName) {
    endTimer('navigation_$routeName');
  }

  /// Track API call performance
  static void trackApiCall(String endpoint) {
    startTimer('api_$endpoint');
  }

  /// Complete API call tracking
  static void completeApiCall(String endpoint) {
    endTimer('api_$endpoint');
  }

  /// Track database operation performance
  static void trackDatabaseOperation(String operation) {
    startTimer('db_$operation');
  }

  /// Complete database operation tracking
  static void completeDatabaseOperation(String operation) {
    endTimer('db_$operation');
  }

  /// Get performance summary for admin dashboard
  static Map<String, dynamic> getPerformanceSummary() {
    if (_metrics.isEmpty) return {};

    final summary = <String, dynamic>{};
    final groupedMetrics = <String, List<PerformanceMetric>>{};

    // Group metrics by label
    for (final metric in _metrics) {
      groupedMetrics.putIfAbsent(metric.label, () => []).add(metric);
    }

    // Calculate statistics for each group
    for (final entry in groupedMetrics.entries) {
      final metrics = entry.value;
      final durations = metrics.map((m) => m.duration).toList();

      durations.sort();

      summary[entry.key] = {
        'count': metrics.length,
        'average': durations.reduce((a, b) => a + b) / durations.length,
        'min': durations.first,
        'max': durations.last,
        'median': durations[durations.length ~/ 2],
        'p95': durations[(durations.length * 0.95).floor()],
      };
    }

    return summary;
  }
}

class PerformanceMetric {
  final String label;
  final int duration; // milliseconds
  final DateTime timestamp;

  PerformanceMetric({
    required this.label,
    required this.duration,
    required this.timestamp,
  });
}

// Performance tracking widget
class PerformanceWrapper extends StatefulWidget {
  final Widget child;
  final String label;

  const PerformanceWrapper({
    super.key,
    required this.child,
    required this.label,
  });

  @override
  State<PerformanceWrapper> createState() => _PerformanceWrapperState();
}

class _PerformanceWrapperState extends State<PerformanceWrapper> {
  @override
  void initState() {
    super.initState();
    PerformanceMonitor.startTimer(widget.label);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    PerformanceMonitor.endTimer(widget.label);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
