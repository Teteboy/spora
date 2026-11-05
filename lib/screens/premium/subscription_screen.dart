import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'premium_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Frames "Mon abonnement" + "Premium a expiré" (/premium/subscription).
/// Pass `expired: true` (or go_router extra {'expired': true}) to show
/// the expired state.
class SubscriptionScreen extends StatelessWidget {
  final bool expired;
  const SubscriptionScreen({super.key, this.expired = false});

  bool _isExpired(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    if (extra is Map && extra['expired'] == true) return true;
    return expired;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: _isExpired(context)
            ? const _ExpiredView()
            : const _ActiveView(),
      ),
    );
  }
}

class _ActiveView extends StatelessWidget {
  const _ActiveView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding:
          const EdgeInsets.symmetric(horizontal: AppDimens.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PaymentHeader(title: 'Mon abonnement'),
          const SizedBox(height: AppDimens.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimens.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.circular(AppDimens.radiusCard),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StatusPill(
                    label: 'Premium actif',
                    bg: AppColors.premiumBg,
                    fg: AppColors.goldDark),
                const SizedBox(height: AppDimens.lg),
                Text('Formule annuelle', style: AppTextStyles.display()),
                const SizedBox(height: AppDimens.sm),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: '49 000 FCFA ',
                        style: AppTextStyles.h1()),
                    TextSpan(
                        text: '/ an',
                        style: AppTextStyles.h1(
                            color: AppColors.textPrimary)),
                  ]),
                ),
                const SizedBox(height: AppDimens.lg),
                Text(
                  'Prochain renouvellement : selon la confirmation du prestataire',
                  style: AppTextStyles.bodyLarge(
                      color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppDimens.sm),
                Text(
                  'Moyen de paiement : Orange Money · ••42',
                  style: AppTextStyles.body(),
                ),
                const SizedBox(height: AppDimens.lg),
                OutlineActionButton(
                    label: 'Changer de formule', onPressed: () {}),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.section),
          Text('Historique des paiements', style: AppTextStyles.h2()),
          const SizedBox(height: AppDimens.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimens.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.circular(AppDimens.radiusCard),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(LucideIcons.receipt,
                        color: AppColors.primary, size: 28),
                    const SizedBox(width: AppDimens.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text('Abonnement annuel',
                              style: AppTextStyles.bodyStrong()),
                          const SizedBox(height: AppDimens.xs),
                          Text(
                            '16 octobre 2026 · 49 000 FCFA · Confirmé',
                            style: AppTextStyles.body(),
                          ),
                          const SizedBox(height: AppDimens.xs),
                          Text(
                            'Orange Money · Réf. SPORA-2026-1042',
                            style: AppTextStyles.caption(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.md),
                Text('Historique fictif de démonstration',
                    style: AppTextStyles.caption()),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.section),
          OutlineActionButton(
            label: 'Annuler l’abonnement',
            onPressed: () => context.push('/premium/cancel'),
          ),
          const SizedBox(height: AppDimens.md),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: TextButton(
              onPressed: () => context.push('/help'),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusCard),
                ),
              ),
              child: Text('Aide au paiement',
                  style: AppTextStyles.button(color: AppColors.primary)),
            ),
          ),
          const SizedBox(height: AppDimens.section),
        ],
      ),
    );
  }
}

/// Frame "Premium a expiré" — downgrade keeps data, resubscribe CTA.
class _ExpiredView extends StatelessWidget {
  const _ExpiredView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.screenMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PaymentHeader(
                  title: 'Premium a expiré',
                  trailing: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: AppDimens.minTouch,
                      height: AppDimens.minTouch,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(
                            AppDimens.radiusInput),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(LucideIcons.moreHorizontal,
                          size: 22, color: AppColors.textPrimary),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.md),
                Text('Compte gratuit',
                    style: AppTextStyles.bodyStrong(
                        color: AppColors.textSecondary)),
                const SizedBox(height: AppDimens.sm),
                Text('Vos vidéos sont conservées.',
                    style: AppTextStyles.display()),
                const SizedBox(height: AppDimens.section),
                Container(
                  padding: const EdgeInsets.all(AppDimens.lg),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTint,
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusCard),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(LucideIcons.info,
                          color: AppColors.primary, size: 24),
                      const SizedBox(width: AppDimens.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text('Votre Premium a expiré le 15 octobre',
                                style: AppTextStyles.bodyStrong(
                                    color: AppColors.primary)),
                            const SizedBox(height: AppDimens.xs),
                            Text(
                              'Un highlight reste visible avec le compte gratuit. Les vidéos supplémentaires sont masquées, jamais supprimées.',
                              style: AppTextStyles.body(
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.section),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimens.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusCard),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mes highlights · 12',
                          style: AppTextStyles.h2()),
                      const SizedBox(height: AppDimens.md),
                      Container(
                        height: 140,
                        decoration: BoxDecoration(
                          color: AppColors.navy700,
                          borderRadius: BorderRadius.circular(
                              AppDimens.radiusCard),
                        ),
                        child: const Center(
                          child: Icon(LucideIcons.goal,
                              color: AppColors.darkTextMuted,
                              size: 48),
                        ),
                      ),
                      const SizedBox(height: AppDimens.md),
                      Text('Finition en une touche',
                          style: AppTextStyles.h3()),
                      const SizedBox(height: AppDimens.sm),
                      const StatusPill(
                          label: 'En ligne · Highlight gratuit',
                          bg: Color(0xFFD1FAE5),
                          fg: Color(0xFF047857)),
                      const SizedBox(height: AppDimens.md),
                      const _LockedRow(
                          text:
                              'Frappe extérieure · 00:42\nMasqué après expiration'),
                      const SizedBox(height: AppDimens.sm),
                      const _LockedRow(
                          text:
                              'Passe décisive · 00:38\nMasqué après expiration'),
                      const SizedBox(height: AppDimens.md),
                      Text(
                        '9 autres vidéos masquées · Restaurées au renouvellement.',
                        style: AppTextStyles.caption(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.section),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppDimens.screenMargin, 0,
              AppDimens.screenMargin, AppDimens.md),
          child: Column(
            children: [
              GoldButton(
                label: 'Renouveler Premium · 49 000 FCFA',
                onPressed: () =>
                    context.pushReplacement('/premium'),
              ),
              const SizedBox(height: AppDimens.md),
              OutlineActionButton(
                label: 'Conserver le compte gratuit',
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LockedRow extends StatelessWidget {
  final String text;
  const _LockedRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(LucideIcons.lock,
            color: AppColors.primary, size: 20),
        const SizedBox(width: AppDimens.sm),
        Expanded(child: Text(text, style: AppTextStyles.body())),
      ],
    );
  }
}
