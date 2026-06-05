import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF090B0F);
  static const Color surface = Color(0xFF121720);
  static const Color incomingBubble = Color(0xFF1A2330);
  static const Color outgoingBubble = Color(0xFF123E38);
  static const Color signalGreen = Color(0xFF6EE7B7);
  static const Color warningRed = Color(0xFFE05252);
  static const Color mutedText = Color(0xFF8A93A3);

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: signalGreen,
        surface: surface,
        error: warningRed,
      ),
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        bodyMedium: TextStyle(fontSize: 15, height: 1.35),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }
}
