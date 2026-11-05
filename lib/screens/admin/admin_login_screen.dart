import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'admin_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A01 — Admin sign-in. Split layout: navy trust panel on the left,
/// credentials form on the right. Successful login routes to 2FA.
class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        const form = _LoginForm();
        if (!wide) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.section),
              child: form,
            ),
          );
        }
        return Row(
          children: [
            const SizedBox(width: 640, child: AdminAuthAside()),
            Expanded(child: Center(child: form)),
          ],
        );
      }),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(LucideIcons.lock,
                size: 32, color: AppColors.primary),
            const SizedBox(height: AppDimens.lg),
            Text('Connexion administration',
                style: AppTextStyles.display()),
            const SizedBox(height: AppDimens.sm),
            Text(
              'Utilisez votre compte professionnel autorisé. '
              'Aucun accès par inscription libre.',
              style: AppTextStyles.body(),
            ),
            const SizedBox(height: AppDimens.xl),
            const AdminField(
                label: 'Adresse e-mail professionnelle',
                value: 'amina.diallo@spora.example'),
            const SizedBox(height: AppDimens.lg),
            const AdminField(
                label: 'Mot de passe', value: '••••••••••••'),
            const SizedBox(height: AppDimens.md),
            AdminLink('Mot de passe oublié ?', onTap: () {}),
            const SizedBox(height: AppDimens.lg),
            const AdminBanner(
              title: 'E-mail ou mot de passe incorrect',
              body: 'Vérifiez vos identifiants et réessayez.',
              icon: LucideIcons.shield,
              color: AppColors.danger,
            ),
            const SizedBox(height: AppDimens.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.go('/admin/2fa'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  textStyle: AppTextStyles.button(),
                  padding:
                      const EdgeInsets.symmetric(vertical: AppDimens.lg),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          AppDimens.radiusInput)),
                ),
                child: const Text('Se connecter'),
              ),
            ),
            const SizedBox(height: AppDimens.lg),
            Text(
              'Accès restreint · Session protégée par 2FA. '
              'En cas de difficulté, contactez la personne responsable '
              'des accès.',
              style: AppTextStyles.caption(),
            ),
            const SizedBox(height: AppDimens.lg),
            Text('Données de démonstration · Maquette statique',
                style: AppTextStyles.micro()),
          ],
        ),
      ),
    );
  }
}

/// Shared navy side panel used by the admin auth screens (A01 / A02).
class AdminAuthAside extends StatelessWidget {
  const AdminAuthAside({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy900,
      padding: const EdgeInsets.all(AppDimens.huge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: AppTextStyles.display(color: AppColors.textLight),
              children: const [
                TextSpan(text: 'SP'),
                TextSpan(
                    text: 'O', style: TextStyle(color: AppColors.gold)),
                TextSpan(text: 'RA'),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius:
                  BorderRadius.circular(AppDimens.radiusPill),
            ),
            child: Text('ACCÈS RÉSERVÉ AU PERSONNEL',
                style:
                    AppTextStyles.eyebrow(color: AppColors.primary)),
          ),
          const SizedBox(height: AppDimens.section),
          Text('Le talent mérite un\nenvironnement sûr.',
              style: AppTextStyles.display(color: AppColors.textLight)
                  .copyWith(fontSize: 34, height: 1.3)),
          const SizedBox(height: AppDimens.lg),
          Text(
            'Modérez avec attention. Protégez les joueurs. '
            'Chaque décision compte.',
            style:
                AppTextStyles.bodyLarge(color: AppColors.darkTextSecondary),
          ),
          const SizedBox(height: AppDimens.huge),
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.navy700,
              borderRadius:
                  BorderRadius.circular(AppDimens.radiusCard),
            ),
            child: const Center(
              child: Icon(LucideIcons.goal,
                  size: 56, color: AppColors.darkTextMuted),
            ),
          ),
          const Spacer(),
          Text("SPORA · Console de confiance et d'opérations",
              style:
                  AppTextStyles.caption(color: AppColors.darkTextMuted)),
        ],
      ),
    );
  }
}
