import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/spora_logo.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isYearly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryDark, AppColors.primary, Color(0xFF1D4ED8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMD, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                    const SporaLogo(height: 32),
                    const Spacer(),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMD),
                  child: Column(
                    children: [
                      // Crown icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: AppColors.goldGradient),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.4), blurRadius: 20)],
                        ),
                        child: const Icon(Icons.workspace_premium, color: Colors.white, size: 44),
                      ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                      const SizedBox(height: 16),
                      const Text(
                        'SPORA Premium',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                      ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                      const SizedBox(height: 8),
                      const Text(
                        'Débloquez tout votre potentiel',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.white70),
                      ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                      const SizedBox(height: 24),
                      // Features
                      _FeaturesList().animate().fadeIn(duration: 400.ms, delay: 400.ms),
                      const SizedBox(height: 24),
                      // Billing toggle
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _BillingTab(label: 'Mensuel', isActive: !_isYearly, onTap: () => setState(() => _isYearly = false)),
                            _BillingTab(label: 'Annuel (-30%)', isActive: _isYearly, onTap: () => setState(() => _isYearly = true)),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
                      const SizedBox(height: 24),
                      // Price card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20)],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('XOF ', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                Text(
                                  _isYearly ? '14,000' : '1,990',
                                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 48, fontWeight: FontWeight.w800, color: AppColors.primary),
                                ),
                              ],
                            ),
                            Text(
                              _isYearly ? '/ an (soit 1,167 XOF/mois)' : '/ mois',
                              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Redirection vers le paiement...')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gold,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text(
                                  'Passer en Premium',
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Paiement sécurisé • Mobile Money • Carte bancaire',
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 600.ms).slideY(begin: 0.1, duration: 400.ms, delay: 600.ms),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturesList extends StatelessWidget {
  final features = const [
    (icon: Icons.videocam, title: 'Highlights illimités', subtitle: 'Uploadez autant de vidéos que vous voulez'),
    (icon: Icons.trending_up, title: 'Mise en avant', subtitle: 'Apparaissez en tête des résultats de recherche'),
    (icon: Icons.verified, title: 'Badge Premium', subtitle: 'Profil certifié visible par tous les agents'),
    (icon: Icons.bar_chart, title: 'Analytiques avancées', subtitle: 'Suivez vos vues, likes et intérêt des agents'),
    (icon: Icons.message, title: 'Messagerie prioritaire', subtitle: 'Répondez en premier aux recruteurs'),
  ];

  const _FeaturesList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: features.map((f) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(f.icon, color: AppColors.gold, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f.title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text(f.subtitle, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.white60)),
                ],
              ),
            ),
            const Icon(Icons.check_circle, color: AppColors.gold, size: 20),
          ],
        ),
      )).toList(),
    );
  }
}

class _BillingTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BillingTab({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.primary : Colors.white70,
          ),
        ),
      ),
    );
  }
}

