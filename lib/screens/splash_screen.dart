import 'package:flutter/material.dart';
import 'user_check_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A2216), // Dark forest green
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'DeepShiva',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE0E7C8), // Light cream/pale green
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 100),
            // Progress indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIndicator(false),
                const SizedBox(width: 8),
                _buildIndicator(false),
                const SizedBox(width: 8),
                _buildIndicator(true), // Last one highlighted
              ],
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserCheckScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0E7C8),
                foregroundColor: const Color(0xFF0A2216),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(fontSize: 18, fontFamily: 'Inter'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return Container(
      width: 24,
      height: 4,
      decoration: BoxDecoration(
        color:
            isActive ? const Color(0xFFE0E7C8) : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
