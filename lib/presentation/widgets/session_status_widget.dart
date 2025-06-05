import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';

class SessionStatusWidget extends StatefulWidget {
  const SessionStatusWidget({super.key});

  @override
  State<SessionStatusWidget> createState() => _SessionStatusWidgetState();
}

class _SessionStatusWidgetState extends State<SessionStatusWidget> {
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _startUpdateTimer();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startUpdateTimer() {
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      return '${hours}h ${minutes}m';
    } else {
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      return '${minutes}m ${seconds}s';
    }
  }

  Color _getStatusColor(Duration? timeLeft) {
    if (timeLeft == null) return Colors.grey;

    if (timeLeft.inMinutes <= 10) {
      return Colors.red;
    } else if (timeLeft.inMinutes <= 30) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  IconData _getStatusIcon(Duration? timeLeft) {
    if (timeLeft == null) return Icons.timer_off;

    if (timeLeft.inMinutes <= 10) {
      return Icons.warning;
    } else if (timeLeft.inMinutes <= 30) {
      return Icons.schedule;
    } else {
      return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (!authService.isAuthenticated) {
          return const SizedBox.shrink();
        }

        final timeLeft = authService.timeUntilTimeout;
        final statusColor = _getStatusColor(timeLeft);
        final statusIcon = _getStatusIcon(timeLeft);

        return Tooltip(
          message: timeLeft != null
              ? 'Session expires in ${_formatDuration(timeLeft)}'
              : 'Session status unknown',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: 6),
                Text(
                  timeLeft != null ? _formatDuration(timeLeft) : 'Unknown',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SessionActionsWidget extends StatelessWidget {
  const SessionActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (!authService.isAuthenticated) {
          return const SizedBox.shrink();
        }

        return PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white70, size: 20),
          tooltip: 'Session Actions',
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'refresh',
              child: Row(
                children: [
                  const Icon(Icons.refresh, size: 18),
                  const SizedBox(width: 8),
                  const Text('Refresh Session'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'extend',
              child: Row(
                children: [
                  const Icon(Icons.schedule, size: 18),
                  const SizedBox(width: 8),
                  const Text('Extend Session'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'info',
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 18),
                  const SizedBox(width: 8),
                  const Text('Session Info'),
                ],
              ),
            ),
          ],
          onSelected: (value) =>
              _handleSessionAction(context, value, authService),
        );
      },
    );
  }

  void _handleSessionAction(
    BuildContext context,
    String action,
    AuthService authService,
  ) {
    switch (action) {
      case 'refresh':
        _refreshSession(context, authService);
        break;
      case 'extend':
        _extendSession(context, authService);
        break;
      case 'info':
        _showSessionInfo(context, authService);
        break;
    }
  }

  void _refreshSession(BuildContext context, AuthService authService) async {
    try {
      final success = await authService.refreshSession();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Session refreshed successfully'
                  : 'Failed to refresh session',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error refreshing session'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _extendSession(BuildContext context, AuthService authService) {
    authService.extendSession();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session extended successfully'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSessionInfo(BuildContext context, AuthService authService) {
    final timeLeft = authService.timeUntilTimeout;
    final lastActivity = authService.lastActivity;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Session Information',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(
              label: 'Status',
              value: authService.isAuthenticated ? 'Active' : 'Inactive',
              color: authService.isAuthenticated ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Time Left',
              value: timeLeft != null ? _formatDuration(timeLeft) : 'Unknown',
              color: timeLeft != null && timeLeft.inMinutes <= 10
                  ? Colors.red
                  : Colors.white70,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Last Activity',
              value: lastActivity != null
                  ? '${DateTime.now().difference(lastActivity).inMinutes} minutes ago'
                  : 'Unknown',
              color: Colors.white70,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Expiring Soon',
              value: authService.isSessionExpiringSoon ? 'Yes' : 'No',
              color: authService.isSessionExpiringSoon
                  ? Colors.orange
                  : Colors.green,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      return '${hours}h ${minutes}m';
    } else {
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      return '${minutes}m ${seconds}s';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
