import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_text_styles.dart';
import 'auth_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _error = false;
  @override
  void dispose() { _email.dispose(); _password.dispose(); super.dispose(); }
  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() { _loading = true; _error = false; });
    final auth = context.read<AuthProvider>();
    final role = auth.selectedUserType == UserType.guest ? UserType.player : auth.selectedUserType;
    auth.setUserType(role);
    await auth.login(_email.text.trim(), _password.text);
    if (!mounted) return;
    if (auth.isAuthenticated) { context.go('/home'); } else { setState(() { _loading = false; _error = true; }); }
  }
  @override
  Widget build(BuildContext context) => AuthPage(title: 'Connexion', back: '/welcome', children: [
    const SizedBox(height: 16), const AuthBrand(), const SizedBox(height: 24),
    Text('Bon retour parmi nous', style: AppTextStyles.display()), const SizedBox(height: 20),
    if (_error) const AuthNotice('Email ou mot de passe incorrect\nVérifiez vos informations puis réessayez.', error: true),
    Form(key: _form, child: Column(children: [
      AuthField(label: 'Adresse e-mail *', controller: _email, hint: 'jordan.mbala@email.com', keyboardType: TextInputType.emailAddress, validator: emailValidator, icon: LucideIcons.mail),
      AuthField(label: 'Mot de passe *', controller: _password, password: true, validator: (v) => (v ?? '').isEmpty ? 'Saisissez votre mot de passe.' : null),
    ])),
    const AuthLink('Mot de passe oublié ?', '/forgot-password'), const SizedBox(height: 4),
    AuthButton(_loading ? 'Connexion en cours...' : 'Connexion', onPressed: _login, loading: _loading),
    if (_loading) ...[const SizedBox(height: 16), Text('Vérification de vos informations. Veuillez patienter.', style: AppTextStyles.caption())],
    const AuthSocial(), const SizedBox(height: 8), const AuthLink('Pas encore de compte ? Créer un compte', '/role'),
  ]);
}
