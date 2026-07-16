import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

/// Service for pairing multiple devices with the same user account
/// Allows data sync across devices without Firebase Authentication
class DevicePairingService {
  // Singleton pattern
  static final DevicePairingService _instance = DevicePairingService._internal();
  factory DevicePairingService() => _instance;
  DevicePairingService._internal();

  /// Generate pairing code from current userId
  /// Returns userId as string for QR code generation
  Future<String?> generatePairingCode() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(AppConstants.keyUserId);
    return userId;
  }

  /// Pair device with userId from QR code
  /// Replaces current userId with the scanned one
  Future<PairingResult> pairWithCode(String scannedUserId) async {
    try {
      // Validate userId format (should be numeric timestamp)
      if (scannedUserId.isEmpty || !_isValidUserId(scannedUserId)) {
        return PairingResult(
          success: false,
          errorMessage: 'Invalid pairing code',
        );
      }

      final prefs = await SharedPreferences.getInstance();

      // Get current userId to check if already paired
      final currentUserId = prefs.getString(AppConstants.keyUserId);
      if (currentUserId == scannedUserId) {
        return PairingResult(
          success: false,
          errorMessage: 'This device is already paired',
        );
      }

      // Store the new userId
      await prefs.setString(AppConstants.keyUserId, scannedUserId);
      await prefs.setBool(AppConstants.keyIsFirstLaunch, false);

      // Mark as paired device (not original enrollment)
      await prefs.setBool(AppConstants.keyIsPairedDevice, true);

      return PairingResult(
        success: true,
        userId: scannedUserId,
      );
    } catch (e) {
      return PairingResult(
        success: false,
        errorMessage: 'Pairing failed: ${e.toString()}',
      );
    }
  }

  /// Check if this is a paired device (not the original enrollment device)
  Future<bool> isPairedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyIsPairedDevice) ?? false;
  }

  /// Unpair device (resets to new user state)
  Future<void> unpairDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyUserId);
    await prefs.remove(AppConstants.keyIsPairedDevice);
    await prefs.remove(AppConstants.keyIsAuthenticated);
    await prefs.setBool(AppConstants.keyIsFirstLaunch, true);
  }

  /// Validate userId format (numeric timestamp)
  bool _isValidUserId(String userId) {
    final parsed = int.tryParse(userId);
    if (parsed == null) return false;

    // Should be a reasonable timestamp (after year 2020)
    final minTimestamp = DateTime(2020).millisecondsSinceEpoch;
    final maxTimestamp = DateTime.now().add(const Duration(days: 365)).millisecondsSinceEpoch;

    return parsed >= minTimestamp && parsed <= maxTimestamp;
  }
}

/// Result of pairing operation
class PairingResult {
  final bool success;
  final String? userId;
  final String? errorMessage;

  PairingResult({
    required this.success,
    this.userId,
    this.errorMessage,
  });
}
