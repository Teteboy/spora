import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/player_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../data/mock_data.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final player = MockData.trendingPlayers.first;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () => context.go('/settings'),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.primaryGradient,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundImage: NetworkImage(auth.currentUser?.avatarUrl ?? 'https://i.pravatar.cc/100?u=profile'),
                          ),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        auth.currentUser?.name ?? player.fullName,
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      Text(
                        player.primaryPosition,
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMD),
              child: Column(
                children: [
                  // Analytics
                  _buildAnalytics(player.profileViews, player.followers, player.highlights.length),
                  const SizedBox(height: 16),
                  // Premium banner
                  if (!player.isPremium) _buildPremiumBanner(context),
                  if (player.isPremium) _buildPremiumBadge(),
                  const SizedBox(height: 16),
                  // Saved players
                  _buildSavedSection(context),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalytics(int views, int followers, int videos) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(child: _AnalyticItem(value: '$views', label: 'Vues profil', icon: Icons.visibility_outlined, color: AppColors.primaryLight)),
          _Divider(),
          Expanded(child: _AnalyticItem(value: '$followers', label: 'Abonnés', icon: Icons.people_outline, color: AppColors.success)),
          _Divider(),
          Expanded(child: _AnalyticItem(value: '$videos', label: 'Highlights', icon: Icons.videocam_outlined, color: AppColors.gold)),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildPremiumBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/premium'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)]),
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.goldGradient), shape: BoxShape.circle),
              child: const Icon(Icons.star, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Passez en Premium', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.goldDark)),
                  Text('Highlights illimités, badge PRO et plus', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.gold),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildPremiumBadge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.primaryGradient),
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified, color: Colors.white, size: 28),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Compte Premium Actif', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              Text('Tous les avantages débloqués', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white70)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildSavedSection(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusLG),
            boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Joueurs sauvegardés', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              if (provider.savedPlayers.isEmpty)
                const Text('Aucun joueur sauvegardé', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondary))
              else
                ...provider.savedPlayers.map((p) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(backgroundImage: NetworkImage(p.avatarUrl ?? 'https://i.pravatar.cc/60?u=${p.id}')),
                  title: Text(p.fullName, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(p.primaryPosition, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary)),
                  trailing: IconButton(
                    icon: const Icon(Icons.bookmark, color: AppColors.gold),
                    onPressed: () => provider.toggleSavePlayer(p),
                  ),
                  onTap: () => context.push('/player/${p.id}', extra: p),
                )),
            ],
          ),
        );
      },
    );
  }
}

class _AnalyticItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _AnalyticItem({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.textSecondary), textAlign: TextAlign.center),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 50, color: AppColors.divider);
  }
}

