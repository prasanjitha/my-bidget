import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

/// Service for handling authentication operations
/// Implements AUTH-001, AUTH-002, AUTH-003 requirements
/// Uses only local biometric authentication (no Firebase)
class AuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// AUTH-001: Check if device biometrics are available
  Future<BiometricCheckResult> checkBiometricAvailability() async {
    try {
      // Check if the device can check biometrics
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;

      if (!canCheckBiometrics) {
        return BiometricCheckResult(
          isAvailable: false,
          errorMessage: 'Biometric authentication not available on this device',
        );
      }

      // Get available biometric types
      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        return BiometricCheckResult(
          isAvailable: false,
          errorMessage: 'Please set up biometric authentication in device settings',
          canNavigateToSettings: true,
        );
      }

      return BiometricCheckResult(
        isAvailable: true,
        availableTypes: availableBiometrics,
      );
    } catch (e) {
      return BiometricCheckResult(
        isAvailable: false,
        errorMessage: 'Error checking biometric availability: ${e.toString()}',
      );
    }
  }

  /// AUTH-001: Enroll user with biometric authentication
  Future<AuthResult> enrollUser() async {
    try {
      // First check biometric availability
      final biometricCheck = await checkBiometricAvailability();
      if (!biometricCheck.isAvailable) {
        return AuthResult(
          success: false,
          errorMessage: biometricCheck.errorMessage,
        );
      }

      // Attempt biometric authentication for enrollment
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Set up biometric authentication for Bidget',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        // Generate a simple user ID (timestamp-based)
        final String userId = DateTime.now().millisecondsSinceEpoch.toString();

        // Store user ID and first launch flag
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.keyUserId, userId);
        await prefs.setBool(AppConstants.keyIsFirstLaunch, false);
        await prefs.setBool(AppConstants.keyIsAuthenticated, true);

        return AuthResult(
          success: true,
          userId: userId,
        );
      } else {
        return AuthResult(
          success: false,
          errorMessage: 'Biometric enrollment cancelled',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Enrollment failed: ${e.toString()}',
      );
    }
  }

  /// AUTH-002: Authenticate user with biometrics
  Future<AuthResult> authenticateWithBiometrics() async {
    try {
      // Check if biometrics are available
      final biometricCheck = await checkBiometricAvailability();
      if (!biometricCheck.isAvailable) {
        return AuthResult(
          success: false,
          errorMessage: biometricCheck.errorMessage,
        );
      }

      // Check lockout status
      final prefs = await SharedPreferences.getInstance();
      final int failedAttempts = prefs.getInt(AppConstants.keyFailedAttempts) ?? 0;
      final int? lockoutTime = prefs.getInt(AppConstants.keyLockoutTime);

      if (lockoutTime != null) {
        final int currentTime = DateTime.now().millisecondsSinceEpoch;
        final int timeSinceLockout = currentTime - lockoutTime;
        final int lockoutDuration = AppConstants.lockoutDurationSeconds * 1000;

        if (timeSinceLockout < lockoutDuration) {
          final int remainingSeconds =
              ((lockoutDuration - timeSinceLockout) / 1000).ceil();
          return AuthResult(
            success: false,
            errorMessage: 'Too many failed attempts. Please try again in $remainingSeconds seconds.',
            isLockedOut: true,
            remainingLockoutSeconds: remainingSeconds,
          );
        } else {
          // Lockout period expired, reset
          await prefs.remove(AppConstants.keyLockoutTime);
          await prefs.setInt(AppConstants.keyFailedAttempts, 0);
        }
      }

      // Attempt biometric authentication
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: AppConstants.biometricReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        // Reset failed attempts on success
        await prefs.setInt(AppConstants.keyFailedAttempts, 0);
        await prefs.remove(AppConstants.keyLockoutTime);
        await prefs.setBool(AppConstants.keyIsAuthenticated, true);

        // Get stored user ID
        final String? userId = prefs.getString(AppConstants.keyUserId);

        return AuthResult(
          success: true,
          userId: userId,
        );
      } else {
        // Increment failed attempts
        final int newFailedAttempts = failedAttempts + 1;
        await prefs.setInt(AppConstants.keyFailedAttempts, newFailedAttempts);

        // Check if should lock out
        if (newFailedAttempts >= AppConstants.maxLoginAttempts) {
          final int currentTime = DateTime.now().millisecondsSinceEpoch;
          await prefs.setInt(AppConstants.keyLockoutTime, currentTime);

          return AuthResult(
            success: false,
            errorMessage: 'Too many failed attempts. Please try again later.',
            isLockedOut: true,
            remainingLockoutSeconds: AppConstants.lockoutDurationSeconds,
          );
        }

        return AuthResult(
          success: false,
          errorMessage: 'Authentication failed. Please try again.',
          failedAttempts: newFailedAttempts,
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Authentication error: ${e.toString()}',
      );
    }
  }

  /// AUTH-003: Check if user is already authenticated
  Future<bool> isUserAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool isAuthenticated =
          prefs.getBool(AppConstants.keyIsAuthenticated) ?? false;

      // Check if user ID exists
      final String? userId = prefs.getString(AppConstants.keyUserId);

      return isAuthenticated && userId != null;
    } catch (e) {
      return false;
    }
  }

  /// AUTH-003: Check if this is first launch
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyIsFirstLaunch) ?? true;
  }

  /// AUTH-003: Clear session (logout)
  Future<void> clearSession() async {
    try {
      // Clear local session data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyIsAuthenticated);
      await prefs.remove(AppConstants.keyFailedAttempts);
      await prefs.remove(AppConstants.keyLockoutTime);
      // Keep userId and isFirstLaunch for potential re-authentication
    } catch (e) {
      // Log error but don't throw - best effort cleanup
      debugPrint('Error clearing session: $e');
    }
  }

  /// AUTH-003: Get current user ID
  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyUserId);
  }
}

/// Result of biometric availability check
class BiometricCheckResult {
  final bool isAvailable;
  final String? errorMessage;
  final bool canNavigateToSettings;
  final List<BiometricType>? availableTypes;

  BiometricCheckResult({
    required this.isAvailable,
    this.errorMessage,
    this.canNavigateToSettings = false,
    this.availableTypes,
  });
}

/// Result of authentication operation
class AuthResult {
  final bool success;
  final String? userId;
  final String? errorMessage;
  final bool isLockedOut;
  final int? remainingLockoutSeconds;
  final int? failedAttempts;

  AuthResult({
    required this.success,
    this.userId,
    this.errorMessage,
    this.isLockedOut = false,
    this.remainingLockoutSeconds,
    this.failedAttempts,
  });
}
