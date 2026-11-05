import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/spora_images.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/spora_logo.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class RecruiterProfileScreen extends StatelessWidget {
  const RecruiterProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppDimens.screenMargin,
                  AppDimens.sm, AppDimens.screenMargin, AppDimens.sm),
              child: Row(
                children: [
                  const SporaLogo(height: 24, flat: true),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusInput),
                    ),
                    child: const Text(
                      'CLUB',
                      style: TextStyle(
                        fontFamily: 'TikTok Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.spacingMD),
                child: Column(
                  children: [
                    // Profile Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusCard),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: AppColors.border, width: 3),
                            ),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundImage: NetworkImage(
                                  sporaImage('club-avatar', w: 180, h: 180)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user?.name ?? 'Olympique FC',
                            style: const TextStyle(
                              fontFamily: 'TikTok Sans',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Club Professionnel',
                              style: TextStyle(
                                fontFamily: 'TikTok Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.goldDark,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user?.email ?? 'recruteur@olympique.fc',
                            style: const TextStyle(
                              fontFamily: 'TikTok Sans',
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildProfileStat('156', 'Candidats'),
                              Container(
                                  width: 1,
                                  height: 30,
                                  color: AppColors.divider,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20)),
                              _buildProfileStat('12', 'Trials'),
                              Container(
                                  width: 1,
                                  height: 30,
                                  color: AppColors.divider,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20)),
                              _buildProfileStat('8', 'Ans exp.'),
                            ],
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: -0.1, end: 0),

                    const SizedBox(height: 24),

                    // Menu Items
                    _buildMenuItem(
                      context,
                      icon: LucideIcons.building2,
                      title: 'Mon club',
                      subtitle: 'Gérer les informations du club',
                      onTap: () => context.push('/edit-profile'),
                    ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                    _buildMenuItem(
                      context,
                      icon: LucideIcons.users,
                      title: 'Joueurs contactés',
                      subtitle: 'Voir tous les candidats',
                      onTap: () => context.go('/recruiter/players'),
                    ).animate().fadeIn(duration: 300.ms, delay: 150.ms),
                    _buildMenuItem(
                      context,
                      icon: LucideIcons.calendar,
                      title: 'Essais planifiés',
                      subtitle: 'Gérer les trials',
                      onTap: () => context.push('/opportunities/mine'),
                    ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
                    _buildMenuItem(
                      context,
                      icon: LucideIcons.bell,
                      title: 'Notifications',
                      subtitle: 'Gérer les notifications',
                      onTap: () => context.push('/settings/notifications'),
                    ).animate().fadeIn(duration: 300.ms, delay: 250.ms),
                    _buildMenuItem(
                      context,
                      icon: LucideIcons.shieldCheck,
                      title: 'Sécurité',
                      subtitle: 'Mot de passe et confidentialité',
                      onTap: () => context.push('/settings/security'),
                    ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
                    _buildMenuItem(
                      context,
                      icon: LucideIcons.helpCircle,
                      title: 'Aide et support',
                      subtitle: 'Centre d\'aide',
                      onTap: () => context.push('/help'),
                    ).animate().fadeIn(duration: 300.ms, delay: 350.ms),
                    _buildMenuItem(
                      context,
                      icon: LucideIcons.info,
                      title: 'À propos',
                      subtitle: 'Version 1.0.0',
                      onTap: () => context.push('/help'),
                    ).animate().fadeIn(duration: 300.ms, delay: 400.ms),

                    const SizedBox(height: 24),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          authProvider.logout();
                          context.go('/login');
                        },
                        icon:
                            const Icon(LucideIcons.logOut, color: Colors.white),
                        label: const Text('Déconnexion'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 450.ms),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'TikTok Sans',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'TikTok Sans',
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'TikTok Sans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'TikTok Sans',
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(LucideIcons.chevronRight,
            color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
