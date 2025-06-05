import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
