import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:safetireapp/dashboard.dart';
import 'package:safetireapp/signup.dart';
import 'package:safetireapp/signupdashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyB3RMIUzSChYxPs2k0c87wmbWA_yrriZbI',
          appId: '1:102246578645:android:87975962b43b14f52da55c',
          messagingSenderId: '102246578645',
          projectId: 'safetire-6375e'));
  runApp(const TireSafeApp());
}

class TireSafeApp extends StatelessWidget {
  const TireSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TireSafe',
      theme: ThemeData(
        primaryColor: const Color(0xFF0078D4),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0078D4)),
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: const Color(0xFF0078D4),
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0078D4),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const WelcomeScreen(),
      routes: {
        '/signup': (context) => const SignUpScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/signupdashboard': (context) => const DashboardSignup()
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo and Title
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF0078D4),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Welcome to TireSafe',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0078D4),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Real-time tire pressure monitoring for\nsafer journeys',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 48),

              // Feature List
              _buildFeatureItem(
                icon: Icons.monitor,
                title: 'Real-time Monitoring',
                subtitle: 'Track tire pressure in real time',
              ),
              const SizedBox(height: 24),
              _buildFeatureItem(
                icon: Icons.notification_important,
                title: 'Instant Alerts',
                subtitle: 'Get notified of pressure changes',
              ),
              const SizedBox(height: 24),
              _buildFeatureItem(
                icon: Icons.analytics,
                title: 'Smart Analysis',
                subtitle: 'Safety predictions',
              ),
              const SizedBox(height: 48),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0078D4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0078D4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
