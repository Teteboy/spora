import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'auth_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// /account-suspended — "Complément mobile · Compte suspendu".
class AccountSuspendedScreen extends StatelessWidget {
  const AccountSuspendedScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      AuthPage(title: 'Compte suspendu', back: '/login', children: [
        const AuthHero(
          icon: LucideIcons.shieldAlert,
          title: 'L’accès à votre compte est suspendu.',
          description: '',
        ),
        const AuthNotice(
            'Impossible de vous connecter\nConsultez la notification reçue ou contactez le support pour demander un examen.',
            error: true),
        AuthButton('Contacter le support',
            onPressed: () => context.push('/help')),
        const SizedBox(height: 12),
        AuthButton('Retour à l’accueil de connexion',
            secondary: true, onPressed: () => context.go('/login')),
      ]);
}
