import 'package:agroai/utils/app_mode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import 'user_check_screen.dart';
import 'main_app_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final authController = Provider.of<AuthController>(context, listen: false);

    // ✅ IMPORTANT: wait for auth check
    try {
      // Run splash delay & auth check in parallel
      await Future.wait([
        authController.checkAuthStatus(),
        Future.delayed(const Duration(seconds: 2)),
      ]);
    } catch (_) {
      // In case something goes wrong, treat as logged out
    }

    if (!mounted) return;

    if (authController.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainAppScreen(mode: AppMode.authenticated),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserCheckScreen()),
      );
    }
  }

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
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE0E7C8)),
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
