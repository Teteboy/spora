import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/player_model.dart';
import '../../providers/player_provider.dart';
import '../../providers/messaging_provider.dart';
import '../../widgets/spora_logo.dart';
import '../home/home_screen.dart' show PlayerListTile;
import 'package:badges/badges.dart' as badges;
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Bordered icon tile used in the top bar (Figma header pattern, 44 px).
Widget _headerTile(IconData icon, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: AppDimens.minTouch,
      height: AppDimens.minTouch,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusInput),
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon, size: 26, color: AppColors.textPrimary),
    ),
  );
}

class RecruiterPlayersScreen extends StatefulWidget {
  const RecruiterPlayersScreen({super.key});

  @override
  State<RecruiterPlayersScreen> createState() => _RecruiterPlayersScreenState();
}

class _RecruiterPlayersScreenState extends State<RecruiterPlayersScreen> {
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
                const SporaLogo(height: 24, flat: true),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
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
            actions: [
              Consumer<MessagingProvider>(
                builder: (context, msg, _) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: badges.Badge(
                      showBadge: msg.unreadNotifications > 0,
                      badgeContent: Text(
                        '${msg.unreadNotifications}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 9),
                      ),
                      badgeStyle:
                          const badges.BadgeStyle(badgeColor: AppColors.danger),
                      child: _headerTile(LucideIcons.bell,
                          () => context.push('/notifications')),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _headerTile(
                    LucideIcons.listFilter, () => _showFilterDialog(context)),
              ),
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
                      Expanded(
                          child: _buildQuickStat('156', 'Candidatures',
                              LucideIcons.users, AppColors.primary)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildQuickStat('42', 'Acceptées',
                              LucideIcons.checkCircle2, AppColors.success)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildQuickStat('18', 'En trial',
                              LucideIcons.calendar, AppColors.gold)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Candidats',
                    style: TextStyle(
                      fontFamily: 'TikTok Sans',
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

              final players = provider.recommendedPlayers
                  .where((p) => _matchesFilter(provider, p))
                  .toList();

              if (players.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Aucun candidat dans cette catégorie.',
                      style: AppTextStyles.body(),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingMD),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final player = players[index];
                      return PlayerListTile(player: player)
                          .animate()
                          .fadeIn(duration: 300.ms, delay: (index * 50).ms);
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

  Widget _buildQuickStat(
      String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'TikTok Sans',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'TikTok Sans',
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Local filtering over [PlayerProvider.recommendedPlayers] (mock data).
  bool _matchesFilter(PlayerProvider provider, PlayerModel p) {
    switch (_filter) {
      case 'Favoris':
        return provider.isPlayerSaved(p.id);
      case 'Contactés':
        return p.isPremium;
      case 'Essai':
        return p.highlights.isNotEmpty;
      default:
        return true;
    }
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => RadioGroup<String>(
        groupValue: _filter,
        onChanged: (v) {
          if (v == null) return;
          setState(() => _filter = v);
          Navigator.pop(sheetContext);
        },
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtrer par',
                style: TextStyle(
                  fontFamily: 'TikTok Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _buildFilterOption('Tous', 'Tous les candidats'),
              _buildFilterOption('Favoris', 'Vos candidats favoris'),
              _buildFilterOption('Contactés', 'Candidats contactés'),
              _buildFilterOption('Essai', 'Essai prévu'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOption(String value, String label) {
    return ListTile(
      title: Text(label),
      leading: Radio<String>(value: value),
      onTap: () {
        setState(() => _filter = value);
        Navigator.pop(context);
      },
    );
  }
}
