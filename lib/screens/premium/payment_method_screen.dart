import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'premium_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Frame "Moyen de paiement" — payment method selection step of /premium.
class PaymentMethodScreen extends StatefulWidget {
  final PremiumPlan plan;
  const PaymentMethodScreen({super.key, this.plan = const PremiumPlan()});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

enum _Method { orange, mtn, card }

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  _Method _method = _Method.orange;

  void _continue() {
    switch (_method) {
      case _Method.card:
        context.push('/premium/card', extra: widget.plan);
        break;
      case _Method.orange:
        context.push('/premium/momo',
            extra: {'plan': widget.plan, 'operator': 'Orange Money'});
        break;
      case _Method.mtn:
        context.push('/premium/momo',
            extra: {'plan': widget.plan, 'operator': 'MTN Mobile Money'});
        break;
    }
  }

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
                    const PaymentHeader(title: 'Moyen de paiement'),
                    const SizedBox(height: AppDimens.md),
                    Text('Comment souhaitez-vous payer ?',
                        style: AppTextStyles.display()),
                    const SizedBox(height: AppDimens.section),
                    _MethodTile(
                      icon: LucideIcons.smartphone,
                      label: 'Orange Money',
                      selected: _method == _Method.orange,
                      onTap: () => setState(() => _method = _Method.orange),
                    ),
                    const SizedBox(height: AppDimens.md),
                    _MethodTile(
                      icon: LucideIcons.smartphone,
                      label: 'MTN Mobile Money',
                      selected: _method == _Method.mtn,
                      onTap: () => setState(() => _method = _Method.mtn),
                    ),
                    const SizedBox(height: AppDimens.md),
                    _MethodTile(
                      icon: LucideIcons.creditCard,
                      label: 'Carte bancaire',
                      darkIcon: true,
                      selected: _method == _Method.card,
                      onTap: () => setState(() => _method = _Method.card),
                    ),
                    const SizedBox(height: AppDimens.section),
                    RecapCard(plan: widget.plan),
                    const SizedBox(height: AppDimens.section),
                    const InfoBanner(
                      title: 'Paiement sécurisé',
                      body:
                          'Les opérateurs confirment votre transaction. SPORA ne demande jamais votre code PIN.',
                    ),
                    const SizedBox(height: AppDimens.section),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppDimens.screenMargin, 0,
                  AppDimens.screenMargin, AppDimens.md),
              child: GradientButton(label: 'Continuer', onPressed: _continue),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool darkIcon;
  final VoidCallback onTap;

  const _MethodTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.darkIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: darkIcon ? AppColors.navy900 : AppColors.muted,
                borderRadius: BorderRadius.circular(AppDimens.radiusInput),
              ),
              child: Icon(icon,
                  color: darkIcon ? AppColors.textLight : AppColors.primary,
                  size: 24),
            ),
            const SizedBox(width: AppDimens.lg),
            Expanded(child: Text(label, style: AppTextStyles.h3())),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : AppColors.surface,
                border: Border.all(
                  color:
                      selected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(LucideIcons.circle,
                      color: AppColors.surface, size: 10)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
