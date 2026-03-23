import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/player_provider.dart';
import '../../providers/messaging_provider.dart';
import '../../widgets/player_card.dart';
import '../../widgets/spora_logo.dart';
import 'package:badges/badges.dart' as badges;

class AgentPlayersScreen extends StatefulWidget {
  const AgentPlayersScreen({super.key});

  @override
  State<AgentPlayersScreen> createState() => _AgentPlayersScreenState();
}

class _AgentPlayersScreenState extends State<AgentPlayersScreen> {
  String _filter = 'Tous';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlayerProvider>().loadRecommendedPlayers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.backgroundLight,
            floating: true,
            pinned: false,
            elevation: 0,
            title: Row(
              children: [
                const SporaLogo(height: 28),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'AGENT',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Consumer<MessagingProvider>(
                builder: (context, msg, _) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: badges.Badge(
                      showBadge: msg.unreadNotifications > 0,
                      badgeContent: Text(
                        '${msg.unreadNotifications}',
                        style: const TextStyle(color: Colors.white, fontSize: 9),
                      ),
                      badgeStyle: const badges.BadgeStyle(badgeColor: AppColors.gold),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                        onPressed: () => context.push('/notifications'),
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.filter_list, color: AppColors.textPrimary),
                onPressed: () => _showFilterDialog(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row
                  Row(
                    children: [
                      Expanded(child: _buildQuickStat('24', 'Joueurs', Icons.people, AppColors.primary)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildQuickStat('8', 'Favoris', Icons.star, AppColors.gold)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildQuickStat('3', 'Contactés', Icons.message, AppColors.success)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  Text(
                    'Mes Joueurs',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          Consumer<PlayerProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final players = provider.recommendedPlayers;

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMD),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final player = players[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PlayerCard(
                          player: player,
                          onTap: () => context.push('/player/${player.id}'),
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms);
                    },
                    childCount: players.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrer par',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _buildFilterOption('Tous', 'Tous les joueurs'),
            _buildFilterOption('Favoris', 'Vos joueurs favoris'),
            _buildFilterOption('Contactés', 'Joueurs contactés'),
            _buildFilterOption('Nouveau', 'Nouveaux profils'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String value, String label) {
    return ListTile(
      title: Text(label),
      leading: Radio<String>(
        value: value,
        groupValue: _filter,
        onChanged: (v) {
          setState(() => _filter = v!);
          Navigator.pop(context);
        },
      ),
      onTap: () {
        setState(() => _filter = value);
        Navigator.pop(context);
      },
    );
  }
}
