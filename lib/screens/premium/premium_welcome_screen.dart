import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import 'premium_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Frame "Bienvenue Premium" (/premium/welcome) — dark navy success screen.
class PremiumWelcomeScreen extends StatelessWidget {
  const PremiumWelcomeScreen({super.key});

  static const _benefits = [
    'Highlights illimités',
    'Profil prioritaire',
    'Statistiques détaillées',
    'Assistance prioritaire',
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
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
                    const PaymentHeader(
                        title: 'Bienvenue Premium', dark: true),
                    const SizedBox(height: AppDimens.xl),
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.navy700,
                      backgroundImage: auth.currentUser?.avatarUrl != null
                          ? NetworkImage(auth.currentUser!.avatarUrl!)
                          : null,
                      child: auth.currentUser?.avatarUrl == null
                          ? const Icon(LucideIcons.user,
                              color: AppColors.darkTextMuted, size: 44)
                          : null,
                    ),
                    const SizedBox(height: AppDimens.lg),
                    const StatusPill(
                        label: 'PREMIUM',
                        bg: AppColors.premiumBg,
                        fg: AppColors.goldDark),
                    const SizedBox(height: AppDimens.section),
                    Text('Bienvenue dans SPORA Premium',
                        style:
                            AppTextStyles.display(color: AppColors.textLight)),
                    const SizedBox(height: AppDimens.md),
                    Text(
                      'Votre abonnement a été confirmé par le prestataire.',
                      style: AppTextStyles.bodyLarge(
                          color: AppColors.darkTextSecondary),
                    ),
                    const SizedBox(height: AppDimens.section),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimens.section),
                      decoration: BoxDecoration(
                        color: AppColors.navy800,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusCard),
                        border:
                            const Border.fromBorderSide(
                                BorderSide(color: AppColors.darkBorder)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Votre talent, sans limite',
                              style: AppTextStyles.h3(
                                  color: AppColors.textLight)),
                          const SizedBox(height: AppDimens.lg),
                          ..._benefits.map((b) => Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppDimens.md),
                                child: Row(
                                  children: [
                                    const Icon(LucideIcons.check,
                                        color: AppColors.gold, size: 20),
                                    const SizedBox(width: AppDimens.sm),
                                    Text(b,
                                        style: AppTextStyles.bodyLarge(
                                            color: AppColors.textLight)),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimens.section),
                    Text(
                      'Votre badge Premium n’est pas une vérification d’identité. Vos nouvelles vidéos seront modérées.',
                      style: AppTextStyles.caption(
                          color: AppColors.darkTextSecondary),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppDimens.screenMargin, 0,
                  AppDimens.screenMargin, AppDimens.md),
              child: GoldButton(
                label: 'Ajouter un highlight',
                onPressed: () => context.go('/home'),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}
