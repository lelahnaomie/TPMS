import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:safetireapp/screens/welcome.dart';
import 'package:safetireapp/screens/dashboard.dart';
import 'package:safetireapp/screens/signup.dart';
import 'package:safetireapp/screens/signupdashboard.dart';
import 'package:safetireapp/screens/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyB3RMIUzSChYxPs2k0c87wmbWA_yrriZbI',
      appId: '1:102246578645:android:87975962b43b14f52da55c',
      messagingSenderId: '102246578645',
      projectId: 'safetire-6375e',
    ),
  );
  runApp(const TireSafeApp());
}

class TireSafeApp extends StatelessWidget {
  const TireSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TireSafe',
      theme: _buildAppTheme(),
      home: const WelcomeScreen(),
      routes: _buildRoutes(),
      debugShowCheckedModeBanner: false,
    );
  }

  // App Theme Configuration
  ThemeData _buildAppTheme() {
    const Color primaryColor = Color(0xFF0078D4);

    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      scaffoldBackgroundColor: Colors.grey[100],

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: Colors.black12,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  // Route Configuration
  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/welcome': (context) => const WelcomeScreen(),
      '/login': (context) => const LoginScreen(),
      '/signup': (context) => const SignUpScreen(),
      '/dashboard': (context) => const DashboardScreen(),
      '/signupdashboard': (context) => const DashboardSignup(),
    };
  }
}

// Route Names Constants
class AppRoutes {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';
  static const String signupDashboard = '/signupdashboard';
}

// App Constants
class AppConstants {
  static const Color primaryColor = Color(0xFF0078D4);
  static const String appName = 'TireSafe';
  static const String appTagline =
      'Real-time tire pressure monitoring for\nsafer journeys';
}
