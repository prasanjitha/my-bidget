/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Bidget';
  static const String appVersion = '1.0.0';

  // Authentication
  static const int maxLoginAttempts = 3;
  static const int lockoutDurationSeconds = 30;
  static const int authTimeoutSeconds = 30;

  // Biometric
  static const String biometricReason = 'Authenticate to access your budget data';

  // SharedPreferences Keys
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyUserId = 'user_id';
  static const String keyIsAuthenticated = 'is_authenticated';
  static const String keyFailedAttempts = 'failed_attempts';
  static const String keyLockoutTime = 'lockout_time';
  static const String keyIsPairedDevice = 'is_paired_device';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String categoriesCollection = 'categories';
  static const String expensesCollection = 'expenses';
  static const String categoryBudgetsCollection = 'categoryBudgets';
  static const String savingsCollection = 'savings';

  // Default Categories
  static const List<String> defaultCategories = ['Food', 'Rent'];

  // Default Currency
  static const String defaultCurrency = 'LKR';
  static const String defaultCurrencySymbol = 'RS';
}
