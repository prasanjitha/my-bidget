import 'package:flutter/foundation.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/session_service.dart';
import '../../../../core/constants/app_constants.dart';

/// State management for authentication
/// Uses Provider pattern for state management
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final SessionService _sessionService = SessionService();

  // Auth state
  AuthState _state = AuthState.initial;
  String? _userId;
  String? _errorMessage;
  bool _isLoading = false;
  int _failedAttempts = 0;
  bool _isLockedOut = false;
  int? _remainingLockoutSeconds;

  // Getters
  AuthState get state => _state;
  String? get userId => _userId;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  int get failedAttempts => _failedAttempts;
  bool get isLockedOut => _isLockedOut;
  int? get remainingLockoutSeconds => _remainingLockoutSeconds;
  bool get isAuthenticated => _state == AuthState.authenticated;

  /// Initialize authentication state
  Future<void> initialize() async {
    _setLoading(true);

    try {
      // Check if first launch
      final isFirstLaunch = await _authService.isFirstLaunch();

      if (isFirstLaunch) {
        _setState(AuthState.needsEnrollment);
      } else {
        // Check if already authenticated
        final isAuthenticated = await _authService.isUserAuthenticated();

        if (isAuthenticated) {
          // Check if session requires re-authentication
          if (_sessionService.requiresReauthentication()) {
            _setState(AuthState.needsReauthentication);
          } else {
            _userId = await _authService.getCurrentUserId();
            _setState(AuthState.authenticated);
          }
        } else {
          _setState(AuthState.unauthenticated);
        }
      }
    } catch (e) {
      _setError('Initialization failed: ${e.toString()}');
      _setState(AuthState.error);
    } finally {
      _setLoading(false);
    }
  }

  /// AUTH-001: Enroll new user
  Future<void> enrollUser() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.enrollUser();

      if (result.success) {
        _userId = result.userId;
        _setState(AuthState.authenticated);
        _sessionService.markReauthenticationComplete();
      } else {
        _setError(result.errorMessage ?? 'Enrollment failed');
        _setState(AuthState.enrollmentFailed);
      }
    } catch (e) {
      _setError('Enrollment error: ${e.toString()}');
      _setState(AuthState.error);
    } finally {
      _setLoading(false);
    }
  }

  /// AUTH-002: Authenticate with biometrics
  Future<void> authenticateWithBiometrics() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.authenticateWithBiometrics();

      if (result.success) {
        _userId = result.userId;
        _failedAttempts = 0;
        _isLockedOut = false;
        _remainingLockoutSeconds = null;
        _setState(AuthState.authenticated);
        _sessionService.markReauthenticationComplete();
      } else {
        _setError(result.errorMessage ?? 'Authentication failed');

        if (result.isLockedOut) {
          _isLockedOut = true;
          _remainingLockoutSeconds = result.remainingLockoutSeconds;
          _setState(AuthState.lockedOut);
        } else {
          _failedAttempts = result.failedAttempts ?? 0;
          _setState(AuthState.authenticationFailed);
        }
      }
    } catch (e) {
      _setError('Authentication error: ${e.toString()}');
      _setState(AuthState.error);
    } finally {
      _setLoading(false);
    }
  }

  /// AUTH-003: Logout user
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.clearSession();
      _sessionService.resetSession();

      _userId = null;
      _failedAttempts = 0;
      _isLockedOut = false;
      _remainingLockoutSeconds = null;
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setError('Logout error: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Check biometric availability
  Future<BiometricCheckResult> checkBiometricAvailability() async {
    return await _authService.checkBiometricAvailability();
  }

  /// Authenticate via PIN (fallback for devices without biometric support)
  Future<void> authenticateWithPin() async {
    _setLoading(true);
    _clearError();
    try {
      // Get or generate userId from persistent storage
      String? uid = await _authService.getCurrentUserId();
      if (uid == null || uid.isEmpty) {
        // First time - create a userId
        final prefs = await _authService.getPrefs();
        uid = DateTime.now().millisecondsSinceEpoch.toString();
        await prefs.setString(AppConstants.keyUserId, uid);
        await prefs.setBool(AppConstants.keyIsFirstLaunch, false);
        await prefs.setBool(AppConstants.keyIsAuthenticated, true);
      } else {
        final prefs = await _authService.getPrefs();
        await prefs.setBool(AppConstants.keyIsAuthenticated, true);
      }
      _userId = uid;
      _failedAttempts = 0;
      _isLockedOut = false;
      _remainingLockoutSeconds = null;
      _setState(AuthState.authenticated);
      _sessionService.markReauthenticationComplete();
    } catch (e) {
      _setError('PIN authentication error: ${e.toString()}');
      _setState(AuthState.authenticationFailed);
    } finally {
      _setLoading(false);
    }
  }

  /// Retry authentication after lockout
  void retryAfterLockout() {
    _isLockedOut = false;
    _remainingLockoutSeconds = null;
    _failedAttempts = 0;
    _setState(AuthState.unauthenticated);
  }

  // Private helper methods
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}

/// Authentication states
enum AuthState {
  initial,
  needsEnrollment,
  enrollmentFailed,
  unauthenticated,
  needsReauthentication,
  authenticated,
  authenticationFailed,
  lockedOut,
  error,
}
