import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// Reusable state widgets for Discover / Home / Search —
// matching Figma frames: chargement, aucun résultat, hors connexion,
// erreur, actualisation, trop de tentatives, accès refusé.

/// Skeleton blocks while the feed is loading.
class DiscoverLoading extends StatelessWidget {
  const DiscoverLoading({super.key});

  @override
  Widget build(BuildContext context) {
    Widget block(double h, [double? w]) => Shimmer.fromColors(
          baseColor: AppColors.shimmerBase,
          highlightColor: AppColors.shimmerHighlight,
          child: Container(
            height: h,
            width: w ?? double.infinity,
            decoration: BoxDecoration(
              color: AppColors.shimmerBase,
              borderRadius: BorderRadius.circular(AppDimens.radiusCard),
            ),
          ),
        );

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.screenMargin, vertical: AppDimens.lg),
      children: [
        block(300),
        const SizedBox(height: AppDimens.lg),
        block(18),
        const SizedBox(height: AppDimens.sm),
        block(18, 200),
        const SizedBox(height: AppDimens.md),
        block(56),
        const SizedBox(height: AppDimens.section),
        block(16),
        const SizedBox(height: AppDimens.sm),
        block(16, 220),
        const SizedBox(height: AppDimens.md),
        block(56),
      ],
    );
  }
}

/// "Actualisation en cours…" inline row shown above refreshed results.
class DiscoverRefreshing extends StatelessWidget {
  const DiscoverRefreshing({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.sm),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.primary),
          ),
          const SizedBox(width: AppDimens.sm),
          Text('Actualisation en cours…',
              style: AppTextStyles.bodyStrong(color: AppColors.primary)),
        ],
      ),
    );
  }
}

/// "Vous êtes hors connexion" banner shown above cached profiles.
class OfflineBanner extends StatelessWidget {
  final String? lastUpdate;
  const OfflineBanner({super.key, this.lastUpdate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.wifiOff,
              size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vous êtes hors connexion',
                    style: AppTextStyles.bodyStrong()),
                const SizedBox(height: AppDimens.xxs),
                Text(
                  'Profils en cache · Dernière mise à jour à '
                  '${lastUpdate ?? '09:32'}. Les nouvelles recherches '
                  'seront disponibles à la reconnexion.',
                  style: AppTextStyles.body(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen offline state with retry.
class OfflineState extends StatelessWidget {
  final VoidCallback? onRetry;
  const OfflineState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return _StateScaffold(
      icon: LucideIcons.wifiOff,
      title: 'Hors connexion',
      message:
          'Vérifiez votre connexion internet puis réessayez. Vos filtres sont conservés.',
      buttonLabel: 'Réessayer',
      onPressed: onRetry,
    );
  }
}

/// "Aucun résultat"
class EmptyResultsState extends StatelessWidget {
  final VoidCallback? onReset;
  const EmptyResultsState({super.key, this.onReset});

  @override
  Widget build(BuildContext context) {
    return _StateScaffold(
      icon: LucideIcons.search,
      title: 'Aucun résultat',
      message:
          'Essayez d’élargir vos filtres pour découvrir plus de talents.',
      buttonLabel: 'Réinitialiser les filtres',
      onPressed: onReset,
    );
  }
}

/// "Le chargement a échoué"
class ErrorState extends StatelessWidget {
  final VoidCallback? onRetry;
  const ErrorState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return _StateScaffold(
      icon: LucideIcons.alertCircle,
      title: 'Le chargement a échoué',
      message:
          'Vos filtres sont conservés. Réessayez dans un instant.',
      buttonLabel: 'Réessayer',
      onPressed: onRetry,
    );
  }
}

/// "Un peu de patience" — too many attempts, retry disabled.
class RateLimitedState extends StatelessWidget {
  final String retryLabel;
  const RateLimitedState({super.key, this.retryLabel = 'Réessayer dans 01:00'});

  @override
  Widget build(BuildContext context) {
    return _StateScaffold(
      icon: LucideIcons.timer,
      title: 'Un peu de patience',
      message: 'Trop de tentatives, réessayez dans 1 minute',
      buttonLabel: retryLabel,
      onPressed: null,
      footer: 'Vos filtres sont conservés.',
    );
  }
}

/// "Accès refusé" — unverified user searching minors.
class AccessDeniedState extends StatelessWidget {
  final VoidCallback? onVerify;
  const AccessDeniedState({super.key, this.onVerify});

  @override
  Widget build(BuildContext context) {
    return _StateScaffold(
      icon: LucideIcons.shield,
      title: 'Accès refusé',
      message:
          'La découverte des joueurs est réservée aux agents et clubs '
          'vérifiés. Les profils mineurs nécessitent le consentement du tuteur.',
      buttonLabel: 'Voir mon statut de vérification',
      onPressed: onVerify,
    );
  }
}

class _StateScaffold extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback? onPressed;
  final String? footer;

  const _StateScaffold({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                  color: AppColors.primaryTint, shape: BoxShape.circle),
              child: Icon(icon, size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: AppDimens.xxl),
            Text(title,
                style: AppTextStyles.h1(), textAlign: TextAlign.center),
            const SizedBox(height: AppDimens.md),
            Text(message,
                style: AppTextStyles.bodyLarge(
                    color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: AppDimens.xxl),
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: onPressed != null
                      ? const LinearGradient(
                          colors: AppColors.primaryGradient)
                      : null,
                  color: onPressed == null ? AppColors.muted : null,
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusPill),
                ),
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: AppColors.textMuted,
                    textStyle: AppTextStyles.button(),
                    padding: const EdgeInsets.symmetric(
                        vertical: AppDimens.md),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppDimens.radiusPill)),
                  ),
                  child: Text(buttonLabel),
                ),
              ),
            ),
            if (footer != null) ...[
              const SizedBox(height: AppDimens.lg),
              Text(footer!, style: AppTextStyles.caption()),
            ],
          ],
        ),
      ),
    );
  }
}
