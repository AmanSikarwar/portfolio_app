import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';

class SessionManager extends StatefulWidget {
  final Widget child;

  const SessionManager({super.key, required this.child});

  @override
  State<SessionManager> createState() => _SessionManagerState();
}

class _SessionManagerState extends State<SessionManager> {
  Timer? _warningTimer;
  bool _showingWarning = false;

  @override
  void initState() {
    super.initState();
    _startWarningTimer();
  }

  @override
  void dispose() {
    _warningTimer?.cancel();
    super.dispose();
  }

  void _startWarningTimer() {
    _warningTimer?.cancel();
    _warningTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkSessionStatus();
    });
  }

  void _checkSessionStatus() {
    final authService = context.read<AuthService>();

    if (authService.isAuthenticated &&
        authService.isSessionExpiringSoon &&
        !_showingWarning) {
      _showSessionWarning();
    }
  }

  void _showSessionWarning() {
    if (!mounted) return;

    setState(() {
      _showingWarning = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SessionWarningDialog(
        onExtend: () {
          context.read<AuthService>().extendSession();
          setState(() {
            _showingWarning = false;
          });
        },
        onLogout: () {
          context.read<AuthService>().signOut();
          setState(() {
            _showingWarning = false;
          });
        },
      ),
    ).then((_) {
      setState(() {
        _showingWarning = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _trackUserActivity(),
      onPanDown: (_) => _trackUserActivity(),
      onScaleStart: (_) => _trackUserActivity(),
      child: Listener(
        onPointerDown: (_) => _trackUserActivity(),
        onPointerMove: (_) => _trackUserActivity(),
        onPointerUp: (_) => _trackUserActivity(),
        child: widget.child,
      ),
    );
  }

  void _trackUserActivity() {
    final authService = context.read<AuthService>();
    if (authService.isAuthenticated) {
      authService.updateActivity();
    }
  }
}

class SessionWarningDialog extends StatefulWidget {
  final VoidCallback onExtend;
  final VoidCallback onLogout;

  const SessionWarningDialog({
    super.key,
    required this.onExtend,
    required this.onLogout,
  });

  @override
  State<SessionWarningDialog> createState() => _SessionWarningDialogState();
}

class _SessionWarningDialogState extends State<SessionWarningDialog> {
  Timer? _countdownTimer;
  Duration _timeLeft = const Duration(minutes: 10);

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    final authService = context.read<AuthService>();
    _timeLeft = authService.timeUntilTimeout ?? const Duration(minutes: 10);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft = _timeLeft - const Duration(seconds: 1);
      });

      if (_timeLeft.inSeconds <= 0) {
        timer.cancel();
        Navigator.of(context).pop();
        widget.onLogout();
      }
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.accentColor.withValues(alpha: 0.3)),
      ),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
          const SizedBox(width: 12),
          const Text(
            'Session Expiring',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your session will expire due to inactivity.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Time remaining: ${_formatDuration(_timeLeft)}',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onLogout();
          },
          child: const Text('Logout', style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onExtend();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Stay Logged In'),
        ),
      ],
    );
  }
}
