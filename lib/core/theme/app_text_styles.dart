import 'package:flutter/material.dart';
import 'app_colors.dart';

/// TikTok Sans type scale (replaces the Poppins spec from Figma "Foundations / SPORA").
class AppTextStyles {
  static const String family = 'TikTok Sans';

  static TextStyle display({Color? color}) => TextStyle(
      fontFamily: family, fontSize: 28, height: 34 / 28,
      fontWeight: FontWeight.w800, letterSpacing: -0.5,
      color: color ?? AppColors.textPrimary);

  static TextStyle h1({Color? color}) => TextStyle(
      fontFamily: family, fontSize: 22, height: 28 / 22,
      fontWeight: FontWeight.w700, color: color ?? AppColors.textPrimary);

  static TextStyle h2({Color? color}) => TextStyle(
      fontFamily: family, fontSize: 18, height: 24 / 18,
      fontWeight: FontWeight.w600, color: color ?? AppColors.textPrimary);

  static TextStyle h3({Color? color}) => TextStyle(
      fontFamily: family, fontSize: 16, height: 22 / 16,
      fontWeight: FontWeight.w600, color: color ?? AppColors.textPrimary);

  static TextStyle bodyLarge({Color? color}) => TextStyle(
      fontFamily: family, fontSize: 16, height: 24 / 16,
      fontWeight: FontWeight.w400, color: color ?? AppColors.textPrimary);

  static TextStyle body({Color? color}) => TextStyle(
      fontFamily: family, fontSize: 14, height: 20 / 14,
      fontWeight: FontWeight.w400, color: color ?? AppColors.textSecondary);

  static TextStyle bodyStrong({Color? color}) => TextStyle(
      fontFamily: family, fontSize: 14, height: 20 / 14,
      fontWeight: FontWeight.w600, color: color ?? AppColors.textPrimary);

  static TextStyle caption({Color? color}) => TextStyle(
      fontFamily: family, fontSize: 12, height: 16 / 12,
      fontWeight: FontWeight.w400, color: color ?? AppColors.textMuted);

  static TextStyle micro({Color? color}) => TextStyle(
      fontFamily: family, fontSize: 11, height: 14 / 11,
      fontWeight: FontWeight.w400, color: color ?? AppColors.textMuted);

  static TextStyle eyebrow({Color? color}) => TextStyle(
      fontFamily: family, fontSize: 11, height: 14 / 11,
      fontWeight: FontWeight.w600, letterSpacing: 1.5,
      color: color ?? AppColors.textMuted);

  static TextStyle button({Color? color}) => TextStyle(
      fontFamily: family, fontSize: 15, height: 20 / 15,
      fontWeight: FontWeight.w600, color: color ?? Colors.white);

  static TextStyle statNumber({Color? color}) => TextStyle(
      fontFamily: family, fontSize: 20, height: 24 / 20,
      fontWeight: FontWeight.w600,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: color ?? AppColors.textPrimary);
}

/// Spacing scale, radii and layout metrics from Figma Foundations.
class AppDimens {
  static const double xxs = 2, xs = 4, sm = 8, md = 12;
  static const double lg = 16, xl = 20, section = 24;
  static const double xxl = 32, xxxl = 40, huge = 48, max = 64;

  static const double screenMargin = lg;
  static const double cardPadding = lg;

  static const double radiusSm = 8;
  static const double radiusInput = 12;
  static const double radiusCard = 16;
  static const double radiusHero = 20;
  static const double radiusSheet = 28;
  static const double radiusPill = 999;

  static const double topBar = 56;
  static const double bottomNav = 80;
  static const double minTouch = 44;
}

/// Elevation tokens (navy-tinted, max one strong shadow per screen).
class AppShadows {
  static const List<BoxShadow> elev1 = [
    BoxShadow(blurRadius: 8, offset: Offset(0, 2), color: Color(0x0F061426)),
  ];
  static const List<BoxShadow> elev2 = [
    BoxShadow(blurRadius: 24, offset: Offset(0, 8), color: Color(0x1A061426)),
  ];
  static const List<BoxShadow> elev3 = [
    BoxShadow(blurRadius: 40, offset: Offset(0, 16), color: Color(0x29061426)),
  ];
  static const List<BoxShadow> glowBrand = [
    BoxShadow(blurRadius: 24, offset: Offset(0, 8), color: Color(0x4D2563EB)),
  ];
}
