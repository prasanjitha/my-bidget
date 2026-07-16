import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'qr_scan_screen.dart';

/// Biometric Login Screen
/// Implements AUTH-001 and AUTH-002 UI requirements
class BiometricLoginScreen extends StatefulWidget {
  const BiometricLoginScreen({super.key});

  @override
  State<BiometricLoginScreen> createState() => _BiometricLoginScreenState();
}

class _BiometricLoginScreenState extends State<BiometricLoginScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger authentication automatically after screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    final authProvider = context.read<AuthProvider>();

    // Check if this is first time (enrollment) or returning user
    if (authProvider.state == AuthState.needsEnrollment) {
      await authProvider.enrollUser();
    } else {
      await authProvider.authenticateWithBiometrics();
    }
  }

  void _showPinDialog(BuildContext context) {
    final pinController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enter PIN'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'PIN',
              hintText: 'Enter 4-digit PIN',
              border: OutlineInputBorder(),
              counterText: '',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter PIN';
              }
              if (value.length != 4) {
                return 'PIN must be 4 digits';
              }
              return null;
            },
            onFieldSubmitted: (value) {
              if (formKey.currentState!.validate()) {
                _handlePinSubmit(dialogContext, pinController.text);
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                _handlePinSubmit(dialogContext, pinController.text);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _handlePinSubmit(BuildContext dialogContext, String enteredPin) async {
    if (enteredPin == '2036') {
      // Correct PIN - close dialog and authenticate via AuthService
      Navigator.of(dialogContext).pop();

      final authProvider = context.read<AuthProvider>();

      // If first time, enroll the user
      if (authProvider.state == AuthState.needsEnrollment) {
        await authProvider.enrollUser();
      } else {
        // Mark as authenticated (bypass biometric for devices without support)
        await authProvider.authenticateWithBiometrics();
      }
    } else {
      // Wrong PIN - show error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect PIN. Try 2036'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Show different UI based on auth state
          if (authProvider.isLoading) {
            return _buildLoadingState();
          }

          if (authProvider.isLockedOut) {
            return _buildLockedOutState(authProvider);
          }

          if (authProvider.state == AuthState.authenticationFailed ||
              authProvider.state == AuthState.enrollmentFailed) {
            return _buildErrorState(authProvider);
          }

          // Default: show biometric prompt
          return _buildBiometricPromptState(authProvider);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            'Initializing...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricPromptState(AuthProvider authProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      'assets/icon/app_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // App Name
              const Text(
                'Bidget',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Budget Tracking Made Simple',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 80),

              // Biometric Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fingerprint,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // Instruction Text
              Text(
                authProvider.state == AuthState.needsEnrollment
                    ? 'Set up biometric authentication'
                    : 'Authenticate to access your data',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 48),

              // Authenticate Button
              ElevatedButton.icon(
                onPressed: authProvider.isLoading ? null : _authenticate,
                icon: const Icon(Icons.fingerprint),
                label: Text(
                  authProvider.state == AuthState.needsEnrollment
                      ? 'Enroll'
                      : 'Authenticate',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Enter PIN Button (for devices without biometric support)
              TextButton.icon(
                onPressed: () => _showPinDialog(context),
                icon: const Icon(Icons.pin, color: Colors.white),
                label: const Text(
                  'Enter PIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),

              // Failed attempts indicator
              if (authProvider.failedAttempts > 0) ...[
                const SizedBox(height: 16),
                Text(
                  'Failed attempts: ${authProvider.failedAttempts}/3',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],

              // Show "Pair with existing device" only on first enrollment
              if (authProvider.state == AuthState.needsEnrollment) ...[
                const SizedBox(height: 40),
                const Divider(
                  color: Colors.white38,
                  thickness: 1,
                  indent: 60,
                  endIndent: 60,
                ),
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QrScanScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  label: const Text(
                    'Pair with existing device',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(AuthProvider authProvider) {
    final errorMsg = authProvider.errorMessage ?? 'An error occurred';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.red.shade400,
            Colors.red.shade700,
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Authentication Failed',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  errorMsg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _authenticate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLockedOutState(AuthProvider authProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.orange.shade400,
            Colors.orange.shade700,
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_clock,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Too Many Attempts',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Please wait ${authProvider.remainingLockoutSeconds ?? 30} seconds before trying again.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 32),

                // Countdown timer
                TweenAnimationBuilder<int>(
                  tween: IntTween(
                    begin: authProvider.remainingLockoutSeconds ?? 30,
                    end: 0,
                  ),
                  duration: Duration(
                      seconds: authProvider.remainingLockoutSeconds ?? 30),
                  builder: (context, value, child) {
                    if (value == 0) {
                      // Auto retry after countdown
                      Future.microtask(() {
                        authProvider.retryAfterLockout();
                      });
                    }

                    return Text(
                      '$value',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
