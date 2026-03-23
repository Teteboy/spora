import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../models/player_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../data/mock_data.dart';

class PlayerProfileScreen extends StatelessWidget {
  final PlayerModel? player;
  const PlayerProfileScreen({super.key, this.player});

  @override
  Widget build(BuildContext context) {
    final p = player ?? MockData.trendingPlayers.first;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, p),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfo(p),
                  const SizedBox(height: 16),
                  _buildPhysical(p),
                  const SizedBox(height: 16),
                  _buildStats(p),
                  const SizedBox(height: 16),
                  _buildHighlights(context, p),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/chat/agent_1', extra: {'name': p.fullName, 'avatar': p.avatarUrl, 'role': 'Joueur'}),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.message_outlined, color: Colors.white),
        label: const Text('Contacter', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, PlayerModel p) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              p.avatarUrl ?? 'https://i.pravatar.cc/400?u=${p.id}',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryGradient)),
                child: const Icon(Icons.person, size: 80, color: Colors.white54),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.2), Colors.black.withValues(alpha: 0.6)],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: NetworkImage(p.avatarUrl ?? 'https://i.pravatar.cc/100?u=${p.id}'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(p.fullName, style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                            if (p.isPremium) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.goldGradient), borderRadius: BorderRadius.circular(100)),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [Icon(Icons.star, color: Colors.white, size: 10), SizedBox(width: 2), Text('PRO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'Poppins'))],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(p.primaryPosition, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.white70)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.sports_soccer, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text(p.currentClub, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo(PlayerModel p) {
    return _SectionCard(
      title: 'Informations générales',
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          _InfoChip(icon: Icons.cake_outlined, label: '${p.age} ans'),
          _InfoChip(icon: Icons.flag_outlined, label: p.nationality),
          _InfoChip(icon: Icons.location_on_outlined, label: p.city),
          _InfoChip(icon: Icons.sports_soccer, label: p.dominantFoot == 'Droite' ? 'Pied droit' : p.dominantFoot == 'Gauche' ? 'Pied gauche' : 'Bivalent'),
          _InfoChip(icon: Icons.work_history_outlined, label: '${p.yearsOfExperience} ans exp.'),
        ],
      ),
    );
  }

  Widget _buildPhysical(PlayerModel p) {
    return _SectionCard(
      title: 'Attributs physiques',
      child: Row(
        children: [
          Expanded(child: _StatBox(label: 'Taille', value: '${(p.height * 100).toInt()} cm')),
          Expanded(child: _StatBox(label: 'Poids', value: '${p.weight.toInt()} kg')),
          Expanded(child: _StatBox(label: 'Pied', value: p.dominantFoot)),
          Expanded(child: _StatBox(label: 'Division', value: p.leagueDivision.replaceAll('Division ', 'D'))),
        ],
      ),
    );
  }

  Widget _buildStats(PlayerModel p) {
    final stats = p.stats;
    return _SectionCard(
      title: 'Statistiques',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _StatBox(label: 'Matchs', value: '${stats.matchesPlayed}')),
              Expanded(child: _StatBox(label: 'Buts', value: '${stats.goals}')),
              Expanded(child: _StatBox(label: 'Passes D.', value: '${stats.assists}')),
              Expanded(child: _StatBox(label: 'Clean Sh.', value: '${stats.cleanSheets}')),
            ],
          ),
          const SizedBox(height: 12),
          if (stats.passAccuracy > 0) ...[
            _StatBar(label: 'Précision passe', value: stats.passAccuracy, max: 100, color: AppColors.primaryLight),
            const SizedBox(height: 8),
          ],
          if (stats.shotAccuracy > 0)
            _StatBar(label: 'Précision tir', value: stats.shotAccuracy, max: 100, color: AppColors.gold),
        ],
      ),
    );
  }

  Widget _buildHighlights(BuildContext context, PlayerModel p) {
    return _SectionCard(
      title: 'Highlights',
      child: p.highlights.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Aucun highlight disponible', style: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary)),
              ),
            )
          : Column(
              children: p.highlights.map((v) => _VideoListItem(video: v)).toList(),
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
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
          Text(title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, duration: 400.ms);
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
        Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final Color color;
  const _StatBar({required this.label, required this.value, required this.max, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary)),
            Text('${value.toStringAsFixed(1)}%', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: value / max,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(100)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _VideoListItem extends StatelessWidget {
  final VideoModel video;
  const _VideoListItem({required this.video});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  video.thumbnailUrl ?? 'https://picsum.photos/120/80',
                  width: 100,
                  height: 70,
                  fit: BoxFit.cover,
                ),
                const Icon(Icons.play_circle_outline, color: Colors.white, size: 28),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(video.title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.play_arrow, size: 12, color: AppColors.textSecondary),
                    Text('${video.views}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    const Icon(Icons.favorite, size: 12, color: AppColors.textSecondary),
                    Text('${video.likes}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

