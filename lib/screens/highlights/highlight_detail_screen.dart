import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/player_model.dart';
import 'highlights_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HighlightDetailScreen extends StatefulWidget {
  const HighlightDetailScreen({super.key, this.video});
  final VideoModel? video;
  @override
  State<HighlightDetailScreen> createState() => _HighlightDetailScreenState();
}

class _HighlightDetailScreenState extends State<HighlightDetailScreen> {
  bool _playing = false;
  bool _saved = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.appBg,
    body: SafeArea(child: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(AppDimens.screenMargin, AppDimens.sm, AppDimens.screenMargin, AppDimens.md),
        child: Row(children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: AppDimens.minTouch,
              height: AppDimens.minTouch,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.radiusInput),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(LucideIcons.arrowLeft, size: 22, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(child: Text('Détail du highlight', style: AppTextStyles.h2(), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
      ),
      Expanded(child: ListView(padding: const EdgeInsets.all(AppDimens.screenMargin), children: [
      ClipRRect(borderRadius: BorderRadius.circular(16), child: HighlightPoster(height: 280, child: IconButton.filled(onPressed: () => setState(() => _playing = !_playing), iconSize: 32, style: IconButton.styleFrom(backgroundColor: AppColors.surface, foregroundColor: AppColors.primary, fixedSize: const Size(56, 56)), icon: Icon(_playing ? LucideIcons.pause : LucideIcons.play)))),
      const SizedBox(height: 20),
      Text(widget.video?.title ?? 'Frappe exceptionnelle depuis l’extérieur de la surface', style: AppTextStyles.h1()),
      const SizedBox(height: 12),
      Align(alignment: Alignment.centerLeft, child: Chip(backgroundColor: AppColors.premiumBg, shape: const StadiumBorder(), label: Text('BUT', style: AppTextStyles.eyebrow(color: AppColors.goldDark)))),
      Text('18,4 K vues · 2,4 K j’aime · Il y a 2 jours', style: AppTextStyles.caption()),
      const SizedBox(height: 24),
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const CircleAvatar(radius: 26, backgroundColor: AppColors.primaryTint, child: Icon(LucideIcons.user, color: AppColors.primary)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.video?.playerName ?? 'Jordan Mbala', style: AppTextStyles.h3()), Text('Attaquant · 21 ans', style: AppTextStyles.body())])), const Icon(LucideIcons.badgeCheck, color: AppColors.primary)]),
        const SizedBox(height: 16),
        Text('Douala, Cameroun · Pied droit', style: AppTextStyles.body()),
        Text('Union sportive · Disponible pour des essais', style: AppTextStyles.caption()),
        TextButton(onPressed: () => context.push('/player/${widget.video?.playerId ?? '1'}'), child: const Text('Voir le profil complet →')),
      ])),
      const SizedBox(height: 24),
      Text('À propos de cette action', style: AppTextStyles.h2()),
      const SizedBox(height: 8),
      Text('Une frappe du droit, à l’entrée de la surface. Match U21 du week-end.', style: AppTextStyles.body()),
      const SizedBox(height: 24),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [for (final stat in [('18,4 K', 'Vues'), ('2,4 K', 'J’aime'), ('128', 'Commentaires')]) Column(children: [Text(stat.$1, style: AppTextStyles.statNumber()), Text(stat.$2, style: AppTextStyles.caption())])]),
      const SizedBox(height: 24),
      Text('Vue recruteur', style: AppTextStyles.eyebrow()),
      const SizedBox(height: 8),
      Text('Retrouvez ce talent dans votre liste et échangez directement avec lui.', style: AppTextStyles.body()),
      ])),
    ])),
    bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () => setState(() => _saved = !_saved), icon: Icon(_saved ? LucideIcons.check : LucideIcons.bookmarkPlus), label: Text(_saved ? 'Dans ma liste' : 'Ajouter à ma liste'))), const SizedBox(width: 12), Expanded(child: FilledButton(onPressed: () => context.push('/chat/${widget.video?.playerId ?? '1'}', extra: {'name': widget.video?.playerName ?? 'Jordan Mbala'}), child: const Text('Contacter')))]))),
  );
}
