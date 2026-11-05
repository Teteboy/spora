import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'auth_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PasswordUpdatedScreen extends StatelessWidget {
  const PasswordUpdatedScreen({super.key});
  @override
  Widget build(BuildContext context) => AuthPage(title: 'Votre compte', bottom: AuthButton('Retour à la connexion', onPressed: () => context.go('/login')), children: const [
    AuthHero(icon: LucideIcons.checkCircle, title: 'Mot de passe mis à jour', description: 'Vous pouvez maintenant vous connecter avec votre nouveau mot de passe.'),
  ]);
}
