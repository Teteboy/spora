import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'auth_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}
class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _form = GlobalKey<FormState>();
  @override
  void dispose() { _password.dispose(); _confirm.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AuthPage(title: 'Nouveau mot de passe', bottom: AuthButton('Réinitialiser', onPressed: () { if (_form.currentState!.validate()) context.push('/password-updated'); }), children: [
    const AuthHero(icon: LucideIcons.lock, title: 'Choisissez un mot de passe sûr', description: 'Votre nouveau mot de passe doit être différent du précédent.'),
    Form(key: _form, child: Column(children: [
      AuthField(label: 'Nouveau mot de passe', controller: _password, password: true, validator: passwordValidator, onChanged: (_) => setState(() {})),
      AuthField(label: 'Confirmer le mot de passe', controller: _confirm, password: true, validator: (v) => v != _password.text || (v ?? '').isEmpty ? 'Les mots de passe doivent correspondre.' : null, onChanged: (_) => setState(() {})),
    ])),
    Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _rule('8 caractères minimum', _password.text.length >= 8),
      _rule('Une lettre et un chiffre', strongPassword(_password.text)),
      _rule('Les mots de passe correspondent', _password.text.isNotEmpty && _password.text == _confirm.text),
    ])),
  ]);
  Widget _rule(String text, bool valid) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text('${valid ? '✓' : '–'} $text', style: AppTextStyles.body(color: valid ? AppColors.clubGreen : AppColors.textMuted)));
}
