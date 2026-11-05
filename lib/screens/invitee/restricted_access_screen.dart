import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shown to invitees (guests) hitting a restricted feature — matches the
/// Figma "découvrir-accès-refusé" state. Deep links are redirected here by
/// the router; in-app actions can also push it directly.
class RestrictedAccessScreen extends StatelessWidget {
  const RestrictedAccessScreen({super.key, this.feature});

  /// Optional name of the blocked feature ("la messagerie", …).
  final String? feature;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.section),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryTint,
                ),
                child: const Icon(LucideIcons.lock,
                    size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: AppDimens.section),
              Text('Accès réservé',
                  style: AppTextStyles.display(), textAlign: TextAlign.center),
              const SizedBox(height: AppDimens.md),
              Text(
                feature == null
                    ? 'Votre compte invité donne accès à la découverte des talents et aux highlights. Créez un compte complet pour débloquer cette fonctionnalité.'
                    : 'Votre compte invité ne donne pas accès à $feature. Créez un compte complet pour débloquer cette fonctionnalité.',
                style: AppTextStyles.bodyLarge(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimens.section),
              _perk(LucideIcons.messageCircle,
                  'Échanger avec les joueurs, clubs et agents'),
              _perk(LucideIcons.briefcase,
                  'Postuler aux opportunités et publier les vôtres'),
              _perk(LucideIcons.bookmark,
                  'Constituer votre liste de talents'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) context.go('/role');
                  },
                  child: const Text('Créer un compte complet'),
                ),
              ),
              const SizedBox(height: AppDimens.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go('/invitee/discover'),
                  child: const Text('Retour à la découverte'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _perk(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.md),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusInput),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(child: Text(label, style: AppTextStyles.body())),
        ],
      ),
    );
  }
}
