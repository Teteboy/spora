import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'auth_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}
class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _form = GlobalKey<FormState>();
  @override
  void dispose() { _email.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AuthPage(title: 'Récupérer mon compte', bottom: AuthButton('Envoyer le lien', onPressed: () { if (_form.currentState!.validate()) context.push('/email-sent', extra: _email.text.trim()); }), children: [
    const AuthHero(icon: LucideIcons.mailCheck, title: 'Mot de passe oublié ?', description: 'Saisissez votre adresse e-mail pour recevoir un lien de réinitialisation.'),
    Form(key: _form, child: AuthField(label: 'Adresse e-mail', controller: _email, hint: 'jordan.mbala@email.com', keyboardType: TextInputType.emailAddress, validator: emailValidator)),
  ]);
}
