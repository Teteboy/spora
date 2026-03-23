import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/spora_logo.dart';
import '../../models/player_model.dart';

class HighlightsScreen extends StatefulWidget {
  const HighlightsScreen({super.key});

  @override
  State<HighlightsScreen> createState() => _HighlightsScreenState();
}

class _HighlightsScreenState extends State<HighlightsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlayerProvider>().loadHomeData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        title: const SporaLogo(height: 32),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.gold,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Tendances'),
            Tab(text: 'Récents'),
            Tab(text: 'Populaires'),
          ],
        ),
      ),
      body: Consumer<PlayerProvider>(
        builder: (context, provider, _) {
          final videos = provider.latestHighlights;
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildVideoGrid(videos),
              _buildVideoGrid(videos.reversed.toList()),
              _buildVideoGrid(videos),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVideoGrid(List<VideoModel> videos) {
    if (videos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, size: 60, color: AppColors.textHint),
            SizedBox(height: 12),
            Text('Aucun highlight disponible', style: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: videos.length,
      itemBuilder: (context, i) {
        final video = videos[i];
        return _VideoGridCard(video: video)
            .animate()
            .fadeIn(duration: 300.ms, delay: Duration(milliseconds: i * 60));
      },
    );
  }
}

class _VideoGridCard extends StatelessWidget {
  final VideoModel video;
  const _VideoGridCard({required this.video});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        child: Stack(
          children: [
            Image.network(
              video.thumbnailUrl ?? 'https://picsum.photos/300/375?random=${video.id}',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => Container(color: AppColors.primaryDark),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                ),
              ),
            ),
            Center(
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow, color: AppColors.primary, size: 26),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.play_arrow, color: Colors.white70, size: 12),
                      Text(_fmt(video.views), style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'Poppins')),
                      const SizedBox(width: 6),
                      const Icon(Icons.favorite, color: Colors.white70, size: 12),
                      Text(_fmt(video.likes), style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'Poppins')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

