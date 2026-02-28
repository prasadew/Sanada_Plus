import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors (WhatsApp similar)
  static const Color primaryTeal = Color(0xFF075E54);
  static const Color primaryTealDark = Color(0xFF128C7E);
  static const Color lightGreen = Color(0xFF25D366);
  static const Color tealGreenDark = Color(0xFF00BFA5);
  static const Color backgroundColorLight = Color(0xFFECE5DD);
  static const Color chatBubbleGreen = Color(0xFFDCF8C6);
  static const Color chatBubbleDark = Color(0xFF056162);
  static const Color darkBackgroundColor = Color(0xFF0B141A);
  static const Color darkAppBarColor = Color(0xFF1F2C34);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        primary: primaryTealDark,
        secondary: lightGreen,
        surface: Colors.white,
        background: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryTealDark,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: lightGreen,
        foregroundColor: Colors.white,
      ),
      iconTheme: const IconThemeData(
        color: primaryTealDark,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        brightness: Brightness.dark,
        primary: tealGreenDark,
        secondary: lightGreen,
        surface: darkAppBarColor,
        background: darkBackgroundColor,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkAppBarColor,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: tealGreenDark,
        foregroundColor: Colors.white,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white70,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkAppBarColor,
      ),
    );
  }
}
