import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  // ═══════════════════════════════════════════════════════════════
  //  LIGHT THEME
  // ═══════════════════════════════════════════════════════════════
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.mediumBrown,
        onPrimary: Colors.white,
        primaryContainer: AppColors.tan,
        onPrimaryContainer: AppColors.darkBrown,
        secondary: AppColors.tan,
        onSecondary: AppColors.darkBrown,
        secondaryContainer: AppColors.cream,
        onSecondaryContainer: AppColors.darkBrown,
        surface: Colors.white,
        onSurface: AppColors.darkBrown,
        surfaceVariant: AppColors.cream,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.warmGray,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBrown,
        foregroundColor: AppColors.cream,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.cream),
        titleTextStyle: TextStyle(
          color: AppColors.cream,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.mediumBrown,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      iconTheme: const IconThemeData(color: AppColors.mediumBrown),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 0.5,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.mediumBrown,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.warmGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.warmGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.mediumBrown, width: 2),
        ),
        hintStyle: TextStyle(color: AppColors.warmGray.withOpacity(0.8)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mediumBrown,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.mediumBrown),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.mediumBrown,
        unselectedItemColor: AppColors.warmGray,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cream,
        selectedColor: AppColors.mediumBrown,
        labelStyle: const TextStyle(color: AppColors.darkBrown),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) =>
            states.contains(MaterialState.selected)
                ? AppColors.mediumBrown
                : AppColors.warmGray),
        trackColor: MaterialStateProperty.resolveWith((states) =>
            states.contains(MaterialState.selected)
                ? AppColors.tan.withOpacity(0.5)
                : AppColors.warmGray.withOpacity(0.3)),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  DARK THEME
  // ═══════════════════════════════════════════════════════════════
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.tan,
        onPrimary: AppColors.darkBrown,
        primaryContainer: AppColors.mediumBrown,
        onPrimaryContainer: AppColors.cream,
        secondary: AppColors.warmGray,
        onSecondary: AppColors.darkBrown,
        secondaryContainer: AppColors.mediumBrown,
        onSecondaryContainer: AppColors.cream,
        surface: AppColors.darkSurface,
        onSurface: AppColors.cream,
        surfaceVariant: AppColors.darkAppBar,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.darkDivider,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkAppBar,
        foregroundColor: AppColors.cream,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.cream),
        titleTextStyle: TextStyle(
          color: AppColors.cream,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.mediumBrown,
        foregroundColor: AppColors.cream,
        elevation: 4,
        shape: CircleBorder(),
      ),
      iconTheme: const IconThemeData(color: AppColors.warmGray),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 0.5,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.tan,
        textColor: AppColors.cream,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.tan, width: 2),
        ),
        hintStyle: TextStyle(color: AppColors.warmGray.withOpacity(0.6)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mediumBrown,
          foregroundColor: AppColors.cream,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.tan),
      ),
      cardTheme: CardTheme(
        color: AppColors.darkSurface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.tan,
        unselectedItemColor: AppColors.warmGray,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkAppBar,
        selectedColor: AppColors.mediumBrown,
        labelStyle: const TextStyle(color: AppColors.cream),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) =>
            states.contains(MaterialState.selected)
                ? AppColors.tan
                : AppColors.warmGray),
        trackColor: MaterialStateProperty.resolveWith((states) =>
            states.contains(MaterialState.selected)
                ? AppColors.mediumBrown.withOpacity(0.5)
                : AppColors.darkDivider),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkAppBar,
      ),
    );
  }
}
