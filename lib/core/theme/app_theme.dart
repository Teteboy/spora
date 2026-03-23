import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.gold,
        surface: AppColors.surface,
      ),
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: AppColors.textHint,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: AppColors.primary.withValues(alpha: 0.1),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        displayMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        displaySmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        headlineLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        headlineMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        headlineSmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        titleSmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, color: AppColors.textSecondary),
        bodyLarge: TextStyle(fontFamily: 'Poppins', color: AppColors.textPrimary),
        bodyMedium: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary),
        bodySmall: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary),
        labelLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primaryLight,
        secondary: AppColors.gold,
        surface: AppColors.surfaceDark,
      ),
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundDarkLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: AppColors.textHintDark,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: AppColors.textSecondaryDark,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: AppColors.shadowDark,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundDarkLight,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.textSecondaryDark,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark),
        displayMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: AppColors.textPrimaryDark),
        displaySmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: AppColors.textPrimaryDark),
        headlineLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: AppColors.textPrimaryDark),
        headlineMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
        headlineSmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
        titleLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
        titleMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, color: AppColors.textPrimaryDark),
        titleSmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, color: AppColors.textSecondaryDark),
        bodyLarge: TextStyle(fontFamily: 'Poppins', color: AppColors.textPrimaryDark),
        bodyMedium: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondaryDark),
        bodySmall: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondaryDark),
        labelLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
      ),
    );
  }
}
