// SPORA design tokens — extracted from Figma "Foundations / SPORA"
// https://www.figma.com/design/Zbzi4s0Sbn5rKEe4ldCezV/Untitled
import 'package:flutter/material.dart';

abstract class SporaColors {
  // Brand
  static const primary = Color(0xFF2563EB);
  static const primaryPressed = Color(0xFF1D4ED8);
  static const primaryTint = Color(0xFFDBEAFE);
  static const indigo = Color(0xFF6366F1); // action gradient: primary → indigo
  static const navy900 = Color(0xFF061426);
  static const navy800 = Color(0xFF0B1B3A);
  static const navy700 = Color(0xFF12294F);
  static const clubGreen = Color(0xFF0F6B45);
  static const green = Color(0xFF10B981);
  static const gold = Color(0xFFFBBF24); // Premium & Highlights tags only
  static const goldDark = Color(0xFFD97706);

  // Light surfaces & text
  static const appBg = Color(0xFFF5F7FC);
  static const surface = Color(0xFFFFFFFF);
  static const muted = Color(0xFFEEF2F9);
  static const border = Color(0xFFE2E8F0);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const textMuted = Color(0xFF64748B);

  // Semantic
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const info = Color(0xFF2563EB);
  static const errorText = Color(0xFFB91C1C);

  // Opportunity categories
  static const catRecrutement = Color(0xFF2563EB);
  static const catDetection = Color(0xFF10B981);
  static const catEssais = Color(0xFFF97316);
  static const catAcademies = Color(0xFF8B5CF6);
  static const catTournois = Color(0xFFEAB308);

  // Dark mode (to be bound — no manual recoloring)
  static const darkApp = Color(0xFF061426);
  static const darkSurface = Color(0xFF0F2038);
  static const darkRaised = Color(0xFF162B49);
  static const darkMuted = Color(0xFF12263F);
  static const darkBorder = Color(0xFF1E3354);
  static const darkTextPrimary = Color(0xFFF1F5F9);
  static const darkTextSecondary = Color(0xFFCBD5E1);
  static const darkTextMuted = Color(0xFF94A3B8);
}

abstract class SporaText {
  static const family = 'Poppins';
  static const display = TextStyle(fontFamily: family, fontSize: 28, height: 34 / 28, fontWeight: FontWeight.w800, letterSpacing: -0.5);
  static const h1 = TextStyle(fontFamily: family, fontSize: 22, height: 28 / 22, fontWeight: FontWeight.w700);
  static const h2 = TextStyle(fontFamily: family, fontSize: 18, height: 24 / 18, fontWeight: FontWeight.w600);
  static const h3 = TextStyle(fontFamily: family, fontSize: 16, height: 22 / 16, fontWeight: FontWeight.w600);
  static const bodyLarge = TextStyle(fontFamily: family, fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400);
  static const body = TextStyle(fontFamily: family, fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400);
  static const bodyStrong = TextStyle(fontFamily: family, fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600);
  static const caption = TextStyle(fontFamily: family, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w400);
  static const micro = TextStyle(fontFamily: family, fontSize: 11, height: 14 / 11, fontWeight: FontWeight.w400);
  static const eyebrow = TextStyle(fontFamily: family, fontSize: 11, height: 14 / 11, fontWeight: FontWeight.w600, letterSpacing: 1.5);
  static const button = TextStyle(fontFamily: family, fontSize: 15, height: 20 / 15, fontWeight: FontWeight.w600);
  static const statNumber = TextStyle(fontFamily: family, fontSize: 20, height: 24 / 20, fontWeight: FontWeight.w600, fontFeatures: [FontFeature.tabularFigures()]);
}

abstract class SporaSpacing {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0; // screen margin, grid gutter
  static const xl = 20.0;
  static const section = 24.0;
  static const xxl = 32.0;
  static const xxxl = 40.0;
  static const huge = 48.0;
  static const max = 64.0;
}

abstract class SporaRadii {
  static const sm = 8.0;
  static const input = 12.0;
  static const card = 16.0;
  static const hero = 20.0;
  static const sheet = 28.0;
  static const pill = 999.0;
}

abstract class SporaLayout {
  static const statusBar = 47.0;
  static const topBar = 56.0;
  static const bottomNav = 80.0;
  static const minTouchTarget = 44.0;
}

abstract class SporaShadows {
  static const elev1 = [BoxShadow(blurRadius: 8, offset: Offset(0, 2), color: Color(0x0F061426))];
  static const elev2 = [BoxShadow(blurRadius: 24, offset: Offset(0, 8), color: Color(0x1A061426))];
  static const elev3 = [BoxShadow(blurRadius: 40, offset: Offset(0, 16), color: Color(0x29061426))];
  static const glowBrand = [BoxShadow(blurRadius: 24, offset: Offset(0, 8), color: Color(0x4D2563EB))];
}

abstract class SporaMotion {
  static const fast = Duration(milliseconds: 120);
  static const base = Duration(milliseconds: 200);
  static const slow = Duration(milliseconds: 320);
  static const hero = Duration(milliseconds: 480);
  static const tab = fast;
  static const push = Duration(milliseconds: 280);
  static const sheet = slow;
  static const dialog = base;
  static const standard = Cubic(0.2, 0, 0, 1);
  static const emphasised = Cubic(0.3, 0, 0, 1.2);
}
