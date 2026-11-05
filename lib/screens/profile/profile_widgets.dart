import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shared building blocks for the Profile screens (tokens only).
class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  const ProfileAppBar({super.key, required this.title, this.onBack, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(AppDimens.topBar);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.appBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      leadingWidth: AppDimens.minTouch + AppDimens.screenMargin,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppDimens.screenMargin),
        child: GestureDetector(
          onTap: onBack ?? () => Navigator.of(context).maybePop(),
          child: Container(
            width: AppDimens.minTouch,
            height: AppDimens.minTouch,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusInput),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(LucideIcons.arrowLeft,
                size: 22, color: AppColors.textPrimary),
          ),
        ),
      ),
      title: Text(title, style: AppTextStyles.h2()),
      actions: actions,
    );
  }
}

/// Pill used for tab-like filters (radius 999).
class PillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const PillChip({super.key, required this.label, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryTint : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyStrong(
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Small status pill (Disponible, Premium, Vérifié…).
class BadgePill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color bg;
  final Color fg;
  const BadgePill({super.key, required this.label, this.icon, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppDimens.radiusPill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
          ],
          Text(label, style: AppTextStyles.caption(color: fg).copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// 3-column stat cell (value over label).
class StatCell extends StatelessWidget {
  final String value;
  final String label;
  const StatCell({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTextStyles.h2()),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption()),
      ],
    );
  }
}

/// White section card, radius 16, elev-1.
class ProfileCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const ProfileCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.elev1,
      ),
      child: child,
    );
  }
}

/// Blue informational banner.
class InfoBanner extends StatelessWidget {
  final String title;
  final String? body;
  final IconData icon;
  const InfoBanner({super.key, required this.title, this.body, this.icon = LucideIcons.lock});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyStrong(color: AppColors.primary)),
                if (body != null) ...[
                  const SizedBox(height: 4),
                  Text(body!, style: AppTextStyles.body(color: AppColors.primary)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Primary filled button (blue → indigo gradient, pill-ish 12 radius like frames).
class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  const PrimaryButton({super.key, required this.label, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.primaryGradient),
          borderRadius: BorderRadius.circular(AppDimens.radiusInput),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
            ],
            Text(label, style: AppTextStyles.button()),
          ],
        ),
      ),
    );
  }
}

/// Outlined secondary button.
class OutlineButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? fg;
  const OutlineButton({super.key, required this.label, this.icon, this.onTap, this.fg});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusInput),
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: fg ?? AppColors.textPrimary, size: 18),
              const SizedBox(width: 8),
            ],
            Text(label, style: AppTextStyles.button(color: fg ?? AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
