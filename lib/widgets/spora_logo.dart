import 'package:flutter/material.dart';

class SporaLogo extends StatelessWidget {
  final double height;
  final bool showText;

  const SporaLogo({
    super.key,
    this.height = 40,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/spora_logo.jpeg',
          height: height,
          width: height,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackLogo(),
        ),
        if (showText) ...[
          const SizedBox(width: 8),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'SP',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                TextSpan(
                  text: 'O',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFF59E0B),
                  ),
                ),
                TextSpan(
                  text: 'RA',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E3A8A),
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
      width: height,
      height: height,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
        ),
      ),
      child: const Icon(Icons.sports_soccer, color: Colors.white),
    );
  }
}
