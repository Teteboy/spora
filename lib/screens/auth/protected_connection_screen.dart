import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'auth_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// /protected-connection — "Complément mobile · Connexion protégée".
/// Extra verification: new attempts are blocked for 15 minutes after
/// 5 failed logins.
class ProtectedConnectionScreen extends StatefulWidget {
  const ProtectedConnectionScreen({super.key});
  @override
  State<ProtectedConnectionScreen> createState() =>
      _ProtectedConnectionScreenState();
}

class _ProtectedConnectionScreenState extends State<ProtectedConnectionScreen> {
  static const int _lockSeconds = 15 * 60;
  int _remaining = _lockSeconds;
  Timer? _timer;
  late final DateTime _retryAt =
      DateTime.now().add(const Duration(seconds: _lockSeconds));

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 1) {
        t.cancel();
        setState(() => _remaining = 0);
      } else {
        setState(() => _remaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _countdown {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _retryLabel {
    final h = _retryAt.hour.toString().padLeft(2, '0');
    final m = _retryAt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) =>
      AuthPage(title: 'Connexion protégée', back: '/login', children: [
        const AuthHero(
          icon: LucideIcons.shieldAlert,
          title: 'Une courte pause pour votre sécurité.',
          description: '',
        ),
        AuthNotice(
            '5 tentatives échouées · 15 minutes\nLes nouvelles tentatives sont bloquées pendant 15 minutes. Vous pourrez réessayer à $_retryLabel.',
            error: true),
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
              AuthField(
                label: 'E-mail',
                controller: TextEditingController(),
                hint: 'jordan.mbala@email.com',
                keyboardType: TextInputType.emailAddress,
                enabled: false,
              ),
              AuthField(
                label: 'Mot de passe',
                controller: TextEditingController(),
                password: true,
                enabled: false,
              ),
              AuthButton(
                _remaining > 0 ? 'Réessayer dans $_countdown' : 'Réessayer',
                onPressed: _remaining > 0
                    ? null
                    : () => context.go('/login'),
              ),
              const AuthLink('Mot de passe oublié ?', '/forgot-password'),
            ],
          ),
        ),
        AuthButton('Retour à l’accueil de connexion',
            secondary: true, onPressed: () => context.go('/login')),
      ]);
}
