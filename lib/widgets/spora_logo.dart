import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// SPORA brand mark. The bundled asset already contains the wordmark;
/// set [showText] to false for icon-only usage.
class SporaLogo extends StatelessWidget {
  final double height;
  final bool showText;
  final bool showIcon;
  final bool light;

  /// Flat brand mark: transparent-background ball + wordmark.
  /// When true, [height] is the wordmark font size and the ball is scaled to match.
  final bool flat;

  const SporaLogo({
    super.key,
    this.height = 40,
    this.showText = true,
    this.showIcon = true,
    this.light = false,
    this.flat = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon)
          flat
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(height * 0.32),
                  child: Image.asset(
                    'assets/images/spora_brand_icon.png',
                    height: height * 1.5,
                    width: height * 1.5,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildFallbackLogo(),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(height * 0.22),
                  child: Image.asset(
                    'assets/images/spora_icon.png',
                    height: height,
                    width: height,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildFallbackLogo(),
                  ),
                ),
        if (showText) ...[
          if (showIcon) const SizedBox(width: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'SP',
                  style: TextStyle(
                    fontFamily: 'TikTok Sans',
                    fontSize: showIcon && !flat ? height * 0.55 : height,
                    fontWeight: FontWeight.w800,
                    color: light ? Colors.white : const Color(0xFF0B1B3A),
                  ),
                ),
                TextSpan(
                  text: 'O',
                  style: TextStyle(
                    fontFamily: 'TikTok Sans',
                    fontSize: showIcon && !flat ? height * 0.55 : height,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
                TextSpan(
                  text: 'RA',
                  style: TextStyle(
                    fontFamily: 'TikTok Sans',
                    fontSize: showIcon && !flat ? height * 0.55 : height,
                    fontWeight: FontWeight.w800,
                    color: light ? Colors.white : const Color(0xFF0B1B3A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFallbackLogo() {
    return Container(
      height: height,
      width: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1B3A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(height * 0.22),
      ),
      child: Icon(
        LucideIcons.goal,
        color: Colors.white,
        size: height * 0.6,
      ),
    );
  }
}
