import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Minimal profile tab for invitees: identity, what they can see,
/// upgrade CTA and logout. Full account features live behind the
/// router guard (/restricted).
class InviteeProfileScreen extends StatelessWidget {
  const InviteeProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.screenMargin),
          children: [
            Text('Profil', style: AppTextStyles.display()),
            const SizedBox(height: AppDimens.section),
            Container(
              padding: const EdgeInsets.all(AppDimens.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryTint,
                    backgroundImage: user?.avatarUrl == null
                        ? null
                        : CachedNetworkImageProvider(user!.avatarUrl!),
                    child: user?.avatarUrl == null
                        ? const Icon(LucideIcons.user,
                            color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? 'Invité',
                            style: AppTextStyles.h2()),
                        const SizedBox(height: AppDimens.xs),
                        Text(user?.email ?? '',
                            style: AppTextStyles.caption(
                                color: AppColors.textMuted)),
                        const SizedBox(height: AppDimens.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.sm,
                              vertical: AppDimens.xs),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTint,
                            borderRadius:
                                BorderRadius.circular(AppDimens.radiusPill),
                          ),
                          child: Text('Compte invité',
                              style: AppTextStyles.micro(
                                      color: AppColors.primary)
                                  .copyWith(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.section),

            // Upgrade card
            Container(
              padding: const EdgeInsets.all(AppDimens.cardPadding),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppDimens.radiusCard),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Passez à un compte complet',
                      style:
                          AppTextStyles.h2(color: AppColors.textLight)),
                  const SizedBox(height: AppDimens.sm),
                  Text(
                    'Messagerie, opportunités, listes de talents et publication de highlights vous attendent.',
                    style: AppTextStyles.body(
                        color: AppColors.textLight
                            .withValues(alpha: 0.85)),
                  ),
                  const SizedBox(height: AppDimens.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.primary,
                      ),
                      onPressed: () async {
                        await context.read<AuthProvider>().logout();
                        if (context.mounted) context.go('/role');
                      },
                      child: const Text('Créer un compte'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.section),

            _tile(
              icon: LucideIcons.settings,
              label: 'Paramètres',
              onTap: () => context.push('/settings'),
            ),
            _tile(
              icon: LucideIcons.circleHelp,
              label: 'Aide et FAQ',
              onTap: () => context.push('/help'),
            ),
            _tile(
              icon: LucideIcons.logOut,
              label: 'Se déconnecter',
              danger: true,
              onTap: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) context.go('/welcome');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    final color = danger ? AppColors.danger : AppColors.textPrimary;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.sm),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.cardPadding),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: AppDimens.md),
                Expanded(
                    child:
                        Text(label, style: AppTextStyles.bodyStrong(color: color))),
                const Icon(LucideIcons.chevronRight,
                    size: 18, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
