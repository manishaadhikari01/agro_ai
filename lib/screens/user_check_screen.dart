import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'main_app_screen.dart';

class UserCheckScreen extends StatelessWidget {
  const UserCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A2216), // Dark forest green
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Are you already registered?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE0E7C8), // Light cream
                    fontFamily: 'Inter',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildButton(context, 'Yes, I\'m registered', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    }),
                    const SizedBox(width: 20),
                    _buildButton(context, 'No, I\'m new', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegistrationScreen(),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainAppScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.close, color: Color(0xFFE0E7C8), size: 30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE0E7C8),
        foregroundColor: const Color(0xFF0A2216),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontFamily: 'Inter'),
      ),
    );
  }
}
