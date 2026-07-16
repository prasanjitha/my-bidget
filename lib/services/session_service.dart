import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

/// Service for managing app session and lifecycle
/// Implements AUTH-003 requirements for session management
class SessionService with WidgetsBindingObserver {
  bool _isInBackground = false;
  bool _requiresReauth = false;
  DateTime? _backgroundTime;

  // Singleton pattern
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  /// Initialize session service and start monitoring app lifecycle
  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Dispose session service
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _handleAppPaused();
        break;
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
      case AppLifecycleState.hidden:
        // App window is hidden but still running
        break;
    }
  }

  /// Handle app going to background
  void _handleAppPaused() {
    _isInBackground = true;
    _backgroundTime = DateTime.now();
    _requiresReauth = true;

    // Clear sensitive data from memory
    _clearSensitiveData();
  }

  /// Handle app returning to foreground
  void _handleAppResumed() {
    _isInBackground = false;

    // Check if re-authentication is required
    if (_requiresReauth) {
      // This flag will be checked by the app to show biometric prompt
    }
  }

  /// Handle app being terminated
  void _handleAppDetached() {
    _clearSensitiveData();
    _clearAuthenticationState();
  }

  /// Clear sensitive data from memory
  void _clearSensitiveData() {
    // In a real app, clear any cached sensitive data here
    // For example: clear cached expense data, user info, etc.
  }

  /// Clear authentication state
  void _clearAuthenticationState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyIsAuthenticated);
    } catch (e) {
      // Best effort cleanup
    }
  }

  /// Check if re-authentication is required
  bool requiresReauthentication() {
    return _requiresReauth;
  }

  /// Mark re-authentication as completed
  void markReauthenticationComplete() {
    _requiresReauth = false;
    _backgroundTime = null;
  }

  /// Check if app is in background
  bool get isInBackground => _isInBackground;

  /// Get time when app went to background
  DateTime? get backgroundTime => _backgroundTime;

  /// Reset session state (call after logout)
  void resetSession() {
    _isInBackground = false;
    _requiresReauth = false;
    _backgroundTime = null;
  }
}
