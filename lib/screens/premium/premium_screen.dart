import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'premium_widgets.dart';
import 'payment_method_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Frame "15 · Compte — SPORA Premium" — dark navy paywall.
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isYearly = true;

  static const _features = [
    (LucideIcons.video, 'Highlights illimités'),
    (LucideIcons.crown, 'Badge Premium'),
    (LucideIcons.trendingUp, 'Profil prioritaire'),
    (LucideIcons.barChart3, 'Statistiques détaillées'),
    (LucideIcons.headphones, 'Assistance prioritaire'),
  ];

  static const _comparison = [
    ('Visibilité', 'Standard', 'Prioritaire'),
    ('Highlights', '1', 'Illimités'),
    ('Badge', '—', 'Premium'),
    ('Statistiques', 'Essentielles', 'Détaillées'),
    ('Messages', 'Standard', 'Prioritaires'),
    ('Candidatures', '3 / mois', 'Illimitées'),
    ('Support', 'Standard', 'Prioritaire'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy900,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.screenMargin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDimens.lg),
                    // Logo + wordmark
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppDimens.radiusCard),
                          ),
                          child: const Center(
                            child: Icon(LucideIcons.crown,
                                color: AppColors.goldDark, size: 30),
                          ),
                        ),
                        const SizedBox(width: AppDimens.md),
                        Text('SPORA PREMIUM',
                            style: AppTextStyles.h1(
                                color: AppColors.textLight)),
                      ],
                    ),
                    const SizedBox(height: AppDimens.xl),
                    Text('Faites-vous repérer plus vite.',
                        style: AppTextStyles.display(
                            color: AppColors.textLight)),
                    const SizedBox(height: AppDimens.md),
                    Text('Plus de visibilité. Plus de possibilités.',
                        style:
                            AppTextStyles.bodyLarge(color: AppColors.darkTextSecondary)),
                    const SizedBox(height: AppDimens.section),
                    // Feature list
                    ..._features.map((f) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppDimens.md),
                          child: Row(
                            children: [
                              Icon(f.$1, color: AppColors.gold, size: 24),
                              const SizedBox(width: AppDimens.md),
                              Text(f.$2,
                                  style: AppTextStyles.h3(
                                      color: AppColors.textLight)),
                            ],
                          ),
                        )),
                    const SizedBox(height: AppDimens.sm),
                    // Free vs Premium comparison
                    Container(
                      padding: const EdgeInsets.all(AppDimens.lg),
                      decoration: BoxDecoration(
                        color: AppColors.navy800,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusCard),
                      ),
                      child: Table(
                        children: [
                          TableRow(children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text('Votre profil',
                                  style: AppTextStyles.bodyStrong(
                                      color: AppColors.darkTextSecondary)),
                            ),
                            Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 12),
                                child: Text('Gratuit',
                                    style: AppTextStyles.body(
                                        color:
                                            AppColors.darkTextSecondary)),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 12),
                                child: Text('Premium',
                                    style: AppTextStyles.bodyStrong(
                                        color: AppColors.gold)),
                              ),
                            ),
                          ]),
                          ..._comparison.map((r) => TableRow(children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6),
                                  child: Text(r.$1,
                                      style: AppTextStyles.body(
                                          color: AppColors
                                              .darkTextSecondary)),
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6),
                                    child: Text(r.$2,
                                        style: AppTextStyles.body(
                                            color: AppColors
                                                .darkTextSecondary)),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6),
                                    child: Text(r.$3,
                                        style: AppTextStyles.bodyStrong(
                                            color: AppColors.gold)),
                                  ),
                                ),
                              ])),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimens.section),
                    // Plan selector
                    _PlanTile(
                      title: 'Mensuel',
                      price: '4 900 FCFA',
                      period: '/ mois',
                      selected: !_isYearly,
                      onTap: () => setState(() => _isYearly = false),
                    ),
                    const SizedBox(height: AppDimens.md),
                    _PlanTile(
                      title: 'Annuel',
                      price: '49 000 FCFA',
                      period: '/ an',
                      badge: 'Économisez 2 mois',
                      selected: _isYearly,
                      onTap: () => setState(() => _isYearly = true),
                    ),
                    const SizedBox(height: AppDimens.section),
                    Text(
                      'Le badge Premium indique l’abonnement. La vérification d’identité est accordée séparément par SPORA.',
                      style: AppTextStyles.caption(
                          color: AppColors.darkTextSecondary),
                    ),
                    const SizedBox(height: AppDimens.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Restaurer les achats',
                            style: AppTextStyles.body(
                                color: AppColors.darkTextSecondary)),
                        const SizedBox(width: AppDimens.xl),
                        Text('Conditions',
                            style: AppTextStyles.body(
                                color: AppColors.darkTextSecondary)),
                      ],
                    ),
                    const SizedBox(height: AppDimens.section),
                  ],
                ),
              ),
            ),
            // Bottom CTA
            Container(
              padding: const EdgeInsets.fromLTRB(
                  AppDimens.screenMargin,
                  AppDimens.md,
                  AppDimens.screenMargin,
                  AppDimens.md),
              decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(color: AppColors.darkBorder)),
              ),
              child: Column(
                children: [
                  GoldButton(
                    label: 'Devenir Premium',
                    icon: LucideIcons.crown,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PaymentMethodScreen(
                          plan: PremiumPlan(yearly: _isYearly),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.md),
                  Text(
                    'Annulable à tout moment · Paiement sécurisé',
                    style: AppTextStyles.caption(
                        color: AppColors.darkTextSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

class _PlanTile extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  const _PlanTile({
    required this.title,
    required this.price,
    required this.period,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppDimens.lg),
        decoration: BoxDecoration(
          color: selected ? AppColors.darkMuted : AppColors.navy800,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.darkBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppColors.gold : Colors.transparent,
                    border: Border.all(
                      color:
                          selected ? AppColors.gold : AppColors.darkTextMuted,
                      width: 2,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style:
                              AppTextStyles.h3(color: AppColors.textLight)),
                      const SizedBox(height: AppDimens.xs),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: price,
                            style: AppTextStyles.h2(
                                color: selected
                                    ? AppColors.gold
                                    : AppColors.textLight),
                          ),
                          TextSpan(
                            text: ' $period',
                            style: AppTextStyles.h3(
                                color: selected
                                    ? AppColors.gold
                                    : AppColors.darkTextSecondary),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (badge != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.14),
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusPill),
                  ),
                  child: Text(badge!,
                      style: AppTextStyles.caption(color: AppColors.gold)
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
