import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'auth_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// /email-confirmed — "Complément mobile · E-mail confirmé".
class EmailConfirmedScreen extends StatelessWidget {
  const EmailConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final email = auth.currentUser?.email ?? '';
    final nextRoute = switch (auth.selectedUserType) {
      UserType.agent => '/onboarding/agent',
      UserType.recruiter => '/onboarding/club',
      _ => '/onboarding/player',
    };
    return AuthPage(title: 'E-mail confirmé', back: '/login', children: [
      const SizedBox(height: 40),
      const Center(
        child: Icon(LucideIcons.mailCheck,
            size: 64, color: AppColors.primary),
      ),
      const SizedBox(height: 20),
      Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.green.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text('Adresse confirmée',
              style: AppTextStyles.bodyStrong(color: AppColors.clubGreen)),
        ),
      ),
      const SizedBox(height: 24),
      Center(
          child: Text('Votre e-mail est vérifié.',
              style: AppTextStyles.display(),
              textAlign: TextAlign.center)),
      if (email.isNotEmpty) ...[
        const SizedBox(height: 12),
        Center(child: Text(email, style: AppTextStyles.bodyLarge())),
      ],
      const SizedBox(height: 24),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('La suite de votre parcours', style: AppTextStyles.h2()),
            const SizedBox(height: 12),
            Text(
              'Vous pouvez maintenant poursuivre votre inscription, publier et envoyer des messages selon les droits de votre compte.',
              style: AppTextStyles.bodyLarge(),
            ),
            const SizedBox(height: 12),
            const AuthNotice(
                'E-mail confirmé ≠ profil Vérifié\nLe badge professionnel est accordé séparément par l’administration. Premium est un abonnement distinct.'),
          ],
        ),
      ),
      const SizedBox(height: 16),
      AuthButton('Continuer mon inscription',
          onPressed: () => context.go(nextRoute)),
    ]);
  }
}
