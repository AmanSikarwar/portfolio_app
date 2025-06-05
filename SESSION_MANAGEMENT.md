# Session Management Implementation

## Overview

Comprehensive session management system for the Flutter portfolio app that provides automatic session handling, timeout management, and user activity tracking.

## Features

### 🔐 Core Session Management

- **Automatic Session Refresh**: Tokens are refreshed every 30 minutes
- **Activity-Based Timeout**: Sessions expire after 2 hours of inactivity
- **Session Warning**: Users are warned 10 minutes before timeout
- **Activity Tracking**: All user interactions extend the session

### 🎯 Session Configuration

```dart
static const Duration _sessionTimeout = Duration(hours: 2);           // Session timeout
static const Duration _refreshInterval = Duration(minutes: 30);       // Auto refresh
static const Duration _warningBeforeTimeout = Duration(minutes: 10);  // Warning time
static const Duration _activityCheckInterval = Duration(seconds: 30); // Activity check
```

### 📊 Session Monitoring

- **Real-time Status Display**: Shows remaining session time
- **Visual Indicators**: Color-coded status (green/orange/red)
- **Session Actions**: Manual refresh, extend, and info dialogs
- **Debug Widget**: Development tool for testing session behavior

## Architecture

### Core Components

#### 1. AuthService (Enhanced)

**Location**: `lib/core/services/auth_service.dart`

**New Properties**:

```dart
// Session timers
Timer? _sessionRefreshTimer;
Timer? _sessionTimeoutTimer;
DateTime? _lastActivity;
StreamSubscription<AuthState>? _authStateSubscription;

// Session status
DateTime? get lastActivity;
Duration? get timeUntilTimeout;
bool get isSessionExpiringSoon;
```

**New Methods**:

```dart
void updateActivity()              // Track user activity
Future<bool> refreshSession()      // Manual session refresh
void extendSession()              // Reset timeout timer
void _startSessionManagement()    // Initialize timers
void _stopSessionManagement()     // Cleanup timers
void _handleSessionTimeout()      // Handle automatic timeout
```

#### 2. SessionManager Widget

**Location**: `lib/presentation/widgets/session_manager.dart`

**Purpose**:

- Wraps the entire app to track user interactions
- Shows session warning dialogs
- Automatically updates activity on user actions

**Features**:

- Gesture detection (tap, pan, scroll)
- Pointer event tracking
- Session warning countdown dialog
- Automatic session extension

#### 3. SessionStatusWidget

**Location**: `lib/presentation/widgets/session_status_widget.dart`

**Purpose**:

- Real-time session status display
- Session action menu
- Session information dialog

**Components**:

- `SessionStatusWidget`: Shows remaining time with color coding
- `SessionActionsWidget`: Popup menu with session controls
- Session info dialog with detailed status

#### 4. SessionConfigWidget (Debug)

**Location**: `lib/presentation/widgets/session_config_widget.dart`

**Purpose**:

- Development and testing tool
- Debug session information
- Manual session control buttons
- Session timeout simulation

## Integration Points

### 1. Main App Integration

```dart
// main.dart
SessionManager(
  child: MaterialApp.router(
    // ... app configuration
  ),
)
```

### 2. Admin Header Integration

```dart
// admin/widgets/admin_header.dart
const SessionStatusWidget(),     // Session timer display
const SessionActionsWidget(),    // Session controls menu
```

### 3. AuthGuard Integration

```dart
// presentation/widgets/auth_guard.dart
void _checkAuthentication() {
  if (!_authService.isAuthenticated || !_authService.isAdmin) {
    context.go('/login');
  } else {
    _authService.updateActivity(); // Track access to protected routes
  }
}
```

## Session Flow

### 1. Login Process

```
User Login → Start Session Management → Initialize Timers → Track Activity
```

### 2. Active Session

```
User Activity → Update Last Activity → Reset Timeout Timer → Continue Session
```

### 3. Session Warning

```
10 Minutes Before Timeout → Show Warning Dialog → User Choice:
├── Extend Session → Reset Timers → Continue
└── Logout → Clean Up → Redirect to Login
```

### 4. Session Timeout

```
2 Hours of Inactivity → Automatic Logout → Clean Up → Redirect to Login
```

### 5. Manual Actions

```
Refresh Session → Validate with Supabase → Update Timers
Extend Session → Reset Activity → Update Timers
```

## User Experience

### Session Status Display

- **Green (>30min)**: Session healthy, circular indicator
- **Orange (10-30min)**: Session expiring soon, warning indicator
- **Red (<10min)**: Session critical, urgent indicator

### Activity Tracking

- Mouse/touch movements
- Clicks and taps
- Keyboard input
- Page navigation
- Route access

### Warning System

- Non-intrusive countdown dialog
- Clear "Stay Logged In" vs "Logout" options
- Real-time countdown timer
- Automatic logout if no response

## Security Features

### 1. Automatic Cleanup

- Timers are cancelled on logout
- Session data is cleared
- Auth state is reset

### 2. Activity Validation

- Only authenticated sessions are tracked
- Admin role verification required
- Protected route access updates activity

### 3. Token Management

- Automatic refresh prevents token expiry
- Failed refresh triggers logout
- Session persistence across page reloads

## Testing

### Manual Testing

1. **Login** → Check session timer starts
2. **Stay Inactive** → Verify warning at 10min mark
3. **User Activity** → Confirm timer resets
4. **Session Extend** → Test manual extension
5. **Session Refresh** → Verify token refresh
6. **Timeout** → Confirm automatic logout

### Debug Features

- Session debug widget in admin dashboard
- Real-time session information
- Manual timeout simulation
- Session action testing

## Configuration

### Environment Variables (Production)

```env
SESSION_TIMEOUT_HOURS=2
REFRESH_INTERVAL_MINUTES=30
WARNING_MINUTES=10
ACTIVITY_CHECK_SECONDS=30
```

### Customization Points

```dart
// Adjust timeouts in auth_service.dart
static const Duration _sessionTimeout = Duration(hours: 2);
static const Duration _refreshInterval = Duration(minutes: 30);
static const Duration _warningBeforeTimeout = Duration(minutes: 10);

// Customize warning dialog appearance in session_manager.dart
// Modify session status colors in session_status_widget.dart
```

## Troubleshooting

### Common Issues

1. **Session not refreshing**
   - Check Supabase connection
   - Verify token validity
   - Check console for errors

2. **Activity not tracking**
   - Ensure SessionManager wraps app
   - Check gesture detection
   - Verify auth state

3. **Warning not showing**
   - Check timer configuration
   - Verify dialog context
   - Check mounted state

### Debug Tools

- Use SessionConfigWidget for testing
- Monitor console logs in debug mode
- Check Flutter DevTools for timer state

## Future Enhancements

1. **Persistent Sessions**: Remember sessions across browser restarts
2. **Multi-tab Support**: Synchronize sessions across tabs
3. **Session Analytics**: Track session patterns and usage
4. **Custom Timeouts**: User-configurable session lengths
5. **Session Migration**: Transfer sessions between devices
6. **Offline Support**: Handle session management offline

## Security Considerations

1. **Token Storage**: Secure token storage in production
2. **Session Fixation**: Prevent session fixation attacks
3. **Cross-tab Security**: Manage sessions across multiple tabs
4. **Network Security**: Secure session refresh requests
5. **Audit Logging**: Log session events for security analysis
