import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'admin_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A19 — Shared administration states (loading / empty / error).

/// "Chargement de la file" — spinner + skeleton lines.
class AdminLoading extends StatelessWidget {
  const AdminLoading({super.key, this.message = 'Chargement de la file'});
  final String message;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
                strokeWidth: 2.5, color: AppColors.primary),
          ),
          const SizedBox(height: AppDimens.lg),
          Text(message, style: AppTextStyles.h2()),
          const SizedBox(height: AppDimens.sm),
          Text('Nous récupérons les dossiers de modération.',
              style: AppTextStyles.body()),
          const SizedBox(height: AppDimens.lg),
          const _Skeleton(width: 220),
          const SizedBox(height: AppDimens.sm),
          const _Skeleton(width: 260),
          const SizedBox(height: AppDimens.lg),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius:
                  BorderRadius.circular(AppDimens.radiusInput),
            ),
            child: Text('Chargement…', style: AppTextStyles.body()),
          ),
        ],
      ),
    );
  }
}

/// "La file est à jour" — success check + refresh action.
class AdminEmpty extends StatelessWidget {
  const AdminEmpty({super.key, required this.message, this.onRefresh});
  final String message;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.checkCircle,
              size: 28, color: AppColors.primary),
          const SizedBox(height: AppDimens.lg),
          Text(message, style: AppTextStyles.h2()),
          const SizedBox(height: AppDimens.sm),
          Text(
            'Aucune vidéo en attente. Les nouvelles soumissions '
            'apparaîtront ici.',
            style: AppTextStyles.body(),
          ),
          const SizedBox(height: AppDimens.lg),
          AdminOutlineButton('Actualiser', onPressed: onRefresh),
        ],
      ),
    );
  }
}

/// "Impossible de charger les dossiers" — error icon + retry.
class AdminError extends StatelessWidget {
  const AdminError({super.key, this.message, this.onRetry});
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.alertCircle,
              size: 28, color: AppColors.danger),
          const SizedBox(height: AppDimens.lg),
          Text(message ?? 'Impossible de charger les dossiers',
              style: AppTextStyles.h2()),
          const SizedBox(height: AppDimens.sm),
          Text(
            'Vos décisions n\'ont pas été modifiées. '
            'Réessayez dans un instant.',
            style: AppTextStyles.body(),
          ),
          const SizedBox(height: AppDimens.lg),
          AdminOutlineButton('Réessayer', onPressed: onRetry),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 14,
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
    );
  }
}
