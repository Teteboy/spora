import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/messaging_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/spora_logo.dart';
import '../../widgets/player_card.dart';
import '../../widgets/video_card.dart';
import 'package:badges/badges.dart' as badges;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlayerProvider>().loadHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroSection(context),
                  const SizedBox(height: 24),
                  _buildHowItWorks(context),
                  const SizedBox(height: 24),
                  _buildTrendingPlayers(context),
                  const SizedBox(height: 24),
                  _buildLatestHighlights(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundLight,
      floating: true,
      pinned: false,
      elevation: 0,
      title: const SporaLogo(height: 36),
      actions: [
        Consumer<MessagingProvider>(
          builder: (context, msg, _) {
            return Padding(
              padding: const EdgeInsets.only(right: 16),
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
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEEF2FF), Color(0xFFDEEBFF), Color(0xFFBFD7FF)],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Mettez en ',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    TextSpan(
                      text: 'Lumière',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                    TextSpan(
                      text: '\nVos Talents',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 180,
                child: Text(
                  'La plateforme mobile n°1 pour les joueurs, clubs et recruteurs',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () => context.go('/onboarding'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    ),
                    child: const Text(
                      'Créer mon profil',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => context.go('/highlights'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    ),
                    child: const Text(
                      'Explorer les Highlights',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              'assets/images/spora_logo.jpeg',
              width: 90,
              height: 90,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.sports_soccer, size: 70, color: AppColors.primary),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, duration: 500.ms);
  }

  Widget _buildHowItWorks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comment ça marche ?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _HowItWorksCard(
                icon: Icons.person_add_outlined,
                title: '1. Crée ton profil',
                subtitle: '• Performances',
                iconBgColor: const Color(0xFFFFF7ED),
                iconColor: AppColors.gold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _HowItWorksCard(
                icon: Icons.play_circle_outline,
                title: '2. Ajoute tes highlights',
                subtitle: '• Poste tes topsportiers',
                iconBgColor: const Color(0xFFEFF6FF),
                iconColor: AppColors.primaryLight,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildTrendingPlayers(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Talents du Moment',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (provider.isLoading)
              SizedBox(
                height: 240,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, __) => _ShimmerCard(width: 160, height: 240),
                ),
              )
            else
              SizedBox(
                height: 260,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.trendingPlayers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final player = provider.trendingPlayers[i];
                    return PlayerCard(
                      player: player,
                      onTap: () => context.push('/player/${player.id}', extra: player),
                      onSave: () => provider.toggleSavePlayer(player),
                      isSaved: provider.isPlayerSaved(player.id),
                    ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: i * 80));
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLatestHighlights(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Derniers highlights',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    _NavBtn(icon: Icons.chevron_left),
                    const SizedBox(width: 4),
                    _NavBtn(icon: Icons.chevron_right),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (provider.latestHighlights.isEmpty)
              const SizedBox(height: 160, child: Center(child: Text('Aucun highlight pour le moment', style: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary))))
            else
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.latestHighlights.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final video = provider.latestHighlights[i];
                    return VideoCard(
                      video: video,
                      onTap: () {},
                    ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: i * 100));
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _HowItWorksCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBgColor;
  final Color iconColor;

  const _HowItWorksCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text(subtitle, style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  const _NavBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 16, color: AppColors.textSecondary),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final double width;
  final double height;
  const _ShimmerCard({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1.seconds, color: AppColors.shimmerHighlight);
  }
}
