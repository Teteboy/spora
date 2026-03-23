import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF1E3A8A);       // Dark Navy Blue
  static const Color primaryLight = Color(0xFF2563EB);   // Medium Blue
  static const Color primaryDark = Color(0xFF0D1B3E);    // Deep Navy

  // Accent/Gold Colors
  static const Color gold = Color(0xFFF59E0B);
  static const Color goldDark = Color(0xFFD97706);
  static const Color goldLight = Color(0xFFFBBF24);

  // Background Colors - Light Mode
  static const Color background = Color(0xFFFFFFFF);       // Pure White
  static const Color backgroundLight = Color(0xFFF8FAFF);
  static const Color surface = Color(0xFFFFFFFF);

  // Background Colors - Dark Mode
  static const Color backgroundDark = Color(0xFF0F172A);    // Dark Slate
  static const Color backgroundDarkLight = Color(0xFF1E293B); // Slate 800
  static const Color surfaceDark = Color(0xFF1E293B);      // Slate 800

  // Text Colors - Light Mode
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFFAFC0D4);
  static const Color textLight = Color(0xFFFFFFFF);

  // Text Colors - Dark Mode
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textHintDark = Color(0xFF475569);

  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF97316);
  static const Color info = Color(0xFF3B82F6);

  // Border & Divider
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color borderDark = Color(0xFF334155);
  static const Color dividerDark = Color(0xFF1E293B);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF1E3A8A),
    Color(0xFF2563EB),
  ];

  static const List<Color> heroGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFF8FAFF),
    Color(0xFFF1F5F9),
  ];

  // Dark Mode Gradient
  static const List<Color> heroGradientDark = [
    Color(0xFF0F172A),
    Color(0xFF1E293B),
    Color(0xFF334155),
  ];

  static const List<Color> goldGradient = [
    Color(0xFFF59E0B),
    Color(0xFFD97706),
  ];

  // Card shadow
  static const Color shadow = Color(0x1A1E3A8A);
  static const Color shadowDark = Color(0x40000000);

  // Shimmer
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFF);
  static const Color shimmerBaseDark = Color(0xFF334155);
  static const Color shimmerHighlightDark = Color(0xFF475569);

  // Premium
  static const Color premium = Color(0xFFF59E0B);
  static const Color premiumBg = Color(0xFFFFFBEB);
}
