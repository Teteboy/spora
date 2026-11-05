import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

bool validEmail(String value) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim());
bool strongPassword(String value) => value.length >= 8 && RegExp(r'[a-zA-Z]').hasMatch(value) && RegExp(r'[0-9]').hasMatch(value);
String? emailValidator(String? value) => validEmail(value ?? '') ? null : 'Saisissez une adresse e-mail valide.';
String? passwordValidator(String? value) => strongPassword(value ?? '') ? null : '8 caractères minimum, une lettre et un chiffre requis.';

class AuthBrand extends StatelessWidget {
  const AuthBrand({super.key, this.light = false});
  final bool light;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset('assets/images/spora_icon.png', height: 44, width: 44, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink())),
    const SizedBox(width: 10),
    Text.rich(TextSpan(children: [
      const TextSpan(text: 'SP'),
      const TextSpan(text: 'O', style: TextStyle(color: AppColors.gold)),
      const TextSpan(text: 'RA'),
    ]), style: AppTextStyles.display(color: light ? AppColors.textLight : AppColors.navy900)),
  ]);
}

class AuthPage extends StatelessWidget {
  const AuthPage({super.key, required this.title, required this.children, this.bottom, this.back = '/login'});
  final String title;
  final List<Widget> children;
  final Widget? bottom;
  final String back;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.appBg,
    appBar: AppBar(backgroundColor: AppColors.appBg, surfaceTintColor: AppColors.appBg,
      leadingWidth: AppDimens.minTouch + AppDimens.screenMargin,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppDimens.screenMargin),
        child: GestureDetector(
          onTap: () { if (context.canPop()) { context.pop(); } else { context.go(back); } },
          child: Container(
            width: AppDimens.minTouch,
            height: AppDimens.minTouch,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusInput),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(LucideIcons.arrowLeft, size: 22, color: AppColors.textPrimary),
          ),
        ),
      ),
      title: Text(title, style: AppTextStyles.h1()), titleSpacing: 0),
    body: SafeArea(top: false, child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children))),
    bottomNavigationBar: bottom == null ? null : Container(color: AppColors.surface, padding: const EdgeInsets.fromLTRB(16, 12, 16, 12), child: SafeArea(top: false, child: bottom!)),
  );
}

class AuthButton extends StatelessWidget {
  const AuthButton(this.label, {super.key, required this.onPressed, this.secondary = false, this.loading = false});
  final String label;
  final VoidCallback? onPressed;
  final bool secondary;
  final bool loading;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, constraints: const BoxConstraints(minHeight: 52),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: secondary ? AppColors.surface : (onPressed == null ? AppColors.border : null), gradient: !secondary && onPressed != null ? const LinearGradient(colors: AppColors.primaryGradient) : null, border: secondary ? Border.all(color: AppColors.border) : null),
    child: TextButton(onPressed: loading ? null : onPressed,
      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [if (loading) ...[const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.surface)), const SizedBox(width: 12)], Flexible(child: Text(label, textAlign: TextAlign.center, style: AppTextStyles.button(color: secondary ? AppColors.textPrimary : (onPressed == null ? AppColors.textMuted : AppColors.textLight))))])),
  );
}

class AuthField extends StatefulWidget {
  const AuthField({super.key, required this.label, required this.controller, this.hint, this.password = false, this.keyboardType, this.validator, this.onChanged, this.enabled = true, this.icon});
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool password;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final IconData? icon;
  @override
  State<AuthField> createState() => _AuthFieldState();
}
class _AuthFieldState extends State<AuthField> {
  bool _visible = false;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 16), child: TextFormField(
    controller: widget.controller, enabled: widget.enabled, obscureText: widget.password && !_visible,
    keyboardType: widget.keyboardType, validator: widget.validator, onChanged: widget.onChanged,
    autovalidateMode: AutovalidateMode.onUserInteraction, textInputAction: TextInputAction.next,
    style: AppTextStyles.body(), decoration: InputDecoration(
      labelText: widget.label, labelStyle: AppTextStyles.body(), hintText: widget.hint, hintStyle: AppTextStyles.body(),
      filled: true, fillColor: AppColors.surface, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      errorStyle: AppTextStyles.caption(color: AppColors.errorText), errorMaxLines: 2,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.danger)),
      suffixIcon: widget.password ? IconButton(tooltip: _visible ? 'Masquer le mot de passe' : 'Afficher le mot de passe', onPressed: () => setState(() => _visible = !_visible), icon: Icon(_visible ? LucideIcons.eye : LucideIcons.eyeOff, color: AppColors.textMuted)) : widget.icon == null ? null : Icon(widget.icon, color: AppColors.textMuted),
    ),
  ));
}

class AuthNotice extends StatelessWidget {
  const AuthNotice(this.text, {super.key, this.error = false});
  final String text;
  final bool error;
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: (error ? AppColors.danger : AppColors.primary).withValues(alpha: 0.07), borderRadius: BorderRadius.circular(16)), child: Text(text, style: AppTextStyles.bodyStrong(color: error ? AppColors.errorText : AppColors.primary)));
}

class AuthLink extends StatelessWidget {
  const AuthLink(this.label, this.route, {super.key});
  final String label;
  final String route;
  @override
  Widget build(BuildContext context) => TextButton(style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft, minimumSize: const Size(44, 44)), onPressed: () => context.push(route), child: Text(label, style: AppTextStyles.body(color: AppColors.primary)));
}

class AuthSocial extends StatelessWidget {
  const AuthSocial({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SizedBox(height: 12), Text('ou avec', style: AppTextStyles.body()), const SizedBox(height: 12),
    Row(children: [Expanded(child: AuthButton('Google', secondary: true, onPressed: () => _notice(context))), const SizedBox(width: 12), Expanded(child: AuthButton('Apple', secondary: true, onPressed: () => _notice(context)))]),
  ]);
  void _notice(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connexion sociale bientôt disponible.')));
}

class AuthHero extends StatelessWidget {
  const AuthHero({super.key, required this.icon, required this.title, required this.description});
  final IconData icon;
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SizedBox(height: 40), Center(child: Icon(icon, size: 64, color: AppColors.primary)), const SizedBox(height: 48),
    Text(title, style: AppTextStyles.display()), const SizedBox(height: 20), Text(description, style: AppTextStyles.bodyLarge()), const SizedBox(height: 16),
  ]);
}
