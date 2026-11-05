import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/spora_images.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shared building blocks for the onboarding flows (Figma "02 · Onboarding").

const Duration _kFast = Duration(milliseconds: 120);
const Duration _kBase = Duration(milliseconds: 200);

TextStyle get onbLabelStyle =>
    AppTextStyles.bodyLarge(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w500);

// ---------------------------------------------------------------------------
// Scaffold: top bar · step eyebrow · progress · scroll body · bottom CTA
// ---------------------------------------------------------------------------

class OnbScaffold extends StatelessWidget {
  const OnbScaffold({
    super.key,
    required this.title,
    required this.children,
    this.onBack,
    this.bottom,
    this.eyebrow,
    this.eyebrowColor = AppColors.primary,
    this.trailingEyebrow,
    this.progress,
    this.showPercent = true,
    this.segmentCount,
    this.segmentFilled = 0,
    this.boxedBack = false,
    this.actions,
  });

  final String title;
  final List<Widget> children;
  final VoidCallback? onBack;
  final Widget? bottom;
  final String? eyebrow;
  final Color eyebrowColor;
  final String? trailingEyebrow;
  final double? progress;
  final bool showPercent;
  final int? segmentCount;
  final int segmentFilled;
  final bool boxedBack;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final hasProgress = eyebrow != null || progress != null || segmentCount != null;
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(title: title, onBack: onBack, boxed: boxedBack, actions: actions),
            if (hasProgress)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: _ProgressBlock(
                  eyebrow: eyebrow,
                  eyebrowColor: eyebrowColor,
                  trailing: trailingEyebrow,
                  progress: progress,
                  showPercent: showPercent,
                  segmentCount: segmentCount,
                  segmentFilled: segmentFilled,
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                children: children,
              ),
            ),
            if (bottom != null)
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.divider)),
                ),
                padding: EdgeInsets.fromLTRB(
                    16, 12, 16, 12 + MediaQuery.paddingOf(context).bottom),
                child: bottom,
              ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, this.onBack, this.boxed = false, this.actions});
  final String title;
  final VoidCallback? onBack;
  final bool boxed;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    Widget? back;
    if (onBack != null) {
      // Figma back tile: bordered rounded square (same whether `boxed` or not).
      back = Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusInput),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppDimens.radiusInput),
            onTap: onBack,
            child: Container(
              width: AppDimens.minTouch,
              height: AppDimens.minTouch,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimens.radiusInput),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(LucideIcons.arrowLeft,
                  size: 22,
                  color: AppColors.textPrimary,
                  semanticLabel: 'Retour'),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 8, 0),
      child: SizedBox(
        height: AppDimens.topBar,
        child: Row(
          children: [
            back ?? const SizedBox(width: 12),
            const SizedBox(width: 4),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  style: AppTextStyles.h1(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            ...?actions,
          ],
        ),
      ),
    );
  }
}

class _ProgressBlock extends StatelessWidget {
  const _ProgressBlock({
    this.eyebrow,
    required this.eyebrowColor,
    this.trailing,
    this.progress,
    required this.showPercent,
    this.segmentCount,
    required this.segmentFilled,
  });

  final String? eyebrow;
  final Color eyebrowColor;
  final String? trailing;
  final double? progress;
  final bool showPercent;
  final int? segmentCount;
  final int segmentFilled;

  @override
  Widget build(BuildContext context) {
    final p = (progress ?? 0).clamp(0.0, 1.0).toDouble();
    return Semantics(
      container: true,
      label: [
        if (eyebrow != null) eyebrow!,
        if (progress != null) '${(p * 100).round()} %',
      ].join(', '),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (eyebrow != null)
                Text(eyebrow!, style: AppTextStyles.bodyStrong(color: eyebrowColor)),
              const Spacer(),
              if (trailing != null) Text(trailing!, style: AppTextStyles.caption()),
            ],
          ),
          if (segmentCount == null && progress != null && showPercent) ...[
            const SizedBox(height: 12),
            Text('${(p * 100).round()} %',
                style: AppTextStyles.bodyStrong(color: AppColors.primary)),
          ],
          const SizedBox(height: 12),
          if (segmentCount != null)
            OnbSegmentedBar(count: segmentCount!, filled: segmentFilled)
          else
            OnbProgressBar(value: p),
        ],
      ),
    );
  }
}

class OnbProgressBar extends StatelessWidget {
  const OnbProgressBar({super.key, required this.value, this.height = 6});
  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: value.clamp(0.0, 1.0).toDouble()),
          duration: const Duration(milliseconds: 320),
          curve: const Cubic(0.2, 0, 0, 1),
          builder: (context, v, _) => Stack(
            children: [
              const Positioned.fill(child: ColoredBox(color: AppColors.border)),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: v,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.primaryGradient),
                    borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnbSegmentedBar extends StatelessWidget {
  const OnbSegmentedBar({super.key, required this.count, required this.filled});
  final int count;
  final int filled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        return Expanded(
          child: AnimatedContainer(
            duration: _kBase,
            height: 6,
            margin: EdgeInsets.only(right: i < count - 1 ? 8 : 0),
            decoration: BoxDecoration(
              color: i < filled ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(AppDimens.radiusPill),
            ),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Buttons
// ---------------------------------------------------------------------------

class OnbPrimaryButton extends StatelessWidget {
  const OnbPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.solidColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  /// When set, replaces the brand gradient (e.g. club green).
  final Color? solidColor;

  @override
  Widget build(BuildContext context) {
    final active = onPressed != null;
    final radius = BorderRadius.circular(AppDimens.radiusInput);
    final fg = active ? AppColors.textLight : AppColors.textMuted;
    return Semantics(
      button: true,
      enabled: active && !loading,
      child: Material(
        type: MaterialType.transparency,
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            gradient: active && solidColor == null
                ? const LinearGradient(colors: AppColors.primaryGradient)
                : null,
            color: active ? solidColor : AppColors.border,
            borderRadius: radius,
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: active && !loading ? onPressed : null,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.2, color: AppColors.textLight),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: fg, size: 20),
                          const SizedBox(width: 10),
                        ],
                        Flexible(
                          child: Text(label,
                              style: AppTextStyles.button(color: fg),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class OnbSecondaryButton extends StatelessWidget {
  const OnbSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = AppColors.textPrimary,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDimens.radiusInput);
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: 52,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: color),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(label,
                      style: AppTextStyles.h3(color: color),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnbTextButton extends StatelessWidget {
  const OnbTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primary,
    this.filled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;

  /// White surface behind the link (e.g. "Je le ferai plus tard").
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.surface : AppColors.surface.withValues(alpha: 0),
      borderRadius: BorderRadius.circular(AppDimens.radiusInput),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: 52,
          width: double.infinity,
          child: Center(child: Text(label, style: AppTextStyles.h3(color: color))),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Inputs
// ---------------------------------------------------------------------------

class _OnbError extends StatelessWidget {
  const _OnbError(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Semantics(
        liveRegion: true,
        child: Text(text, style: AppTextStyles.caption(color: AppColors.errorText)),
      ),
    );
  }
}

/// Text field. By default the label sits inside the box (Figma "Prénom *"
/// cards); set [labelOutside] for the football-style label above the box.
class OnbField extends StatefulWidget {
  const OnbField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofillHints,
    this.onChanged,
    this.errorText,
    this.prefixText,
    this.trailing,
    this.enabled = true,
    this.labelOutside = false,
    this.maxLength,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final String? prefixText;
  final Widget? trailing;
  final bool enabled;
  final bool labelOutside;
  final int? maxLength;

  @override
  State<OnbField> createState() => _OnbFieldState();
}

class _OnbFieldState extends State<OnbField> {
  late final FocusNode _focus = FocusNode()..addListener(_onFocus);

  void _onFocus() => setState(() {});

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final hasError = w.errorText != null;
    final focused = _focus.hasFocus;
    final borderColor = hasError
        ? AppColors.danger
        : focused
            ? AppColors.primary
            : AppColors.border;

    final field = TextField(
      controller: w.controller,
      focusNode: _focus,
      enabled: w.enabled,
      keyboardType: w.keyboardType,
      textInputAction: w.textInputAction,
      textCapitalization: w.textCapitalization,
      inputFormatters: [
        ...?w.inputFormatters,
        if (w.maxLength != null) LengthLimitingTextInputFormatter(w.maxLength),
      ],
      autofillHints: w.autofillHints,
      onChanged: w.onChanged,
      cursorColor: AppColors.primary,
      style: AppTextStyles.bodyLarge(
          color: w.enabled ? AppColors.textPrimary : AppColors.textMuted),
      decoration: InputDecoration(
        isDense: true,
        filled: false,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        hintText: w.hint,
        hintStyle: AppTextStyles.bodyLarge(color: AppColors.textHint),
        prefixText: w.prefixText,
        // Keeps the prefix (e.g. "+237") visible while the field is empty.
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixStyle: AppTextStyles.bodyLarge(color: AppColors.textSecondary),
      ),
    );

    final box = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: w.enabled ? _focus.requestFocus : null,
      child: AnimatedContainer(
        duration: _kFast,
        padding: EdgeInsets.fromLTRB(16, w.labelOutside ? 15 : 11, 12, w.labelOutside ? 15 : 11),
        decoration: BoxDecoration(
          color: w.enabled ? AppColors.surface : AppColors.muted,
          borderRadius: BorderRadius.circular(AppDimens.radiusInput),
          border: Border.all(color: borderColor, width: focused || hasError ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: w.labelOutside
                  ? field
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(w.label,
                            style: AppTextStyles.body(color: AppColors.textSecondary)),
                        const SizedBox(height: 2),
                        field,
                      ],
                    ),
            ),
            if (w.trailing != null) w.trailing!,
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (w.labelOutside) ...[
          Text(w.label, style: onbLabelStyle),
          const SizedBox(height: 8),
        ],
        box,
        if (hasError) _OnbError(w.errorText!),
      ],
    );
  }
}

/// Tappable "field" opening a picker (select, date…).
class OnbSelectBox extends StatelessWidget {
  const OnbSelectBox({
    super.key,
    required this.label,
    required this.onTap,
    this.value,
    this.hint,
    this.errorText,
    this.icon = LucideIcons.chevronDown,
    this.labelOutside = false,
  });

  final String label;
  final String? value;
  final String? hint;
  final VoidCallback onTap;
  final String? errorText;
  final IconData icon;
  final bool labelOutside;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    final valueText = Text(
      value ?? hint ?? '',
      style: AppTextStyles.bodyLarge(
          color: value == null ? AppColors.textHint : AppColors.textPrimary),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    return Semantics(
      button: true,
      label: '$label${value != null ? ', $value' : ''}',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (labelOutside) ...[
            Text(label, style: onbLabelStyle),
            const SizedBox(height: 8),
          ],
          Material(
            color: AppColors.surface,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusInput),
              side: BorderSide(
                  color: hasError ? AppColors.danger : AppColors.border,
                  width: hasError ? 1.5 : 1),
            ),
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    16, labelOutside ? 15 : 11, 12, labelOutside ? 15 : 11),
                child: Row(
                  children: [
                    Expanded(
                      child: labelOutside
                          ? valueText
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(label,
                                    style: AppTextStyles.body(
                                        color: AppColors.textSecondary)),
                                const SizedBox(height: 2),
                                valueText,
                              ],
                            ),
                    ),
                    const SizedBox(width: 8),
                    Icon(icon, color: AppColors.textMuted, size: 22),
                  ],
                ),
              ),
            ),
          ),
          if (hasError) _OnbError(errorText!),
        ],
      ),
    );
  }
}

class OnbSectionLabel extends StatelessWidget {
  const OnbSectionLabel(this.text, {super.key, this.helper});
  final String text;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: onbLabelStyle),
          if (helper != null) ...[
            const SizedBox(height: 2),
            Text(helper!, style: AppTextStyles.caption()),
          ],
        ],
      ),
    );
  }
}

class OnbPill extends StatelessWidget {
  const OnbPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
    this.semanticLabel,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: _kFast,
        decoration: ShapeDecoration(
          color: selected ? AppColors.primaryTint.withValues(alpha: 0.7) : AppColors.surface,
          shape: StadiumBorder(
            side: BorderSide(
              color: selected ? AppColors.primary.withValues(alpha: 0.35) : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 56, minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (leading != null) ...[leading!, const SizedBox(width: 8)],
                    Text(
                      label,
                      style: AppTextStyles.body(
                        color: selected ? AppColors.primary : AppColors.textSecondary,
                      ).copyWith(
                        fontSize: 15,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OnbPillWrap extends StatelessWidget {
  const OnbPillWrap({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: 10, runSpacing: 10, children: children);
}

enum OnbTone { info, success }

class OnbBanner extends StatelessWidget {
  const OnbBanner({
    super.key,
    required this.title,
    this.message,
    this.tone = OnbTone.info,
    this.icon,
    this.boldMessage = true,
  });

  final String title;
  final String? message;
  final OnbTone tone;
  final IconData? icon;
  final bool boldMessage;

  @override
  Widget build(BuildContext context) {
    final fg = tone == OnbTone.info ? AppColors.primary : AppColors.clubGreen;
    final bg = tone == OnbTone.info
        ? AppColors.primary.withValues(alpha: 0.08)
        : AppColors.green.withValues(alpha: 0.10);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: fg, size: 24),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyStrong(color: fg).copyWith(fontSize: 15)),
                if (message != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    message!,
                    style: boldMessage
                        ? AppTextStyles.bodyStrong(color: fg).copyWith(fontSize: 15)
                        : AppTextStyles.body(color: AppColors.textSecondary).copyWith(fontSize: 15),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnbCard extends StatelessWidget {
  const OnbCard({super.key, required this.child, this.padding = const EdgeInsets.all(20)});
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class OnbStatusChip extends StatelessWidget {
  const OnbStatusChip({super.key, required this.label, this.tone = OnbTone.info});
  final String label;
  final OnbTone tone;

  @override
  Widget build(BuildContext context) {
    final fg = tone == OnbTone.info ? AppColors.primary : AppColors.clubGreen;
    final bg = tone == OnbTone.info
        ? AppColors.primary.withValues(alpha: 0.08)
        : AppColors.green.withValues(alpha: 0.12);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Text(label, style: AppTextStyles.bodyStrong(color: fg).copyWith(fontSize: 13)),
    );
  }
}

class OnbToggleRow extends StatelessWidget {
  const OnbToggleRow({super.key, required this.label, required this.value, required this.onChanged});
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTextStyles.bodyLarge(color: AppColors.textPrimary)),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.border,
            thumbColor: WidgetStateProperty.resolveWith((states) =>
                states.contains(WidgetState.selected) ? AppColors.surface : AppColors.textMuted),
            trackOutlineColor: WidgetStateProperty.resolveWith((states) =>
                states.contains(WidgetState.selected) ? AppColors.primary : AppColors.border),
          ),
        ],
      ),
    );
  }
}

class OnbCheckRow extends StatelessWidget {
  const OnbCheckRow({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.errorText,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MergeSemantics(
          child: InkWell(
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            onTap: () => onChanged(!value),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: Checkbox(
                      value: value,
                      onChanged: (v) => onChanged(v ?? false),
                      activeColor: AppColors.primary,
                      side: BorderSide(
                        color: errorText != null ? AppColors.danger : AppColors.textMuted,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(label,
                          style: AppTextStyles.bodyLarge(color: AppColors.textPrimary)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (errorText != null) _OnbError(errorText!),
      ],
    );
  }
}

/// Centered media placeholder (photo / logo / crest) + link label.
class OnbMediaPicker extends StatelessWidget {
  const OnbMediaPicker({
    super.key,
    required this.icon,
    required this.label,
    required this.changeLabel,
    required this.onTap,
    this.image,
    this.linkColor = AppColors.primary,
    this.fit = BoxFit.cover,
    this.errorText,
    this.helper,
  });

  final IconData icon;
  final String label;
  final String changeLabel;
  final VoidCallback onTap;
  final Uint8List? image;
  final Color linkColor;
  final BoxFit fit;
  final String? errorText;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Semantics(
            button: true,
            label: image != null ? changeLabel : label,
            excludeSemantics: true,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppDimens.radiusCard),
              child: AnimatedSwitcher(
                duration: _kBase,
                child: image != null
                    ? Container(
                        key: const ValueKey('img'),
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                          border: Border.all(color: AppColors.border),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.memory(image!, fit: fit, gaplessPlayback: true),
                      )
                    : SizedBox(
                        key: const ValueKey('ph'),
                        width: 112,
                        height: 100,
                        child: Icon(icon, size: 72, color: AppColors.primary),
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ExcludeSemantics(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(image != null ? changeLabel : label,
                  style: AppTextStyles.bodyLarge(color: linkColor)),
            ),
          ),
        ),
        if (helper != null && errorText == null)
          Text(helper!, style: AppTextStyles.caption()),
        if (errorText != null) _OnbError(errorText!),
      ],
    );
  }
}

/// Done / welcome header: outlined check circle + display headline.
class OnbDoneHeader extends StatelessWidget {
  const OnbDoneHeader({
    super.key,
    required this.headline,
    required this.subtitle,
    this.color = AppColors.primary,
  });

  final String headline;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.6, end: 1),
          duration: const Duration(milliseconds: 480),
          curve: const Cubic(0.3, 0, 0, 1.2),
          builder: (context, s, child) => Transform.scale(scale: s, child: child),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(LucideIcons.check, color: color, size: 44),
          ),
        ),
        const SizedBox(height: 32),
        Semantics(header: true, child: Text(headline, style: AppTextStyles.display())),
        const SizedBox(height: 12),
        Text(subtitle, style: AppTextStyles.bodyLarge(color: AppColors.textSecondary)),
      ],
    );
  }
}

/// Icon + two-line row used in summary / tips cards.
class OnbInfoRow extends StatelessWidget {
  const OnbInfoRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor = AppColors.primary,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyLarge(color: AppColors.textPrimary)),
                  if (subtitle != null)
                    Text(subtitle!, style: AppTextStyles.bodyLarge(color: AppColors.textPrimary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mock video poster with graceful fallback.
class OnbVideoThumb extends StatelessWidget {
  const OnbVideoThumb({super.key, required this.seed, this.radius = 12});
  final int seed;
  final double radius;

  @override
  Widget build(BuildContext context) {
    const fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.navy700, AppColors.clubGreen],
        ),
      ),
      child: Center(child: Icon(LucideIcons.goal, color: AppColors.textLight, size: 32)),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          sporaImage('spora-highlight-$seed' as Object?, w: 640, h: 360),
          fit: BoxFit.cover,
          semanticLabel: 'Aperçu de la vidéo',
          errorBuilder: (context, error, stack) => fallback,
          loadingBuilder: (context, child, progress) => progress == null ? child : fallback,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sheets & helpers
// ---------------------------------------------------------------------------

class OnbChoice<T> {
  const OnbChoice(this.value, this.label, {this.icon, this.destructive = false});
  final T value;
  final String label;
  final IconData? icon;
  final bool destructive;
}

ShapeBorder get _sheetShape => const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusSheet)),
    );

Future<T?> showOnbChoiceSheet<T>(
  BuildContext context, {
  required String title,
  required List<OnbChoice<T>> choices,
  T? selected,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    shape: _sheetShape,
    builder: (ctx) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(title, style: AppTextStyles.h2()),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 8),
                children: [
                  for (final c in choices)
                    ListTile(
                      leading: c.icon == null
                          ? null
                          : Icon(c.icon,
                              color: c.destructive ? AppColors.errorText : AppColors.primary),
                      title: Text(
                        c.label,
                        style: AppTextStyles.bodyLarge(
                            color: c.destructive ? AppColors.errorText : AppColors.textPrimary),
                      ),
                      trailing: c.value == selected
                          ? const Icon(LucideIcons.check, color: AppColors.primary)
                          : null,
                      selected: c.value == selected,
                      onTap: () => Navigator.of(ctx).pop(c.value),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<String?> showOnbOptionsSheet(
  BuildContext context, {
  required String title,
  required List<String> options,
  String? selected,
}) =>
    showOnbChoiceSheet<String>(
      context,
      title: title,
      selected: selected,
      choices: [for (final o in options) OnbChoice(o, o)],
    );

Future<Set<String>?> showOnbMultiSelectSheet(
  BuildContext context, {
  required String title,
  required List<String> options,
  required Set<String> selected,
}) {
  final working = {...selected};
  return showModalBottomSheet<Set<String>>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    shape: _sheetShape,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.75),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Text(title, style: AppTextStyles.h2()),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text('Plusieurs choix possibles', style: AppTextStyles.caption()),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final o in options)
                      CheckboxListTile(
                        value: working.contains(o),
                        activeColor: AppColors.primary,
                        controlAffinity: ListTileControlAffinity.trailing,
                        title: Text(o, style: AppTextStyles.bodyLarge(color: AppColors.textPrimary)),
                        onChanged: (v) => setSheet(() {
                          if (v == true) {
                            working.add(o);
                          } else {
                            working.remove(o);
                          }
                        }),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: OnbPrimaryButton(
                  label: 'Valider',
                  onPressed: () => Navigator.of(ctx).pop(working),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<RangeValues?> showOnbAgeRangeSheet(
  BuildContext context, {
  required RangeValues initial,
  double min = 15,
  double max = 40,
}) {
  var working = initial;
  return showModalBottomSheet<RangeValues>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    shape: _sheetShape,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tranche d’âge', style: AppTextStyles.h2()),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '${working.start.round()}–${working.end.round()} ans',
                  style: AppTextStyles.statNumber(color: AppColors.primary),
                ),
              ),
              RangeSlider(
                values: working,
                min: min,
                max: max,
                divisions: (max - min).round(),
                activeColor: AppColors.primary,
                inactiveColor: AppColors.border,
                labels: RangeLabels('${working.start.round()}', '${working.end.round()}'),
                onChanged: (v) => setSheet(() => working = v),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${min.round()} ans', style: AppTextStyles.caption()),
                  Text('${max.round()} ans', style: AppTextStyles.caption()),
                ],
              ),
              const SizedBox(height: 16),
              OnbPrimaryButton(
                label: 'Valider',
                onPressed: () => Navigator.of(ctx).pop(working),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void showOnbSnack(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? AppColors.errorText : AppColors.navy800,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusInput)),
        content: Text(message, style: AppTextStyles.body(color: AppColors.textLight)),
      ),
    );
}

/// Center-crops [bytes] to a square PNG (max [maxSide] px).
Future<Uint8List> cropToSquare(Uint8List bytes, {int maxSide = 512}) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  final src = frame.image;
  final side = math.min(src.width, src.height);
  final target = math.min(side, maxSide);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawImageRect(
    src,
    Rect.fromLTWH((src.width - side) / 2, (src.height - side) / 2,
        side.toDouble(), side.toDouble()),
    Rect.fromLTWH(0, 0, target.toDouble(), target.toDouble()),
    Paint()..filterQuality = FilterQuality.high,
  );
  final out = await recorder.endRecording().toImage(target, target);
  final data = await out.toByteData(format: ui.ImageByteFormat.png);
  src.dispose();
  out.dispose();
  codec.dispose();
  if (data == null) return bytes;
  return data.buffer.asUint8List();
}
