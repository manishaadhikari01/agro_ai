import 'package:flutter/material.dart';

class Constants {
  // --- Neutral Colors ---
  final Color blackColor = Color(0xFF1A1A1A); // Main text
  final Color greyColor = Color(0xFF4F4F4F); // Subtext
  final Color iconGrey = Color(0xFF8A8A8A); // Icons
  final Color whiteColor = Color(0xFFFFFFFF);

  // --- iOS-Style Weather Gradient ---
  static const Color iosTop = Color(0xFFF9F6F0); // Warm off-white/light beige
  static const Color iosBottom = Color.fromARGB(
    255,
    1,
    38,
    92,
  ); // Muted desaturated blue

  // --- Hot Weather Gradient ---
  static const Color hotTop = Color(0xFFFCE9D8);
  static const Color hotBottom = Color(0xFFE55C1B);

  //basics
  final primaryColor = Color(0xFF3A5BA0); // Main brand blue
  final secondaryColor = Color(0xFF8A9BBF); // Soft muted blue
  final tertiaryColor = Color(0xFFDDE3EB); // Light cloudy blue

  // Text colors
  final primaryTextColor = Colors.black87;
  final secondaryTextColor = Colors.black54;

  final iosGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Constants.iosTop, Constants.iosBottom],
  );

  final hotGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Constants.hotTop, Constants.hotBottom],
  );
}
