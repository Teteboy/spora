import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'auth_ui.dart';
import 'role_choice_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}
class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _accepted = false;
  bool _submitted = false;
  @override
  void dispose() { _name.dispose(); _email.dispose(); _phone.dispose(); _password.dispose(); super.dispose(); }
  void _submit() {
    setState(() => _submitted = true);
    if (!_form.currentState!.validate() || !_accepted) return;
    if (registrationRole == null) { context.push('/role'); return; }
    context.read<AuthProvider>().setUserType(registrationRole!);
    context.push('/verify-email', extra: _email.text.trim());
  }
  @override
  Widget build(BuildContext context) {
    final strong = strongPassword(_password.text);
    return AuthPage(title: 'Créer mon compte', back: '/role', children: [
      Text('Votre talent mérite d’être vu. Rejoignez SPORA.', style: AppTextStyles.body()), const SizedBox(height: 20),
      if (registrationRole == null) const AuthLink('Choisir votre rôle pour continuer', '/role'),
      Form(key: _form, child: Column(children: [
        AuthField(label: 'Nom complet *', hint: 'Jordan Mbala', controller: _name, validator: (v) => (v ?? '').trim().length < 2 ? 'Saisissez votre nom complet.' : null),
        AuthField(label: 'Adresse e-mail *', hint: 'jordan.mbala@email.com', controller: _email, keyboardType: TextInputType.emailAddress, validator: emailValidator, icon: LucideIcons.mail),
        AuthField(label: 'Téléphone · facultatif', hint: '+237   Votre numéro', controller: _phone, keyboardType: TextInputType.phone, icon: LucideIcons.phone),
        AuthField(label: 'Mot de passe *', controller: _password, password: true, validator: passwordValidator, onChanged: (_) => setState(() {})),
      ])),
      Row(children: List.generate(4, (i) => Expanded(child: Container(height: 3, margin: EdgeInsets.only(right: i == 3 ? 0 : 4), decoration: BoxDecoration(color: i < (strong ? 3 : (_password.text.isEmpty ? 0 : 1)) ? (strong ? AppColors.success : AppColors.danger) : AppColors.border, borderRadius: BorderRadius.circular(999)))))),
      const SizedBox(height: 8), Text(strong ? 'Mot de passe fort · 8 caractères minimum' : '8 caractères minimum, une lettre et un chiffre.', style: AppTextStyles.caption(color: strong ? AppColors.clubGreen : AppColors.textMuted)),
      const SizedBox(height: 8), CheckboxListTile(value: _accepted, onChanged: (v) => setState(() => _accepted = v ?? false), contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading, activeColor: AppColors.primary, title: Text('J’accepte les Conditions d’utilisation et la Politique de confidentialité.', style: AppTextStyles.caption(color: AppColors.textSecondary))),
      if (_submitted && !_accepted) const AuthNotice('Acceptez les conditions pour créer votre compte.', error: true),
      const SizedBox(height: 8), AuthButton('Créer mon compte', onPressed: _submit), const AuthSocial(), const SizedBox(height: 8), const Center(child: AuthLink('Déjà un compte ? Connexion', '/login')),
    ]);
  }
}
