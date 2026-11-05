import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'highlights_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MyHighlightsScreen extends StatefulWidget {
  const MyHighlightsScreen({super.key});
  @override
  State<MyHighlightsScreen> createState() => _MyHighlightsScreenState();
}

class _OwnHighlight {
  _OwnHighlight(this.title, this.tag, this.status, {this.pinned = false});
  String title;
  String tag;
  final String status;
  bool pinned;
}

class _MyHighlightsScreenState extends State<MyHighlightsScreen> {
  final _videos = [
    _OwnHighlight('Frappe depuis l’extérieur de la surface', 'BUT', 'En ligne', pinned: true),
    _OwnHighlight('Finition en une touche', 'BUT', 'En traitement'),
    _OwnHighlight('Dribbles et accélération', 'DRIBBLES', 'En validation'),
    _OwnHighlight('Mes meilleures passes', 'PASSES', 'Refusée'),
  ];

  Future<void> _edit(_OwnHighlight video) async {
    final controller = TextEditingController(text: video.title);
    var tag = video.tag;
    final form = GlobalKey<FormState>();
    await showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (sheet) => StatefulBuilder(builder: (context, update) => Padding(padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + MediaQuery.viewInsetsOf(context).bottom), child: Form(key: form, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Modifier le highlight', style: AppTextStyles.h2()),
      const SizedBox(height: 20),
      TextFormField(controller: controller, maxLength: 100, style: AppTextStyles.body(), decoration: const InputDecoration(labelText: 'Titre *', border: OutlineInputBorder()), validator: (value) => value == null || value.trim().isEmpty ? 'Ajoutez un titre' : null),
      const SizedBox(height: 12),
      Text('Type d’action *', style: AppTextStyles.bodyStrong()),
      Wrap(spacing: 8, children: [for (final item in highlightTags) ChoiceChip(shape: const StadiumBorder(), label: Text(item, style: AppTextStyles.caption()), selected: tag == item, onSelected: (_) => update(() => tag = item))]),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: FilledButton(onPressed: () { if (form.currentState!.validate()) { setState(() { video.title = controller.text.trim(); video.tag = tag; }); Navigator.pop(sheet); } }, child: const Text('Enregistrer'))),
    ])))));
    // Keep the controller alive until the sheet's closing animation completes.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    controller.dispose();
  }

  Future<void> _delete(_OwnHighlight video) async {
    final confirmed = await showDialog<bool>(context: context, builder: (dialog) => AlertDialog(
      title: Text('Supprimer ce highlight ?', style: AppTextStyles.h2()),
      content: Text('Cette action est définitive. La vidéo et ses statistiques seront supprimées.', style: AppTextStyles.body()),
      actions: [TextButton(onPressed: () => Navigator.pop(dialog, false), child: const Text('Annuler')), TextButton(onPressed: () => Navigator.pop(dialog, true), child: Text('Supprimer', style: AppTextStyles.button(color: AppColors.danger)))],
    ));
    if (confirmed == true && mounted) setState(() => _videos.remove(video));
  }

  void _pin(_OwnHighlight video) => setState(() { final pinned = video.pinned; for (final item in _videos) { item.pinned = false; } video.pinned = !pinned; });

  Color _statusColor(String status) => switch (status) { 'En ligne' => AppColors.clubGreen, 'Refusée' => AppColors.errorText, 'En traitement' => AppColors.primary, _ => AppColors.goldDark };

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.appBg,
    body: SafeArea(child: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(AppDimens.screenMargin, AppDimens.sm, AppDimens.screenMargin, AppDimens.md),
        child: Row(children: [
          _tile(icon: LucideIcons.arrowLeft, onTap: () => context.pop()),
          const SizedBox(width: AppDimens.md),
          Expanded(child: Text('Mes highlights', style: AppTextStyles.h1(), maxLines: 1, overflow: TextOverflow.ellipsis)),
          _tile(icon: LucideIcons.plus, onTap: () => context.push('/highlights/publish')),
        ]),
      ),
      Expanded(child: ListView(padding: const EdgeInsets.all(AppDimens.screenMargin), children: [
      Text('${_videos.length} vidéos · Votre talent en images', style: AppTextStyles.body()),
      const SizedBox(height: 16),
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.primaryTint, borderRadius: BorderRadius.circular(16)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(LucideIcons.pin, color: AppColors.primary), const SizedBox(width: 12), Expanded(child: Text('Épinglez une vidéo de présentation pour la mettre en avant sur votre profil.', style: AppTextStyles.body(color: AppColors.primary)))])),
      const SizedBox(height: 20),
      if (_videos.isEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 64), child: Column(children: [const Icon(LucideIcons.film, size: 56, color: AppColors.textMuted), const SizedBox(height: 16), Text('Aucun highlight pour le moment', style: AppTextStyles.h3()), TextButton(onPressed: () => context.push('/highlights/publish'), child: const Text('Publier mon premier highlight'))])),
      for (final video in _videos) Padding(padding: const EdgeInsets.only(bottom: 16), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(borderRadius: BorderRadius.circular(12), child: const SizedBox(width: 96, child: HighlightPoster(height: 112, child: Icon(LucideIcons.playCircle, color: AppColors.surface, size: 32)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(video.title, style: AppTextStyles.h3()), const SizedBox(height: 8), Text('${video.tag} · 00:42', style: AppTextStyles.caption()), const SizedBox(height: 4), Chip(visualDensity: VisualDensity.compact, shape: const StadiumBorder(), side: BorderSide.none, backgroundColor: _statusColor(video.status).withValues(alpha: .1), label: Text(video.status, style: AppTextStyles.micro(color: _statusColor(video.status))))])),
          PopupMenuButton<String>(tooltip: 'Actions du highlight', onSelected: (action) { switch (action) { case 'edit': _edit(video); case 'pin': _pin(video); case 'delete': _delete(video); } }, itemBuilder: (_) => [const PopupMenuItem(value: 'edit', child: Text('Modifier le titre / le tag')), if (video.status == 'En ligne') PopupMenuItem(value: 'pin', child: Text(video.pinned ? 'Retirer la présentation' : 'Épingler en présentation')), const PopupMenuItem(value: 'delete', child: Text('Supprimer'))]),
        ]),
        if (video.pinned) Padding(padding: const EdgeInsets.only(top: 12), child: Row(children: [const Icon(LucideIcons.pin, color: AppColors.primary, size: 16), const SizedBox(width: 6), Text('Vidéo de présentation', style: AppTextStyles.caption(color: AppColors.primary))])),
        if (video.status == 'En ligne') Padding(padding: const EdgeInsets.only(top: 12), child: Text('18,4 K vues · 2,4 K j’aime · 128 commentaires', style: AppTextStyles.caption())),
        if (video.status == 'En traitement') Padding(padding: const EdgeInsets.only(top: 12), child: Text('Préparation de votre vidéo. Elle sera ensuite vérifiée.', style: AppTextStyles.caption())),
        if (video.status == 'En validation') Padding(padding: const EdgeInsets.only(top: 12), child: Text('Notre équipe vérifie votre vidéo avant sa publication.', style: AppTextStyles.caption())),
        if (video.status == 'Refusée') ...[const SizedBox(height: 12), Text('Motif : qualité vidéo insuffisante. L’action et le joueur doivent être clairement visibles.', style: AppTextStyles.caption(color: AppColors.errorText)), TextButton.icon(onPressed: () => context.push('/highlights/publish'), icon: const Icon(LucideIcons.upload), label: const Text('Remplacer'))],
      ]))),
      FilledButton.icon(onPressed: () => context.push('/highlights/publish'), icon: const Icon(LucideIcons.plus), label: const Text('Publier un highlight')),
      ])),
    ])),
  );

  /// Bordered icon tile used in the top bar (Figma header pattern, 44 px).
  Widget _tile({required IconData icon, required VoidCallback onTap}) {
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
        child: Icon(icon, size: 22, color: AppColors.textPrimary),
      ),
    );
  }
}
