import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Session management
  Timer? _sessionRefreshTimer;
  Timer? _sessionTimeoutTimer;
  DateTime? _lastActivity;
  StreamSubscription<AuthState>? _authStateSubscription;

  // Session configuration
  static const Duration _sessionTimeout = Duration(
    hours: 2,
  ); // Auto logout after 2 hours of inactivity
  static const Duration _refreshInterval = Duration(
    minutes: 30,
  ); // Refresh token every 30 minutes
  static const Duration _warningBeforeTimeout = Duration(
    minutes: 10,
  ); // Warn user 10 minutes before timeout
  static const Duration _activityCheckInterval = Duration(
    seconds: 30,
  ); // Check activity every 30 seconds

  User? get currentUser => _supabase.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  bool get isAdmin => _isUserAdmin();

  // Session properties
  DateTime? get lastActivity => _lastActivity;
  Duration? get timeUntilTimeout {
    if (_lastActivity == null) return null;
    final elapsed = DateTime.now().difference(_lastActivity!);
    final remaining = _sessionTimeout - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get isSessionExpiringSoon {
    final timeLeft = timeUntilTimeout;
    return timeLeft != null && timeLeft <= _warningBeforeTimeout;
  }

  // Admin credentials - In production, this should be handled via Supabase RLS
  static const String _adminEmail = 'admin@amansikarwar.com';
  static const String _adminPassword = 'admin123'; // Change this in production

  /// Initialize auth service and listen to auth state changes
  void initialize() {
    _authStateSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        _startSessionManagement();
      } else if (data.event == AuthChangeEvent.signedOut) {
        _stopSessionManagement();
      }
      notifyListeners();
    });

    // If user is already signed in, start session management
    if (isAuthenticated) {
      _startSessionManagement();
    }
  }

  /// Dispose auth service and clean up timers
  @override
  void dispose() {
    _stopSessionManagement();
    _authStateSubscription?.cancel();
    super.dispose();
  }

  /// Start session management timers
  void _startSessionManagement() {
    _updateLastActivity();
    _startSessionRefreshTimer();
    _startSessionTimeoutTimer();
  }

  /// Stop all session management timers
  void _stopSessionManagement() {
    _sessionRefreshTimer?.cancel();
    _sessionTimeoutTimer?.cancel();
    _lastActivity = null;
  }

  /// Update last activity timestamp
  void updateActivity() {
    _updateLastActivity();
    _resetSessionTimeoutTimer();
  }

  void _updateLastActivity() {
    _lastActivity = DateTime.now();
  }

  /// Start automatic session refresh timer
  void _startSessionRefreshTimer() {
    _sessionRefreshTimer?.cancel();
    _sessionRefreshTimer = Timer.periodic(_refreshInterval, (timer) {
      _refreshSession();
    });
  }

  /// Start session timeout timer
  void _startSessionTimeoutTimer() {
    _sessionTimeoutTimer?.cancel();
    _sessionTimeoutTimer = Timer(_sessionTimeout, () {
      _handleSessionTimeout();
    });
  }

  /// Reset session timeout timer (called when user is active)
  void _resetSessionTimeoutTimer() {
    _sessionTimeoutTimer?.cancel();
    _startSessionTimeoutTimer();
  }

  /// Refresh the current session
  Future<void> _refreshSession() async {
    try {
      if (isAuthenticated) {
        await _supabase.auth.refreshSession();
        if (kDebugMode) {
          print('Session refreshed successfully');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Session refresh failed: $e');
      }
      // If refresh fails, sign out the user
      await signOut();
    }
  }

  /// Handle session timeout
  void _handleSessionTimeout() {
    if (kDebugMode) {
      print('Session timed out due to inactivity');
    }
    signOut();
  }

  /// Manually refresh session (can be called by UI)
  Future<bool> refreshSession() async {
    try {
      await _supabase.auth.refreshSession();
      _updateLastActivity();
      _resetSessionTimeoutTimer();
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Manual session refresh failed: $e');
      }
      return false;
    }
  }

  /// Extend session (reset timeout)
  void extendSession() {
    _updateLastActivity();
    _resetSessionTimeoutTimer();
    notifyListeners();
  }

  /// Sign in with email and password
  Future<AuthResult> signIn(String email, String password) async {
    try {
      // For demo purposes, check against hardcoded admin credentials
      if (email.toLowerCase() == _adminEmail && password == _adminPassword) {
        // Create a session using Supabase auth with the admin email
        final response = await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (response.user != null) {
          _startSessionManagement();
          notifyListeners();
          return AuthResult.success('Successfully signed in as admin');
        } else {
          return AuthResult.error('Invalid credentials');
        }
      } else {
        return AuthResult.error('Invalid admin credentials');
      }
    } catch (e) {
      // If Supabase auth fails, try creating the admin user
      if (email.toLowerCase() == _adminEmail && password == _adminPassword) {
        try {
          await _supabase.auth.signUp(email: email, password: password);

          // Try signing in again
          final response = await _supabase.auth.signInWithPassword(
            email: email,
            password: password,
          );

          if (response.user != null) {
            _startSessionManagement();
            notifyListeners();
            return AuthResult.success('Successfully signed in as admin');
          }
        } catch (signUpError) {
          if (kDebugMode) {
            print('Auth error: $signUpError');
          }
        }
      }

      return AuthResult.error(
        'Authentication failed. Please check your credentials.',
      );
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      _stopSessionManagement();
      await _supabase.auth.signOut();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Sign out error: $e');
      }
    }
  }

  /// Check if current user is admin
  bool _isUserAdmin() {
    final user = currentUser;
    if (user == null) return false;

    // Check if user email matches admin email
    return user.email?.toLowerCase() == _adminEmail;
  }

  /// Get user display name
  String get userDisplayName {
    final user = currentUser;
    if (user == null) return 'Guest';

    return user.userMetadata?['full_name'] ??
        user.email?.split('@').first ??
        'Admin User';
  }

  /// Get user avatar URL
  String? get userAvatarUrl {
    final user = currentUser;
    return user?.userMetadata?['avatar_url'];
  }
}

/// Result class for authentication operations
class AuthResult {
  final bool isSuccess;
  final String message;
  final String? errorCode;

  AuthResult._(this.isSuccess, this.message, [this.errorCode]);

  factory AuthResult.success(String message) => AuthResult._(true, message);
  factory AuthResult.error(String message, [String? errorCode]) =>
      AuthResult._(false, message, errorCode);
}
