import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shared building blocks for the SPORA administration console
/// (cards, pills, tables, filters, pagination, banners, buttons).

// ── Card ────────────────────────────────────────────────────────────────────

class AdminCard extends StatelessWidget {
  const AdminCard({super.key, required this.child, this.padding, this.color});
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppDimens.xl),
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

// ── Page header ─────────────────────────────────────────────────────────────

class AdminPageHeader extends StatelessWidget {
  const AdminPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.display()),
              const SizedBox(height: AppDimens.xs),
              Text(subtitle, style: AppTextStyles.body()),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppDimens.lg),
          DefaultTextStyle(
            style: AppTextStyles.caption(color: AppColors.textSecondary),
            child: trailing!,
          ),
        ],
      ],
    );
  }
}

// ── Status pill ─────────────────────────────────────────────────────────────

class AdminPill extends StatelessWidget {
  const AdminPill(this.label, {super.key, this.color = AppColors.textSecondary});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Text(label,
          style: AppTextStyles.caption(color: color)
              .copyWith(fontWeight: FontWeight.w600)),
    );
  }
}

/// Tinted banner with leading icon — used for info / warning notices.
class AdminBanner extends StatelessWidget {
  const AdminBanner({
    super.key,
    required this.title,
    required this.body,
    this.icon = LucideIcons.info,
    this.color = AppColors.primary,
  });
  final String title;
  final String body;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodyStrong(color: color)),
                const SizedBox(height: AppDimens.xs),
                Text(body, style: AppTextStyles.body()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat card ───────────────────────────────────────────────────────────────

class AdminStatCard extends StatelessWidget {
  const AdminStatCard({
    super.key,
    required this.label,
    required this.value,
    this.hint,
    this.hintColor = AppColors.success,
  });
  final String label;
  final String value;
  final String? hint;
  final Color hintColor;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.body()),
          const SizedBox(height: AppDimens.sm),
          Text(value,
              style: AppTextStyles.display().copyWith(fontSize: 24)),
          if (hint != null) ...[
            const SizedBox(height: AppDimens.sm),
            Text(hint!, style: AppTextStyles.caption(color: hintColor)),
          ],
        ],
      ),
    );
  }
}

// ── Search + filters ────────────────────────────────────────────────────────

class AdminSearchField extends StatelessWidget {
  const AdminSearchField({super.key, this.hint = 'Rechercher un nom, une référence…', this.width = 320});
  final String hint;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        style: AppTextStyles.body(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body(color: AppColors.textHint),
          prefixIcon:
              const Icon(LucideIcons.search, size: 20, color: AppColors.textMuted),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          filled: true,
          fillColor: AppColors.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusInput),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusInput),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

/// Mock filter chip styled like a dropdown selector.
class AdminFilter extends StatelessWidget {
  const AdminFilter(this.label, {super.key, this.selected = false, this.onTap});
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusInput),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryTint : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusInput),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTextStyles.bodyStrong(color: fg)),
            const SizedBox(width: AppDimens.sm),
            Icon(LucideIcons.chevronDown, size: 16, color: fg),
          ],
        ),
      ),
    );
  }
}

// ── Buttons ─────────────────────────────────────────────────────────────────

class AdminPrimaryButton extends StatelessWidget {
  const AdminPrimaryButton(this.label,
      {super.key, this.onPressed, this.icon, this.color});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed ?? () {},
      icon: Icon(icon ?? LucideIcons.plus, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: color ?? AppColors.primary,
        foregroundColor: Colors.white,
        textStyle: AppTextStyles.button(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusInput)),
      ),
    );
  }
}

class AdminOutlineButton extends StatelessWidget {
  const AdminOutlineButton(this.label,
      {super.key, this.onPressed, this.icon, this.color});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? AppColors.textPrimary;
    return OutlinedButton.icon(
      onPressed: onPressed ?? () {},
      icon: icon != null
          ? Icon(icon, size: 18, color: fg)
          : const SizedBox.shrink(),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: fg,
        textStyle: AppTextStyles.button(color: fg),
        side: BorderSide(color: color ?? AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusInput)),
      ),
    );
  }
}

/// Text link "Voir →" used in the Action column.
class AdminLink extends StatelessWidget {
  const AdminLink(this.label, {super.key, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text('$label →',
          style: AppTextStyles.bodyStrong(color: AppColors.primary)),
    );
  }
}

// ── Data table ──────────────────────────────────────────────────────────────

class AdminCol {
  const AdminCol(this.label, {this.flex = 1});
  final String label;
  final int flex;
}

/// Lightweight table matching the Figma rows (muted header, divider rows).
class AdminTable extends StatelessWidget {
  const AdminTable({
    super.key,
    required this.columns,
    required this.rows,
    this.onRowTap,
  });
  final List<AdminCol> columns;
  final List<List<Widget>> rows;
  final void Function(int index)? onRowTap;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.lg, vertical: AppDimens.md),
            decoration: const BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppDimens.radiusCard)),
            ),
            child: Row(
              children: [
                for (final c in columns)
                  Expanded(
                    flex: c.flex,
                    child: Text(c.label, style: AppTextStyles.caption()),
                  ),
              ],
            ),
          ),
          for (var i = 0; i < rows.length; i++)
            InkWell(
              onTap: onRowTap == null ? null : () => onRowTap!(i),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.lg, vertical: AppDimens.lg),
                decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: AppColors.divider)),
                ),
                child: Row(
                  children: [
                    for (var j = 0; j < columns.length; j++)
                      Expanded(flex: columns[j].flex, child: rows[i][j]),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Footer strip: "1–4 sur 4 résultats · 20 par page" + pager controls.
class AdminPagination extends StatelessWidget {
  const AdminPagination({super.key, required this.summary});
  final String summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.lg, vertical: AppDimens.md),
      child: Row(
        children: [
          Expanded(
              child:
                  Text(summary, style: AppTextStyles.caption())),
          Text('← Précédent',
              style: AppTextStyles.caption(color: AppColors.primary)),
          const SizedBox(width: AppDimens.md),
          _page('1', selected: true),
          const SizedBox(width: AppDimens.xs),
          _page('2'),
          const SizedBox(width: AppDimens.md),
          Text('Suivant →',
              style: AppTextStyles.caption(color: AppColors.primary)),
        ],
      ),
    );
  }

  static Widget _page(String n, {bool selected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: selected ? Border.all(color: AppColors.primary) : null,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(n,
          style: AppTextStyles.caption(
              color: selected ? AppColors.primary : AppColors.textSecondary)),
    );
  }
}

// ── Form field ──────────────────────────────────────────────────────────────

class AdminField extends StatelessWidget {
  const AdminField({super.key, required this.label, required this.value, this.maxLines = 1});
  final String label;
  final String value;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.body()),
        const SizedBox(height: AppDimens.sm),
        TextFormField(
          initialValue: value,
          maxLines: maxLines,
          style: AppTextStyles.body(color: AppColors.textPrimary),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusInput),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusInput),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

/// Section card with title + content.
class AdminSection extends StatelessWidget {
  const AdminSection({super.key, required this.title, required this.child, this.trailing});
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: AppTextStyles.h2())),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          child,
        ],
      ),
    );
  }
}

/// Responsive 2/4-column stat grid.
class AdminStatGrid extends StatelessWidget {
  const AdminStatGrid({super.key, required this.cards});
  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth > 1100 ? cards.length.clamp(2, 4) : 2;
      return GridView.count(
        crossAxisCount: cols,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppDimens.lg,
        crossAxisSpacing: AppDimens.lg,
        childAspectRatio: 2.6,
        children: cards,
      );
    });
  }
}
