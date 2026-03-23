import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/player_provider.dart';
import '../../providers/messaging_provider.dart';
import '../../widgets/player_card.dart';
import '../../widgets/spora_logo.dart';
import 'package:badges/badges.dart' as badges;

class RecruiterDashboardScreen extends StatefulWidget {
  const RecruiterDashboardScreen({super.key});

  @override
  State<RecruiterDashboardScreen> createState() =>
      _RecruiterDashboardScreenState();
}

class _RecruiterDashboardScreenState extends State<RecruiterDashboardScreen> {
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsSection(context),
                  const SizedBox(height: 24),
                  _buildScoutSection(context),
                  const SizedBox(height: 24),
                  _buildOpenTrials(context),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floating: true,
      pinned: false,
      elevation: 0,
      title: Row(
        children: [
          const SporaLogo(height: 32),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'CLUB',
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
                  icon: Icon(Icons.notifications_outlined,
                      color: Theme.of(context).iconTheme.color),
                  onPressed: () => context.push('/notifications'),
                ),
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.add_circle_outline,
              color: Theme.of(context).iconTheme.color),
          onPressed: () => context.push('/recruiter/create-trial'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistiques',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.headlineSmall?.color,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.people_outline,
                label: 'Candidatures',
                value: '156',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.check_circle_outline,
                label: 'Acceptées',
                value: '42',
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.event,
                label: 'Trials actifs',
                value: '3',
                color: AppColors.gold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.visibility,
                label: 'Vues totales',
                value: '8.5K',
                color: AppColors.info,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.headlineMedium?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Joueurs Recommandés',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/recruiter/players'),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Consumer<PlayerProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final players = provider.recommendedPlayers.take(3).toList();
            return Column(
              children: players
                  .map((player) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PlayerCard(
                          player: player,
                          onTap: () => context.push('/player/${player.id}'),
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 100.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildOpenTrials(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trials Ouverts',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/recruiter/trials'),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTrialCard(
          context,
          title: 'Stage de détection - FC Barcelona',
          date: '15 Mars 2026',
          location: 'Barcelone, Espagne',
          applicants: 45,
          maxApplicants: 50,
        ),
        _buildTrialCard(
          context,
          title: 'Académie de football - Paris Saint-Germain',
          date: '20 Avril 2026',
          location: 'Paris, France',
          applicants: 32,
          maxApplicants: 40,
        ),
        _buildTrialCard(
          context,
          title: 'Trial pour gardiens - Chelsea FC',
          date: '5 Mai 2026',
          location: 'Londres, Royaume-Uni',
          applicants: 18,
          maxApplicants: 20,
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 200.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildTrialCard(
    BuildContext context, {
    required String title,
    required String date,
    required String location,
    required int applicants,
    required int maxApplicants,
  }) {
    final progress = applicants / maxApplicants;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Actif',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today,
                  size: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color),
              const SizedBox(width: 6),
              Text(
                date,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.location_on,
                  size: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  location,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(
                      progress > 0.8 ? AppColors.warning : AppColors.primary,
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$applicants/$maxApplicants',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
