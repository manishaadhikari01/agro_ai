import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const DeepShivaApp());
}

class DeepShivaApp extends StatelessWidget {
  const DeepShivaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeepShiva',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'Inter',
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
