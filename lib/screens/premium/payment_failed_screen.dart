import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'premium_widgets.dart';
import 'payment_method_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Frame "Paiement échoué".
class PaymentFailedScreen extends StatelessWidget {
  final PremiumPlan plan;
  final String method;
  const PaymentFailedScreen({
    super.key,
    this.plan = const PremiumPlan(),
    this.method = 'Orange Money',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
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
                    const PaymentHeader(title: 'Paiement échoué'),
                    const SizedBox(height: AppDimens.xl),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.danger, width: 2),
                      ),
                      child: const Icon(LucideIcons.alertCircle,
                          color: AppColors.danger, size: 36),
                    ),
                    const SizedBox(height: AppDimens.section),
                    Text('Le paiement n’a pas abouti',
                        style: AppTextStyles.display()),
                    const SizedBox(height: AppDimens.md),
                    Text(
                      'L’opérateur n’a pas confirmé la transaction. Votre abonnement n’a pas été activé.',
                      style: AppTextStyles.bodyLarge(
                          color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppDimens.section),
                    RecapCard(plan: plan),
                    const SizedBox(height: AppDimens.section),
                    const InfoBanner(
                      isWarning: true,
                      title: 'Avant de recommencer',
                      body:
                          'Vérifiez le statut auprès de votre opérateur pour éviter un double paiement.',
                    ),
                    const SizedBox(height: AppDimens.section),
                    OutlineActionButton(
                      label: 'Changer de moyen de paiement',
                      onPressed: () =>
                          Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) =>
                              PaymentMethodScreen(plan: plan),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimens.md),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppDimens.screenMargin, 0,
                  AppDimens.screenMargin, AppDimens.md),
              child: GradientButton(
                label: 'Réessayer',
                onPressed: () {
                  if (method == 'Carte bancaire') {
                    context.pushReplacement('/premium/card', extra: plan);
                  } else {
                    context.pushReplacement('/premium/momo',
                        extra: {'plan': plan, 'operator': method});
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
