import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/biometric_login_screen.dart';
import 'features/home/presentation/screens/main_navigation_screen.dart';
import 'features/home/presentation/providers/home_provider.dart';
import 'features/home/presentation/providers/settings_provider.dart';
import 'services/session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (for Firestore database only, not for authentication)
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully for Firestore database');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // Show error screen if Firebase fails
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 80,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Database Initialization Failed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: $e',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }

  // Initialize session service
  SessionService().initialize();

  // Initialize settings
  final settingsProvider = SettingsProvider();
  await settingsProvider.initialize();

  runApp(MyApp(settingsProvider: settingsProvider));
}

class MyApp extends StatelessWidget {
  final SettingsProvider settingsProvider;

  const MyApp({super.key, required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider.value(value: settingsProvider),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Bidget',
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2196F3),
                primary: const Color(0xFF2196F3),
                brightness: Brightness.light,
              ),
              primaryColor: const Color(0xFF2196F3),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
                backgroundColor: Color(0xFF2196F3),
                foregroundColor: Colors.white,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.dark,
                ),
              ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: Color(0xFF2196F3),
                foregroundColor: Colors.white,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2196F3),
                primary: const Color(0xFF2196F3),
                brightness: Brightness.dark,
              ).copyWith(
                surface: const Color(0xFF1E1E1E),
              ),
              primaryColor: const Color(0xFF2196F3),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
                backgroundColor: Color(0xFF1E1E1E),
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.dark,
                ),
              ),
              scaffoldBackgroundColor: const Color(0xFF121212),
              cardTheme: const CardThemeData(
                color: Color(0xFF1E1E1E),
              ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: Color(0xFF2196F3),
                foregroundColor: Colors.white,
              ),
            ),
            home: Builder(
              builder: (context) {
                final isDarkMode = settings.isDarkMode;
                return AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
                    statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
                    systemNavigationBarColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
                    systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
                  ),
                  child: const AuthenticationWrapper(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Wrapper widget to handle authentication state and navigation
class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper>
    with WidgetsBindingObserver {
  bool _initializedHomeForSession = false;

  @override
  void initState() {
    super.initState();
    // Initialize auth provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initialize();
    });

    // Listen to app lifecycle for session management
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app returning from background
    if (state == AppLifecycleState.resumed) {
      final authProvider = context.read<AuthProvider>();
      final sessionService = SessionService();

      // If app came from background and user is authenticated
      if (sessionService.requiresReauthentication() &&
          authProvider.isAuthenticated) {
        // Trigger re-authentication
        authProvider.initialize();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen during initialization
        if (authProvider.state == AuthState.initial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Navigate based on auth state
        if (authProvider.isAuthenticated) {
          if (!_initializedHomeForSession) {
            _initializedHomeForSession = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<HomeProvider>().initialize(authProvider.userId);
            });
          }
          return const MainNavigationScreen();
        }

        // Reset the initialization flag when not authenticated
        _initializedHomeForSession = false;

        // Show biometric login for all other states
        return const BiometricLoginScreen();
      },
    );
  }
}
