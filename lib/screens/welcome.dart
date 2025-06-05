import 'package:flutter/material.dart';
import 'package:safetireapp/widgets/app_logo.dart';
import 'package:safetireapp/widgets/feature_item.dart';
import 'package:safetireapp/widgets/custom_button.dart';
import 'package:safetireapp/screens/signup.dart';

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
              // App Logo and Title Section
              const AppLogo(),
              const SizedBox(height: 16),

              // Welcome Text
              const Text(
                'Welcome to TireSafe',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0078D4),
                ),
              ),
              const SizedBox(height: 8),

              // Tagline
              const Text(
                'Real-time tire pressure monitoring for\nsafer journeys',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 48),

              // Feature List
              const FeatureItem(
                icon: Icons.monitor,
                title: 'Real-time Monitoring',
                subtitle: 'Track tire pressure in real time',
              ),
              const SizedBox(height: 24),

              const FeatureItem(
                icon: Icons.notification_important,
                title: 'Instant Alerts',
                subtitle: 'Get notified of pressure changes',
              ),
              const SizedBox(height: 24),

              const FeatureItem(
                icon: Icons.analytics,
                title: 'Smart Analysis',
                subtitle: 'Safety predictions and insights',
              ),
              const SizedBox(height: 48),

              // Get Started Button
              CustomButton(
                text: 'Get Started',
                onPressed: () => _navigateToSignup(context),
                isFullWidth: true,
              ),

              const SizedBox(height: 16),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: Colors.black54),
                  ),
                  TextButton(
                    onPressed: () => _navigateToLogin(context),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignUpScreen(),
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushNamed(context, '/login');
  }
}
