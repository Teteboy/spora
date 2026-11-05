import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shared building blocks for the Premium / payment flow
/// (design frames 08-premium — light screens on AppColors.appBg).
class PremiumPlan {
  final bool yearly;
  const PremiumPlan({this.yearly = true});

  String get label => yearly ? 'Annuel' : 'Mensuel';
  String get price => yearly ? '49 000 FCFA' : '4 900 FCFA';
  String get period => yearly ? '/ an' : '/ mois';
  String get recapLine => 'SPORA Premium · $label';
}

/// Top bar: back arrow (44×44) + bold title, like "Moyen de paiement".
class PaymentHeader extends StatelessWidget {
  final String title;
  final bool dark;
  final Widget? trailing;
  const PaymentHeader({
    super.key,
    required this.title,
    this.dark = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final color = dark ? AppColors.textLight : AppColors.textPrimary;
    return SizedBox(
      height: AppDimens.topBar,
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
            borderRadius: BorderRadius.circular(AppDimens.radiusInput),
            child: Container(
              width: AppDimens.minTouch,
              height: AppDimens.minTouch,
              decoration: BoxDecoration(
                color: dark ? AppColors.darkSurface : AppColors.surface,
                borderRadius:
                    BorderRadius.circular(AppDimens.radiusInput),
                border: Border.all(
                    color: dark ? AppColors.darkBorder : AppColors.border),
              ),
              child: Icon(LucideIcons.arrowLeft, color: color, size: 22),
            ),
          ),
          const SizedBox(width: AppDimens.sm),
          Expanded(
            child: Text(title, style: AppTextStyles.h1(color: color)),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// "Récapitulatif" card: plan line, taxes, total, disclaimer.
class RecapCard extends StatelessWidget {
  final PremiumPlan plan;
  const RecapCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Récapitulatif', style: AppTextStyles.h2()),
          const SizedBox(height: AppDimens.lg),
          Row(
            children: [
              const Icon(LucideIcons.crown,
                  color: AppColors.primary, size: 28),
              const SizedBox(width: AppDimens.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.recapLine, style: AppTextStyles.bodyStrong()),
                  Text('${plan.price} ${plan.period}',
                      style: AppTextStyles.body()),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          Text('Taxes : à confirmer', style: AppTextStyles.bodyLarge()),
          const SizedBox(height: AppDimens.sm),
          Text('Total : ${plan.price}', style: AppTextStyles.h1()),
          const SizedBox(height: AppDimens.md),
          Text(
            'Prix indicatifs non définis · Aucun débit réel',
            style: AppTextStyles.body(),
          ),
        ],
      ),
    );
  }
}

/// Blue info banner (primaryTint background, primary text).
class InfoBanner extends StatelessWidget {
  final String title;
  final String body;
  final bool isWarning;
  const InfoBanner({
    super.key,
    required this.title,
    required this.body,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isWarning
        ? AppColors.danger.withValues(alpha: 0.08)
        : AppColors.primaryTint;
    final fg = isWarning ? AppColors.errorText : AppColors.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h3(color: fg)),
          const SizedBox(height: AppDimens.xs),
          Text(body, style: AppTextStyles.bodyStrong(color: fg)),
        ],
      ),
    );
  }
}

/// Full-width gradient CTA (primary → indigo), radius 16, height ~56.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const GradientButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.primaryGradient),
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusCard),
            ),
          ),
          child: Text(label, style: AppTextStyles.button()),
        ),
      ),
    );
  }
}

/// Outlined secondary button (white, border).
class OutlineActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const OutlineActionButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          ),
        ),
        child: Text(label, style: AppTextStyles.button(color: AppColors.textPrimary)),
      ),
    );
  }
}

/// Gold CTA used on Premium dark screens.
class GoldButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  const GoldButton({super.key, required this.label, this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.navy900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: AppDimens.sm),
            ],
            Text(label, style: AppTextStyles.button(color: AppColors.navy900)),
          ],
        ),
      ),
    );
  }
}

/// Small status pill.
class StatusPill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const StatusPill({super.key, required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Text(label, style: AppTextStyles.bodyStrong(color: fg)),
    );
  }
}
