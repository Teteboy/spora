import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/spora_logo.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        title: const Text('Menu',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Column(
          children: [
            // Profile summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(colors: AppColors.primaryGradient),
                borderRadius: BorderRadius.circular(AppConstants.radiusLG),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(auth.currentUser?.avatarUrl ??
                        'https://i.pravatar.cc/80?u=me'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(auth.currentUser?.name ?? 'Joueur SPORA',
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        Text(auth.currentUser?.email ?? '',
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Colors.white70)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: AppColors.goldGradient),
                              borderRadius: BorderRadius.circular(100)),
                          child: const Text('PREMIUM',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 20),
            // Menu groups
            _SettingsGroup(
              title: 'Mon compte',
              items: [
                _SettingsItem(
                    icon: Icons.person_outline,
                    label: 'Mon profil',
                    onTap: () => context.go('/profile')),
                _SettingsItem(
                    icon: Icons.message_outlined,
                    label: 'Messages',
                    onTap: () => context.push('/messages')),
                _SettingsItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () => context.push('/notifications')),
                _SettingsItem(
                    icon: Icons.workspace_premium,
                    label: 'Abonnement Premium',
                    onTap: () => context.push('/premium'),
                    iconColor: AppColors.gold),
                _SettingsItem(
                    icon: Icons.badge_outlined,
                    label: 'Espace Agent',
                    onTap: () => context.push('/agent'),
                    iconColor: AppColors.primary),
                _SettingsItem(
                    icon: Icons.business_center_outlined,
                    label: 'Espace Recruteur',
                    onTap: () => context.push('/recruiter'),
                    iconColor: AppColors.primary),
              ],
            ),
            const SizedBox(height: 16),
            // Dark Mode Toggle
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.dark_mode_outlined,
                          color: AppColors.primary),
                    ),
                    title: const Text('Mode sombre',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w500)),
                    value: themeProvider.isDarkMode,
                    onChanged: (value) => themeProvider.toggleTheme(),
                    activeColor: AppColors.gold,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _SettingsGroup(
              title: 'Découverte',
              items: [
                _SettingsItem(
                    icon: Icons.search,
                    label: 'Rechercher des joueurs',
                    onTap: () => context.go('/search')),
                _SettingsItem(
                    icon: Icons.videocam_outlined,
                    label: 'Explorer les highlights',
                    onTap: () => context.go('/highlights')),
                _SettingsItem(
                    icon: Icons.bookmark_outline,
                    label: 'Joueurs sauvegardés',
                    onTap: () => context.go('/profile')),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsGroup(
              title: 'Application',
              items: [
                _SettingsItem(
                    icon: Icons.language,
                    label: 'Langue',
                    trailing: const Text('Français',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: AppColors.textSecondary)),
                    onTap: () {}),
                _SettingsItem(
                    icon: Icons.dark_mode_outlined,
                    label: 'Mode sombre',
                    trailing: Switch(
                        value: false,
                        onChanged: (_) {},
                        activeColor: AppColors.primary),
                    onTap: () {}),
                _SettingsItem(
                    icon: Icons.lock_outline,
                    label: 'Confidentialité',
                    onTap: () {}),
                _SettingsItem(
                    icon: Icons.help_outline,
                    label: 'Aide & Support',
                    onTap: () {}),
                _SettingsItem(
                    icon: Icons.info_outline,
                    label: 'À propos de SPORA',
                    onTap: () {}),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  auth.logout();
                  context.go('/login');
                },
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text('Se déconnecter',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
            const SizedBox(height: 24),
            const SporaLogo(height: 28),
            const SizedBox(height: 8),
            const Text('Version 1.0.0',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textHint)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;
  const _SettingsGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(title,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5)),
          ),
          ...items.asMap().entries.map((e) => Column(
                children: [
                  e.value,
                  if (e.key < items.length - 1)
                    const Divider(
                        height: 1, indent: 52, color: AppColors.divider),
                ],
              )),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: const Duration(milliseconds: 100));
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? iconColor;

  const _SettingsItem(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.trailing,
      this.iconColor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 18),
      ),
      title: Text(label,
          style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.textPrimary)),
      trailing: trailing ??
          const Icon(Icons.chevron_right, color: AppColors.textHint, size: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
