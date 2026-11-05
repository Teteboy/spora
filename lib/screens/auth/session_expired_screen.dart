import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'auth_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// /session-expired — "Complément mobile · Session expirée".
class SessionExpiredScreen extends StatefulWidget {
  const SessionExpiredScreen({super.key});
  @override
  State<SessionExpiredScreen> createState() => _SessionExpiredScreenState();
}

class _SessionExpiredScreenState extends State<SessionExpiredScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _email;
  final _password = TextEditingController();
  bool _loading = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(
        text: context.read<AuthProvider>().currentUser?.email ?? '');
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _reconnect() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = false;
    });
    final auth = context.read<AuthProvider>();
    await auth.login(_email.text.trim(), _password.text);
    if (!mounted) return;
    if (auth.isAuthenticated) {
      context.go('/home');
    } else {
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) =>
      AuthPage(title: 'Session expirée', back: '/login', children: [
        const AuthHero(
          icon: LucideIcons.logIn,
          title: 'Reconnectez-vous pour continuer.',
          description: '',
        ),
        if (_error)
          const AuthNotice(
              'Email ou mot de passe incorrect\nVérifiez vos informations puis réessayez.',
              error: true),
        const AuthNotice(
            'Votre session a expiré\nVotre session a expiré ou a été révoquée. Vos données enregistrées sont conservées.'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                key: _form,
                child: Column(children: [
                  AuthField(
                    label: 'E-mail',
                    controller: _email,
                    hint: 'jordan.mbala@email.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: emailValidator,
                  ),
                  AuthField(
                    label: 'Mot de passe',
                    controller: _password,
                    password: true,
                    validator: (v) => (v ?? '').isEmpty
                        ? 'Saisissez votre mot de passe.'
                        : null,
                  ),
                ]),
              ),
              AuthButton(_loading ? 'Connexion en cours...' : 'Se reconnecter',
                  onPressed: _reconnect, loading: _loading),
              const AuthLink('Mot de passe oublié ?', '/forgot-password'),
            ],
          ),
        ),
        AuthButton('Retour à l’accueil de connexion',
            secondary: true, onPressed: () => context.go('/login')),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'Vos données et brouillons sont conservés sur cet appareil.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(),
          ),
        ),
      ]);
}
