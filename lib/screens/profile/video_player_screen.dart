import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/spora_images.dart';

/// Landscape highlight player — /video-player (frame « Lecteur vidéo paysage »).
/// Forces landscape while open, restores portrait on dispose.
class VideoPlayerScreen extends StatefulWidget {
  final String? title;
  const VideoPlayerScreen({super.key, this.title});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool _playing = false;
  double _progress = 16 / 42; // 00:16 / 00:42

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy900,
      body: SafeArea(
        child: Stack(fit: StackFit.expand, children: [
          Image.network(
            sporaImage('video-player', w: 1280, h: 720),
            fit: BoxFit.cover,
            loadingBuilder: (c, w, p) =>
                p == null ? w : const SizedBox.shrink(),
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0x99061426),
            ),
          ),
          // Top bar
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.arrowLeft,
                      color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: Text(
                    widget.title ??
                        'Frappe exceptionnelle depuis l’extérieur de la surface',
                    style: AppTextStyles.h3(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.share2,
                      color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // Center controls
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 40,
                  icon: const Icon(LucideIcons.rotateCcw,
                      color: Colors.white),
                  onPressed: () {},
                ),
                const SizedBox(width: 40),
                GestureDetector(
                  onTap: () => setState(() => _playing = !_playing),
                  child: Icon(
                    _playing
                        ? LucideIcons.pauseCircle
                        : LucideIcons.playCircle,
                    color: Colors.white,
                    size: 56,
                  ),
                ),
                const SizedBox(width: 40),
                IconButton(
                  iconSize: 40,
                  icon: const Icon(LucideIcons.rotateCw,
                      color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // Bottom controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                      'Économie de données · lecture manuelle · ±10 s',
                      style:
                          AppTextStyles.caption(color: Colors.white70)),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 0),
                    overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 0),
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: Colors.white,
                    thumbColor: Colors.transparent,
                    overlayColor: Colors.transparent,
                  ),
                  child: Slider(
                    value: _progress,
                    onChanged: (v) => setState(() => _progress = v),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 8, 12),
                  child: Row(
                    children: [
                      Text('00:16 / 00:42',
                          style:
                              AppTextStyles.caption(color: Colors.white)),
                      const Spacer(),
                      Flexible(
                        child: Text('Auto · 720p · 1×',
                            style: AppTextStyles.caption(
                                color: Colors.white),
                            overflow: TextOverflow.ellipsis),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.heart,
                            color: Colors.white, size: 22),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.maximize,
                            color: Colors.white, size: 24),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
