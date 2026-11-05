import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'admin_moderation_support.dart';
import 'admin_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _videos = [
  (id: 'VID-0284', title: 'Frappe extérieure', player: 'Jordan Mbala · 19 ans', time: '08:20', duration: '00:42', tag: 'BUT', minor: false),
  (id: 'VID-0285', title: 'Passes en profondeur', player: 'Kevin Njoya · 21 ans', time: '09:05', duration: '00:38', tag: 'PASSES', minor: false),
  (id: 'VID-0286', title: 'Placement défensif', player: 'Samuel Kouassi · 20 ans', time: '10:12', duration: '00:51', tag: 'SKILLS', minor: false),
  (id: 'VID-0287', title: 'Première touche', player: 'Joueur protégé · 16 ans', time: '11:30', duration: '00:28', tag: 'SKILLS', minor: true),
  (id: 'VID-0288', title: 'Arrêts réflexes', player: 'David Tchoupo · 22 ans', time: '13:42', duration: '00:56', tag: 'ARRÊTS', minor: false),
  (id: 'VID-0289', title: 'Finition en une touche', player: 'Jordan Mbala · 19 ans', time: '15:00', duration: '00:35', tag: 'BUT', minor: false),
];

class VideoModerationScreen extends StatefulWidget {
  const VideoModerationScreen({super.key});
  @override
  State<VideoModerationScreen> createState() => _VideoModerationScreenState();
}

class _VideoModerationScreenState extends State<VideoModerationScreen> {
  String _query = '', _tag = 'Tag : Tous', _age = 'Âge : Tous';
  @override
  Widget build(BuildContext context) {
    final videos = _videos.where((v) => '${v.title} ${v.player}'.toLowerCase().contains(_query.toLowerCase()) &&
      (_tag == 'Tag : Tous' || v.tag == _tag) && (_age == 'Âge : Tous' || v.minor == (_age == 'Mineurs'))).toList();
    return ModerationPage(title: 'Modération vidéos', subtitle: '48 vidéos en attente · Triées de la plus ancienne à la plus récente.', children: [
      const Wrap(spacing: 16, runSpacing: 8, children: [AdminPill('En validation · 48', color: AppColors.primary), AdminPill('En traitement · 16'), AdminPill('Approuvées · 1 196', color: AppColors.clubGreen), AdminPill('Refusées · 42', color: AppColors.danger)]),
      Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
        ModerationSearch(hint: 'Titre ou propriétaire…', onChanged: (s) => setState(() => _query = s)),
        const AdminFilter('Statut : En validation', selected: true),
        ModerationFilter(value: _tag, options: const ['Tag : Tous', 'BUT', 'PASSES', 'SKILLS', 'ARRÊTS'], onChanged: (s) => setState(() => _tag = s)),
        ModerationFilter(value: _age, options: const ['Âge : Tous', 'Adultes', 'Mineurs'], onChanged: (s) => setState(() => _age = s)),
        const AdminFilter('Plus anciennes'),
      ]),
      const AdminBanner(title: 'MVP · Toutes les vidéos sont examinées avant publication', body: 'Une vidéo en validation reste visible uniquement par son propriétaire.'),
      LayoutBuilder(builder: (context, c) => AdminTable(columns: const [AdminCol('Aperçu / propriétaire', flex: 2), AdminCol('Soumission'), AdminCol('Durée / tag'), AdminCol('Âge et statut'), AdminCol('Action')], rows: [
        for (final v in videos) [
          Row(children: [if (c.maxWidth > 1000) ...[const _VideoPlaceholder(width: 66, height: 48), const SizedBox(width: 10)], Expanded(child: ModerationText('${v.title}\n${v.player}', strong: true))]),
          ModerationText('15 oct. · ${v.time}\n${25 - _videos.indexOf(v)} h d’attente'),
          ModerationText('${v.duration} · ${v.tag}'),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ModerationText(v.minor ? 'Mineur' : 'Adulte'), AdminPill(v.minor ? 'Revue sensible' : 'En validation', color: v.minor ? AppColors.warning : AppColors.primary)]),
          AdminLink('Examiner', onTap: () => context.push('/admin/moderation/${v.id}')),
        ],
      ])),
      if (videos.isEmpty) const ModerationText('Aucune vidéo ne correspond aux filtres.'),
      AdminPagination(summary: '1–${videos.length} sur 48 résultats · 20 par page'),
      const AdminSection(title: 'Consignes de revue', child: ModerationText('Vérifier le contenu sportif, les droits déclarés et l’absence de données personnelles. Pour un mineur, contrôler aussi le consentement et les restrictions de visibilité.')),
    ]);
  }
}

class HighlightReviewScreen extends StatelessWidget {
  const HighlightReviewScreen({super.key, required this.itemId});
  final String itemId;
  @override
  Widget build(BuildContext context) {
    final matches = _videos.where((v) => v.id == itemId);
    if (matches.isEmpty) {
      return ModerationPage(title: 'Highlight introuvable', subtitle: itemId, children: [AdminLink('Retour à la modération', onTap: () => context.go('/admin/moderation'))]);
    }
    final video = matches.first;
    return ModerationPage(title: 'Examen d’un highlight', subtitle: '$itemId · ${video.player} · Soumis le 15 octobre 2026 à ${video.time}', children: [
      ModerationColumns(left: Column(children: [
        AdminCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const AspectRatio(aspectRatio: 2.25, child: _VideoPlaceholder()),
          Row(children: [IconButton(onPressed: () => moderationNotice(context, 'Aperçu vidéo fictif, aucun média chargé'), icon: const Icon(LucideIcons.play, color: AppColors.primary)), ModerationText('00:00 / ${video.duration}'), const Spacer(), const Icon(LucideIcons.volume2, color: AppColors.primary), const SizedBox(width: 16), const Icon(LucideIcons.maximize, color: AppColors.primary)]),
          Text(video.title, style: AppTextStyles.h1()), const SizedBox(height: 16),
          ModerationText('${video.tag} · ${video.duration} · Source 84 Mo · 720p · France'), const SizedBox(height: 16),
          AdminBanner(title: video.player, body: video.minor ? 'Profil mineur · Coordonnées protégées · Consentement à vérifier.' : 'Paris · U21 · Profil vérifié · Abonnement Premium distinct du statut de vérification.'),
        ])), const SizedBox(height: 20),
        const AdminSection(title: 'Historique de soumission', child: ModerationText('15 oct. 08:20 · Vidéo reçue → En traitement\n\n15 oct. 08:23 · Poster et qualités générés → En validation\n\n16 oct. 09:35 · Dossier ouvert par Amina Diallo')),
      ]), right: _HighlightDecision(itemId: itemId)),
      const AdminSection(title: 'Décisions réversibles', child: ModerationText('Aucune décision définitive sur ce dossier. Une révision exige un nouveau motif et ne remplace jamais la trace précédente.')),
    ]);
  }
}

class _HighlightDecision extends StatefulWidget {
  const _HighlightDecision({required this.itemId});
  final String itemId;
  @override
  State<_HighlightDecision> createState() => _HighlightDecisionState();
}
class _HighlightDecisionState extends State<_HighlightDecision> {
  final _reason = TextEditingController(text: 'Les droits de diffusion de cet extrait ne peuvent pas être confirmés.');
  String? _decision;
  final _checks = [true, true, true, false];
  @override
  void dispose() { _reason.dispose(); super.dispose(); }
  Future<void> _decide(bool approve) async {
    final ok = await confirmModeration(context, title: approve ? 'Approuver ce highlight ?' : 'Refuser ce highlight ?',
      body: approve ? 'La vidéo sera publiée et le joueur sera notifié.' : 'La vidéo ne sera pas publiée. Le motif sera transmis au propriétaire.',
      confirmLabel: approve ? 'Confirmer la validation' : 'Confirmer le refus', destructive: !approve,
      initialReason: approve ? '' : _reason.text);
    if (!mounted || !ok) return;
    setState(() => _decision = approve ? 'Approuvée' : 'Refusée');
    moderationNotice(context, 'Décision enregistrée pour ${widget.itemId}');
  }
  @override
  Widget build(BuildContext context) => AdminSection(title: 'Vérifications avant décision', child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    for (var i = 0; i < _checks.length; i++) CheckboxListTile(contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading,
      title: ModerationText(const ['Durée et format conformes', 'Contenu football identifiable', 'Aucun contact personnel visible', 'Droits de diffusion confirmés'][i]),
      value: _checks[i], onChanged: (v) => setState(() => _checks[i] = v ?? false)),
    const SizedBox(height: 16),
    TextField(controller: _reason, maxLines: 4, decoration: const InputDecoration(labelText: 'Motif de refus · obligatoire', border: OutlineInputBorder())),
    const SizedBox(height: 16),
    if (_decision != null) AdminPill(_decision!, color: _decision == 'Approuvée' ? AppColors.success : AppColors.danger)
    else ...[
      FilledButton(onPressed: _checks.every((v) => v) ? () => _decide(true) : null, child: const Text('Valider le highlight')),
      const SizedBox(height: 12), AdminPrimaryButton('Refuser avec ce motif', icon: LucideIcons.x, color: AppColors.errorText, onPressed: () => _decide(false)),
    ],
    const SizedBox(height: 16), const ModerationText('La décision notifie le propriétaire et crée une entrée dans le journal d’audit.'),
  ]));
}

class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder({this.width, this.height});
  final double? width, height;
  @override
  Widget build(BuildContext context) => Container(width: width, height: height,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), gradient: const LinearGradient(colors: [AppColors.navy700, AppColors.clubGreen], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
    child: const Center(child: Icon(LucideIcons.playCircle, color: Colors.white, size: 34)));
}
