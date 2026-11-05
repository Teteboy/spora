import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'admin_login_screen.dart';
import 'admin_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A02 — Two-factor verification: six digit boxes then access grant.
class Admin2faScreen extends StatelessWidget {
  const Admin2faScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        const form = _TwoFactorForm();
        if (!wide) {
          return const SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppDimens.section),
              child: form,
            ),
          );
        }
        return const Row(
          children: [
            SizedBox(width: 640, child: AdminAuthAside()),
            Expanded(child: Center(child: form)),
          ],
        );
      }),
    );
  }
}

class _TwoFactorForm extends StatelessWidget {
  const _TwoFactorForm();

  static const _digits = ['2', '4', '8', '9', '1', '6'];

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
            const Icon(LucideIcons.shieldCheck,
                size: 32, color: AppColors.primary),
            const SizedBox(height: AppDimens.lg),
            Text('Vérification en deux étapes',
                style: AppTextStyles.display()),
            const SizedBox(height: AppDimens.sm),
            Text(
              "Saisissez le code à six chiffres de votre application "
              "d'authentification.",
              style: AppTextStyles.body(),
            ),
            const SizedBox(height: AppDimens.lg),
            Text('amina.diallo@spora.example',
                style: AppTextStyles.bodyStrong()),
            const SizedBox(height: AppDimens.lg),
            Row(
              children: [
                for (final d in _digits) ...[
                  _DigitBox(digit: d),
                  if (d != _digits.last)
                    const SizedBox(width: AppDimens.md),
                ],
              ],
            ),
            const SizedBox(height: AppDimens.xl),
            const AdminBanner(
              title: 'Code invalide ou expiré',
              body: 'Utilisez le nouveau code affiché dans votre '
                  'application.',
              icon: LucideIcons.shield,
              color: AppColors.danger,
            ),
            const SizedBox(height: AppDimens.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.go('/admin/dashboard'),
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
                child: const Text('Vérifier et accéder'),
              ),
            ),
            const SizedBox(height: AppDimens.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  textStyle:
                      AppTextStyles.button(color: AppColors.textPrimary),
                  side: const BorderSide(color: AppColors.border),
                  padding:
                      const EdgeInsets.symmetric(vertical: AppDimens.lg),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          AppDimens.radiusInput)),
                ),
                child: const Text('Utiliser un code de récupération'),
              ),
            ),
            const SizedBox(height: AppDimens.lg),
            AdminLink('← Revenir à la connexion',
                onTap: () => context.go('/admin/login')),
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

class _DigitBox extends StatelessWidget {
  const _DigitBox({required this.digit});
  final String digit;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.15,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusInput),
            border: Border.all(color: AppColors.danger),
          ),
          child: Text(digit, style: AppTextStyles.h1()),
        ),
      ),
    );
  }
}
