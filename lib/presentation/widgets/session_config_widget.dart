import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';

class SessionConfigWidget extends StatefulWidget {
  const SessionConfigWidget({super.key});

  @override
  State<SessionConfigWidget> createState() => _SessionConfigWidgetState();
}

class _SessionConfigWidgetState extends State<SessionConfigWidget> {
  bool _showDebugInfo = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (!authService.isAuthenticated) {
          return const SizedBox.shrink();
        }

        return Container(
          width: 300, // Add explicit width constraint
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900]?.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Session Management Debug',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showDebugInfo = !_showDebugInfo;
                      });
                    },
                    icon: Icon(
                      _showDebugInfo ? Icons.visibility_off : Icons.visibility,
                      color: Colors.blue,
                    ),
                    tooltip: _showDebugInfo
                        ? 'Hide Debug Info'
                        : 'Show Debug Info',
                  ),
                ],
              ),
              if (_showDebugInfo) ...[
                const SizedBox(height: 12),
                _buildDebugRow(
                  'Status',
                  authService.isAuthenticated ? 'Active' : 'Inactive',
                ),
                _buildDebugRow('Admin', authService.isAdmin ? 'Yes' : 'No'),
                _buildDebugRow(
                  'Time Until Timeout',
                  authService.timeUntilTimeout != null
                      ? _formatDuration(authService.timeUntilTimeout!)
                      : 'Unknown',
                ),
                _buildDebugRow(
                  'Last Activity',
                  authService.lastActivity != null
                      ? '${DateTime.now().difference(authService.lastActivity!).inSeconds}s ago'
                      : 'Unknown',
                ),
                _buildDebugRow(
                  'Session Expiring Soon',
                  authService.isSessionExpiringSoon ? 'Yes' : 'No',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => authService.extendSession(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Extend Session'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _testSessionTimeout(authService),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Test Timeout'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => authService.refreshSession(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Refresh Session'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _testSessionTimeout(AuthService authService) {
    // Simulate session timeout for testing
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Test Session Timeout',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will simulate a session timeout. Are you sure?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Force a timeout by setting last activity to a long time ago
              // This is for testing purposes only
              authService.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Test Timeout'),
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
