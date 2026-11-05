import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Theme-aware palette for the Account & Settings screens (light/dark tokens).
class AccountPalette {
  final bool dark;
  const AccountPalette(this.dark);

  static AccountPalette of(BuildContext context) =>
      AccountPalette(Theme.of(context).brightness == Brightness.dark);

  Color get bg => dark ? AppColors.darkApp : AppColors.appBg;
  Color get surface => dark ? AppColors.darkSurface : AppColors.surface;
  Color get raised => dark ? AppColors.darkRaised : AppColors.surface;
  Color get muted => dark ? AppColors.darkMuted : AppColors.muted;
  Color get border => dark ? AppColors.darkBorder : AppColors.border;
  Color get divider => dark ? AppColors.darkBorder : AppColors.border;
  Color get text => dark ? AppColors.darkTextPrimary : AppColors.textPrimary;
  Color get text2 =>
      dark ? AppColors.darkTextSecondary : AppColors.textSecondary;
  Color get text3 => dark ? AppColors.darkTextMuted : AppColors.textMuted;
  Color get tint =>
      dark ? AppColors.primary.withValues(alpha: 0.18) : AppColors.primaryTint
          .withValues(alpha: 0.6);
  Color get successTint => AppColors.success.withValues(alpha: 0.14);
  Color get dangerTint => AppColors.danger.withValues(alpha: 0.10);
}

/// Pops the current route or falls back to [fallback] when nothing to pop.
void accountBack(BuildContext context, {String fallback = '/profile'}) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallback);
  }
}

/// Standard top bar: back arrow (optionally boxed) + H1 title.
class AccountTopBar extends StatelessWidget {
  final String title;
  final bool boxedBack;
  final VoidCallback? onBack;
  final bool showBack;
  final List<Widget> actions;

  const AccountTopBar({
    super.key,
    required this.title,
    this.boxedBack = false,
    this.onBack,
    this.showBack = true,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    return SizedBox(
      height: AppDimens.topBar + 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenMargin),
        child: Row(
          children: [
            if (showBack) ...[
              Semantics(
                button: true,
                label: 'Retour',
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppDimens.radiusInput),
                  onTap: onBack ?? () => accountBack(context),
                  child: Container(
                    width: AppDimens.minTouch,
                    height: AppDimens.minTouch,
                    decoration: BoxDecoration(
                      color: p.surface,
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusInput),
                      border: Border.all(color: p.border),
                    ),
                    child: Icon(LucideIcons.arrowLeft, color: p.text, size: 22),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.sm),
            ],
            Expanded(
              child: Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h1(color: p.text)),
            ),
            ...actions,
          ],
        ),
      ),
    );
  }
}

/// Scaffold with app-bg, SafeArea, top bar, scrollable body and optional
/// sticky bottom action.
class AccountScaffold extends StatelessWidget {
  final String title;
  final bool boxedBack;
  final VoidCallback? onBack;
  final bool showBack;
  final List<Widget> children;
  final Widget? bottom;
  final List<Widget> actions;

  const AccountScaffold({
    super.key,
    required this.title,
    required this.children,
    this.boxedBack = false,
    this.onBack,
    this.showBack = true,
    this.bottom,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        bottom: bottom == null,
        child: Column(
          children: [
            AccountTopBar(
              title: title,
              boxedBack: boxedBack,
              onBack: onBack,
              showBack: showBack,
              actions: actions,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppDimens.screenMargin,
                    AppDimens.sm, AppDimens.screenMargin, AppDimens.section),
                children: children,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: bottom == null
          ? null
          : Container(
              color: p.surface,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppDimens.screenMargin,
                      AppDimens.md, AppDimens.screenMargin, AppDimens.md),
                  child: bottom,
                ),
              ),
            ),
    );
  }
}

/// White rounded card (radius 16) with 1px border.
class AccountCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const AccountCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.cardPadding),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? p.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: p.border),
      ),
      child: child,
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(
          top: AppDimens.xl, bottom: AppDimens.md),
      child: Row(
        children: [
          Expanded(child: Text(text, style: AppTextStyles.h2(color: p.text))),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Large page heading ("Choisissez vos alertes", …).
class PageHeading extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? eyebrow;
  const PageHeading(this.title, {super.key, this.subtitle, this.eyebrow});

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.sm, bottom: AppDimens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrow != null) ...[
            Text(eyebrow!,
                style: AppTextStyles.bodyStrong(color: AppColors.primary)),
            const SizedBox(height: AppDimens.md),
          ],
          Text(title, style: AppTextStyles.display(color: p.text)),
          if (subtitle != null) ...[
            const SizedBox(height: AppDimens.md),
            Text(subtitle!, style: AppTextStyles.body(color: p.text2)),
          ],
        ],
      ),
    );
  }
}

/// Primary gradient button (#2563EB → #6366F1).
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  const GradientButton(
      {super.key, required this.label, this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.primaryGradient),
            borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppDimens.radiusCard),
            onTap: enabled ? onPressed : null,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.4, color: AppColors.textLight))
                  : Text(label, style: AppTextStyles.button()),
            ),
          ),
        ),
      ),
    );
  }
}

/// Solid danger button (deletion).
class DangerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const DangerButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.errorText,
          disabledBackgroundColor: AppColors.errorText.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusCard)),
        ),
        child: Text(label, style: AppTextStyles.button()),
      ),
    );
  }
}

/// Outlined/secondary button on surface.
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? textColor;
  final double height;
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.textColor,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    final c = textColor ?? p.text;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: p.surface,
          side: BorderSide(color: p.border),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusCard)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: c, size: 22),
              const SizedBox(width: AppDimens.md),
            ],
            Flexible(
              child: Text(label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.button(color: c)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tinted info banner (blue by default).
class InfoBanner extends StatelessWidget {
  final String title;
  final String? body;
  final IconData? icon;
  final Color color;
  final Color? background;
  final bool boldBody;

  const InfoBanner({
    super.key,
    required this.title,
    this.body,
    this.icon,
    this.color = AppColors.primary,
    this.background,
    this.boldBody = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: background ?? p.tint,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppDimens.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyStrong(color: color)),
                if (body != null)
                  Text(body!,
                      style: boldBody
                          ? AppTextStyles.bodyStrong(color: color)
                          : AppTextStyles.body(color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small pill / status chip.
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color? background;
  const StatusPill(
      {super.key, required this.label, required this.color, this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Text(label,
          style: AppTextStyles.caption(color: color)
              .copyWith(fontWeight: FontWeight.w600)),
    );
  }
}

/// Selectable pill (ATT/MIL…, Droit/Gauche…, Agent/Club/Joueur).
class ChoicePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const ChoicePill(
      {super.key,
      required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          constraints: const BoxConstraints(minHeight: AppDimens.minTouch),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: selected ? p.tint : p.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
            border: Border.all(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : p.border),
          ),
          child: Center(
            widthFactor: 1,
            child: Text(label,
                style: selected
                    ? AppTextStyles.caption(color: AppColors.primary)
                        .copyWith(fontWeight: FontWeight.w600)
                    : AppTextStyles.caption(color: p.text2)),
          ),
        ),
      ),
    );
  }
}

/// Labelled text field inside a rounded box (label on top, value below).
class LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hint;
  final bool readOnly;
  final bool obscure;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? errorText;

  const LabeledField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.readOnly = false,
    this.obscure = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.onChanged,
    this.onTap,
    this.trailing,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    final disabled = readOnly && onTap == null;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: disabled ? p.muted : p.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusInput),
              border: Border.all(
                  color: errorText != null ? AppColors.danger : p.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: AppTextStyles.caption(
                              color: disabled ? p.text3 : p.text2)),
                      const SizedBox(height: 2),
                      TextField(
                        controller: controller,
                        readOnly: readOnly,
                        onTap: onTap,
                        obscureText: obscure,
                        maxLines: obscure ? 1 : maxLines,
                        minLines: 1,
                        maxLength: maxLength,
                        keyboardType: keyboardType,
                        onChanged: onChanged,
                        style: AppTextStyles.body(
                            color: disabled ? p.text3 : p.text2),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: hint,
                          hintStyle: AppTextStyles.body(color: p.text3),
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(errorText!,
                  style: AppTextStyles.caption(color: AppColors.errorText)),
            ),
        ],
      ),
    );
  }
}

/// Row with title/subtitle and a Switch.
class SwitchRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final EdgeInsetsGeometry padding;

  const SwitchRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.padding = const EdgeInsets.symmetric(vertical: AppDimens.sm),
  });

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.body(color: p.text)),
                    if (subtitle != null)
                      Text(subtitle!,
                          style: AppTextStyles.caption(color: p.text3)),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: AppColors.textLight,
                activeTrackColor: AppColors.primary,
                inactiveThumbColor: AppColors.textLight,
                inactiveTrackColor: p.border,
                trackOutlineColor:
                    WidgetStateProperty.all(Colors.transparent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icon + title/subtitle row (used in menus & settings).
class IconRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;
  final bool bold;
  final bool chevron;
  final Widget? trailing;

  const IconRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.onTap,
    this.iconColor,
    this.titleColor,
    this.bold = false,
    this.chevron = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.lg, vertical: AppDimens.md),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
              const SizedBox(width: AppDimens.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        style: bold
                            ? AppTextStyles.h3(color: titleColor ?? p.text)
                            : AppTextStyles.bodyLarge(
                                    color: titleColor ?? p.text)
                                .copyWith(fontSize: 15, height: 22 / 15)),
                    if (subtitle != null)
                      Text(subtitle!,
                          style: AppTextStyles.body(color: p.text2)),
                  ],
                ),
              ),
              if (trailingText != null) ...[
                const SizedBox(width: AppDimens.sm),
                Text(trailingText!,
                    style: AppTextStyles.caption(color: p.text3)),
              ],
              if (trailing != null) trailing!,
              if (chevron) ...[
                const SizedBox(width: AppDimens.md),
                Icon(LucideIcons.chevronRight, color: p.text3, size: 22),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Upload card (icon, title, hint, "Ajouter" button / attached file chip).
class UploadCard extends StatelessWidget {
  final String title;
  final String hint;
  final String buttonLabel;
  final String? fileName;
  final VoidCallback onAdd;
  final VoidCallback? onRemove;
  final IconData icon;

  const UploadCard({
    super.key,
    required this.title,
    required this.hint,
    required this.onAdd,
    this.buttonLabel = 'Ajouter le document',
    this.fileName,
    this.onRemove,
    this.icon = LucideIcons.upload,
  });

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.md),
      child: AccountCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: AppDimens.md),
            Text(title, style: AppTextStyles.bodyStrong(color: p.text)),
            const SizedBox(height: AppDimens.sm),
            Text(hint, style: AppTextStyles.caption(color: p.text3)),
            const SizedBox(height: AppDimens.md),
            if (fileName == null)
              SecondaryButton(label: buttonLabel, onPressed: onAdd, height: 48)
            else
              Container(
                padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
                decoration: BoxDecoration(
                  color: p.muted,
                  borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.checkCircle2,
                        color: AppColors.success, size: 16),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(fileName!,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption(color: p.text)
                              .copyWith(fontWeight: FontWeight.w600)),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Retirer',
                      icon: Icon(LucideIcons.x, size: 16, color: p.text2),
                      onPressed: onRemove,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Divider inset between rows inside a card.
class RowDivider extends StatelessWidget {
  final double indent;
  const RowDivider({super.key, this.indent = AppDimens.lg});

  @override
  Widget build(BuildContext context) {
    return Divider(
        height: 1,
        thickness: 1,
        indent: indent,
        endIndent: AppDimens.lg,
        color: AccountPalette.of(context).divider);
  }
}

void showAccountSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message, style: AppTextStyles.body(color: AppColors.textLight)),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.navy800,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusInput)),
    ));
}

/// Centered dialog styled per "Modifications non enregistrées".
Future<T?> showAccountDialog<T>({
  required BuildContext context,
  required String title,
  required String message,
  required String primaryLabel,
  required String secondaryLabel,
  required T primaryValue,
  required T secondaryValue,
  bool primaryDanger = false,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: AppColors.navy900.withValues(alpha: 0.92),
    builder: (ctx) {
      final p = AccountPalette.of(ctx);
      return Dialog(
        backgroundColor: p.surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusSheet)),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.h1(color: p.text)),
              const SizedBox(height: AppDimens.md),
              Text(message, style: AppTextStyles.bodyLarge(color: p.text2)),
              const SizedBox(height: AppDimens.xl),
              primaryDanger
                  ? DangerButton(
                      label: primaryLabel,
                      onPressed: () => Navigator.of(ctx).pop(primaryValue))
                  : GradientButton(
                      label: primaryLabel,
                      onPressed: () => Navigator.of(ctx).pop(primaryValue)),
              const SizedBox(height: AppDimens.md),
              SecondaryButton(
                  label: secondaryLabel,
                  onPressed: () => Navigator.of(ctx).pop(secondaryValue)),
            ],
          ),
        ),
      );
    },
  );
}
