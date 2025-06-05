import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/supabase_config.dart';
import 'logging_service.dart';

class AnalyticsService {
  static const String _tableName = 'portfolio_analytics';

  // Track page visits
  static Future<void> trackPageView({
    required String page,
    String? userAgent,
    String? referrer,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${SupabaseConfig.supabaseUrl}/rest/v1/$_tableName'),
        headers: {
          'apikey': SupabaseConfig.supabaseAnonKey,
          'Authorization': 'Bearer ${SupabaseConfig.supabaseAnonKey}',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
        body: jsonEncode({
          'page': page,
          'user_agent': userAgent,
          'referrer': referrer,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode != 201) {
        LoggingService.warning('Failed to track analytics: ${response.body}');
      }
    } catch (e) {
      LoggingService.error('Analytics tracking error', error: e);
    }
  }

  // Track button clicks
  static Future<void> trackEvent({
    required String eventName,
    String? category,
    Map<String, dynamic>? properties,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${SupabaseConfig.supabaseUrl}/rest/v1/portfolio_events'),
        headers: {
          'apikey': SupabaseConfig.supabaseAnonKey,
          'Authorization': 'Bearer ${SupabaseConfig.supabaseAnonKey}',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
        body: jsonEncode({
          'event_name': eventName,
          'category': category,
          'properties': properties,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode != 201) {
        LoggingService.warning('Failed to track event: ${response.body}');
      }
    } catch (e) {
      LoggingService.error('Event tracking error', error: e);
    }
  }

  // Get analytics summary
  static Future<Map<String, dynamic>> getAnalyticsSummary() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${SupabaseConfig.supabaseUrl}/rest/v1/rpc/get_analytics_summary',
        ),
        headers: {
          'apikey': SupabaseConfig.supabaseAnonKey,
          'Authorization': 'Bearer ${SupabaseConfig.supabaseAnonKey}',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      LoggingService.error('Analytics summary error', error: e);
    }
    return {};
  }
}

// Analytics tracking widget
class AnalyticsTracker extends StatefulWidget {
  final Widget child;
  final String pageName;

  const AnalyticsTracker({
    super.key,
    required this.child,
    required this.pageName,
  });

  @override
  State<AnalyticsTracker> createState() => _AnalyticsTrackerState();
}

class _AnalyticsTrackerState extends State<AnalyticsTracker> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService.trackPageView(page: widget.pageName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
