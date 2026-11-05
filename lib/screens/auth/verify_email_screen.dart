import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'auth_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key, this.email});
  final String? email;
  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    final address = email ?? (extra is String ? extra : 'jordan.mbala@email.com');
    return AuthPage(title: 'Vérifier mon e-mail', bottom: AuthButton('Renvoyer l’e-mail', onPressed: () => context.push('/email-sent', extra: address)), children: [
      AuthHero(icon: LucideIcons.mailCheck, title: 'Une dernière vérification', description: 'Confirmez $address avant de publier une vidéo ou d’envoyer un message.'),
      const AuthNotice('Consultation disponible\nVous pouvez continuer à découvrir les talents. Publication et messagerie restent bloquées.'),
      AuthButton('J’ai vérifié mon e-mail', secondary: true, onPressed: () => context.push('/email-confirmed', extra: address)),
    ]);
  }
}
