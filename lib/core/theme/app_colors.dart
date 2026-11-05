import 'package:flutter/material.dart';

/// SPORA design tokens — aligned with Figma "Foundations / SPORA".
class AppColors {
  // Brand
  static const Color primary = Color(0xFF2563EB);        // Primary 500
  static const Color primaryPressed = Color(0xFF1D4ED8); // Primary 600
  static const Color primaryTint = Color(0xFFDBEAFE);    // Primary 100
  static const Color indigo = Color(0xFF6366F1);         // Action gradient end

  // Navy
  static const Color navy900 = Color(0xFF061426);
  static const Color navy800 = Color(0xFF0B1B3A);
  static const Color navy700 = Color(0xFF12294F);

  // Role / accent
  static const Color clubGreen = Color(0xFF0F6B45);      // Green 700 — clubs
  static const Color green = Color(0xFF10B981);          // Green 500 / success
  static const Color gold = Color(0xFFFBBF24);           // Gold 400 — Premium & Highlights tags only
  static const Color goldDark = Color(0xFFD97706);       // Gold 600

  // Light surfaces
  static const Color appBg = Color(0xFFF5F7FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFFEEF2F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  // Light text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textLight = Color(0xFFFFFFFF);

  // Dark mode (per Foundations spec — borders over shadows, 4% photo veil)
  static const Color darkApp = Color(0xFF061426);
  static const Color darkSurface = Color(0xFF0F2038);
  static const Color darkRaised = Color(0xFF162B49);
  static const Color darkMuted = Color(0xFF12263F);
  static const Color darkBorder = Color(0xFF1E3354);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextMuted = Color(0xFF94A3B8);
  static const Color darkDivider = Color(0xFF12263F);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color error = danger;
  static const Color info = Color(0xFF2563EB);
  static const Color errorText = Color(0xFFB91C1C);

  // Opportunity categories
  static const Color catRecrutement = Color(0xFF2563EB);
  static const Color catDetection = Color(0xFF10B981);
  static const Color catEssais = Color(0xFFF97316);
  static const Color catAcademies = Color(0xFF8B5CF6);
  static const Color catTournois = Color(0xFFEAB308);

  // Premium
  static const Color premium = gold;
  static const Color premiumBg = Color(0xFFFFF5D6);

  // Gradients
  static const List<Color> primaryGradient = [primary, indigo];
  static const List<Color> heroGradient = [surface, appBg];
  static const List<Color> heroGradientDark = [darkApp, darkSurface];
  static const List<Color> goldGradient = [gold, goldDark];

  // Shadows / shimmer
  static const Color shadow = Color(0x0F061426);
  static const Color shadowDark = Color(0x40000000);
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFFAFCFF);
  static const Color shimmerBaseDark = Color(0xFF1E3354);
  static const Color shimmerHighlightDark = Color(0xFF2E4468);

  // Back-compat aliases used by older screens
  static const Color primaryLight = primary;
  static const Color primaryDark = navy800;
  static const Color background = surface;
  static const Color backgroundLight = appBg;
  static const Color backgroundDark = darkApp;
  static const Color backgroundDarkLight = darkSurface;
  static const Color surfaceDark = darkSurface;
  static const Color textPrimaryDark = darkTextPrimary;
  static const Color textSecondaryDark = darkTextMuted;
  static const Color textHintDark = textMuted;
  static const Color borderDark = darkBorder;
  static const Color dividerDark = darkDivider;
  static const Color goldLight = gold;
}
