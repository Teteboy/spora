import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'premium_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Frames "Annuler l'abonnement" (sheet) + "Abonnement résilié"
/// (/premium/cancel).
class CancelSubscriptionScreen extends StatefulWidget {
  const CancelSubscriptionScreen({super.key});

  @override
  State<CancelSubscriptionScreen> createState() =>
      _CancelSubscriptionScreenState();
}

class _CancelSubscriptionScreenState
    extends State<CancelSubscriptionScreen> {
  bool _cancelled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _cancelled ? AppColors.appBg : AppColors.navy900,
      body: SafeArea(
        child: _cancelled ? _buildCancelled() : _buildConfirm(),
      ),
    );
  }

  /// Sheet on dark backdrop (radius 28).
  Widget _buildConfirm() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.screenMargin),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimens.section),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.circular(AppDimens.radiusSheet),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Annuler l’abonnement ?',
                  style: AppTextStyles.display()),
              const SizedBox(height: AppDimens.lg),
              Text(
                'Le renouvellement automatique sera désactivé. Vous garderez votre accès Premium jusqu’à la fin de la période déjà payée, selon la date confirmée par le prestataire. Aucun nouveau prélèvement ne sera effectué.',
                style:
                    AppTextStyles.bodyLarge(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimens.section),
              GradientButton(
                label: 'Garder mon abonnement',
                onPressed: () => context.pop(),
              ),
              const SizedBox(height: AppDimens.md),
              OutlineActionButton(
                label: 'Confirmer l’annulation',
                onPressed: () => setState(() => _cancelled = true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Frame "Abonnement résilié".
  Widget _buildCancelled() {
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
                  title: 'Abonnement résilié',
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
                const SizedBox(height: AppDimens.sm),
                Text('En revue · Maquette statique · Données fictives',
                    style: AppTextStyles.caption()),
                const SizedBox(height: AppDimens.lg),
                const StatusPill(
                    label: 'Renouvellement désactivé',
                    bg: Color(0xFFD1FAE5),
                    fg: Color(0xFF047857)),
                const SizedBox(height: AppDimens.lg),
                Text('Votre abonnement est résilié.',
                    style: AppTextStyles.display()),
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
                      Text('Premium reste actif',
                          style: AppTextStyles.h3()),
                      const SizedBox(height: AppDimens.md),
                      Text('Jusqu’au 12 sept. 2027',
                          style: AppTextStyles.display()),
                      const SizedBox(height: AppDimens.lg),
                      Text(
                        'Vous conservez vos avantages jusqu’à la fin de la période déjà réglée. Aucun nouveau prélèvement de renouvellement ne sera demandé.',
                        style: AppTextStyles.bodyLarge(
                            color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppDimens.lg),
                      Text('Annuel · Prix officiel : 49 000 FCFA',
                          style: AppTextStyles.caption()),
                    ],
                  ),
                ),
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
                            Text('Après la fin de période',
                                style: AppTextStyles.h3(
                                    color: AppColors.primary)),
                            const SizedBox(height: AppDimens.xs),
                            Text(
                              'Votre compte redevient gratuit. Les highlights supplémentaires sont masqués, pas supprimés.',
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
                GradientButton(
                  label: 'Revenir à mon abonnement',
                  onPressed: () => context.pop(),
                ),
                const SizedBox(height: AppDimens.md),
                OutlineActionButton(
                  label: 'Consulter mes paiements',
                  onPressed: () => context
                      .pushReplacement('/premium/subscription'),
                ),
                const SizedBox(height: AppDimens.section),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
