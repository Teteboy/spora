import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/player_model.dart';
import '../../core/constants/spora_images.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const highlightTags = ['BUT', 'SKILLS', 'PASSES', 'ARRÊTS', 'DRIBBLES', 'AUTRE'];

/// Offline-safe simulated poster shared by the highlights flows.
class HighlightPoster extends StatelessWidget {
  const HighlightPoster({super.key, this.child, this.height});
  final Widget? child;
  final double? height;
  @override
  Widget build(BuildContext context) => Container(
    height: height,
    width: double.infinity,
    decoration: const BoxDecoration(gradient: LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [AppColors.navy700, AppColors.darkApp, AppColors.clubGreen],
    )),
    child: Stack(alignment: Alignment.center, children: [
      const Positioned(right: 24, bottom: 32, child: Icon(LucideIcons.goal, size: 72, color: AppColors.darkBorder)),
      const Icon(LucideIcons.footprints, size: 150, color: AppColors.darkRaised),
      if (child != null) child!,
    ]),
  );
}

/// One feed entry — a [VideoModel] plus presentation metadata shown in Figma.
class _FeedItem {
  final VideoModel video;
  final String tag;
  final String position;
  final String level;
  final String sizeMb;
  final String postedAgo;
  final bool verified;
  const _FeedItem({
    required this.video,
    required this.tag,
    required this.position,
    required this.level,
    this.sizeMb = '3,2',
    this.postedAgo = 'Il y a 2 jours',
    this.verified = false,
  });
}

final List<_FeedItem> _feed = [
  _FeedItem(
    tag: 'BUT', position: 'Attaquant', level: 'Niveau National', verified: true,
    video: VideoModel(
      id: 'hl1',
      title: 'Frappe exceptionnelle depuis l’extérieur de la surface',
      description: 'Frappe en lucarne depuis 25 mètres.',
      views: 18400, likes: 2400, comments: 128, shares: 342,
      uploadDate: DateTime(2025, 3, 8),
      playerId: 'jordan_mbala', playerName: 'Jordan Mbala',
      playerAvatarUrl: 'https://i.pravatar.cc/120?u=jordan_mbala',
    ),
  ),
  _FeedItem(
    tag: 'SKILLS', position: 'Milieu offensif', level: 'Niveau Régional',
    postedAgo: 'Il y a 5 heures', sizeMb: '2,8', verified: true,
    video: VideoModel(
      id: 'hl2', title: 'Enchaînement technique en pleine course',
      description: 'Double contact et petit pont.',
      views: 9600, likes: 1800, comments: 64, shares: 96,
      uploadDate: DateTime(2025, 3, 12),
      playerId: 'amadou_diallo', playerName: 'Amadou Diallo',
      playerAvatarUrl: 'https://i.pravatar.cc/120?u=amadou_diallo',
    ),
  ),
  _FeedItem(
    tag: 'PASSES', position: 'Milieu relayeur', level: 'Niveau National',
    postedAgo: 'Il y a 1 jour', sizeMb: '3,6',
    video: VideoModel(
      id: 'hl3', title: 'Passe décisive entre deux défenseurs',
      description: 'Ouverture lumineuse de 40 mètres.',
      views: 7200, likes: 940, comments: 41, shares: 58,
      uploadDate: DateTime(2025, 3, 11),
      playerId: 'kevin_njoya', playerName: 'Kévin Njoya',
      playerAvatarUrl: 'https://i.pravatar.cc/120?u=kevin_njoya',
    ),
  ),
  _FeedItem(
    tag: 'ARRÊTS', position: 'Gardien', level: 'Niveau Élite',
    postedAgo: 'Il y a 3 jours', sizeMb: '4,1',
    video: VideoModel(
      id: 'hl4', title: 'Double arrêt réflexe sur la ligne',
      description: 'Deux parades décisives en une action.',
      views: 12300, likes: 1500, comments: 87, shares: 120,
      uploadDate: DateTime(2025, 3, 7),
      playerId: 'theo_bernard', playerName: 'Théo Bernard',
      playerAvatarUrl: 'https://i.pravatar.cc/120?u=theo_bernard',
    ),
  ),
  _FeedItem(
    tag: 'DRIBBLES', position: 'Ailier gauche', level: 'Niveau Régional',
    postedAgo: 'Il y a 6 heures', sizeMb: '2,4',
    video: VideoModel(
      id: 'hl5', title: 'Roulette et crochet en pleine surface',
      description: 'Élimination de trois défenseurs.',
      views: 5400, likes: 620, comments: 33, shares: 44,
      uploadDate: DateTime(2025, 3, 12),
      playerId: 'evan_fontaine', playerName: 'Evan Fontaine',
      playerAvatarUrl: 'https://i.pravatar.cc/120?u=evan_fontaine',
    ),
  ),
  _FeedItem(
    tag: 'BUT', position: 'Attaquant', level: 'Niveau National',
    postedAgo: 'Il y a 4 jours', sizeMb: '3,9',
    video: VideoModel(
      id: 'hl6', title: 'Volée en pleine course au second poteau',
      description: 'Reprise acrobatique imparable.',
      views: 21900, likes: 3100, comments: 154, shares: 201,
      uploadDate: DateTime(2025, 3, 6),
      playerId: 'kylian_moreau', playerName: 'Kylian Moreau',
      playerAvatarUrl: 'https://i.pravatar.cc/120?u=kylian_moreau',
    ),
  ),
  _FeedItem(
    tag: 'AUTRE', position: 'Défenseur central', level: 'Niveau Départemental',
    postedAgo: 'Il y a 1 semaine', sizeMb: '3,1',
    video: VideoModel(
      id: 'hl7', title: 'Tacle décisif en dernière minute',
      description: 'Intervention qui sauve le match.',
      views: 3800, likes: 410, comments: 19, shares: 22,
      uploadDate: DateTime(2025, 3, 3),
      playerId: 'louka_dubois', playerName: 'Louka Dubois',
      playerAvatarUrl: 'https://i.pravatar.cc/120?u=louka_dubois',
    ),
  ),
];

/// '18400' → '18,4 K' — compact counter used in the Figma rail and meta line.
String _compact(int value) {
  if (value < 1000) return '$value';
  final text = (value / 1000).toStringAsFixed(1).replaceAll('.', ',');
  return '${text.endsWith(',0') ? text.substring(0, text.length - 2) : text} K';
}

class HighlightsScreen extends StatefulWidget {
  const HighlightsScreen({super.key});
  @override
  State<HighlightsScreen> createState() => _HighlightsScreenState();
}

class _HighlightsScreenState extends State<HighlightsScreen> {
  static const _states = ['Lecture', 'Aimé', 'Pause', 'Chargement vidéo', 'Hors connexion', 'Limite gratuite atteinte', 'Économie de données'];
  static const _chips = ['Tout', ...highlightTags];
  static const _tabs = ['Pour vous', 'Suivis'];

  String _tab = 'Pour vous';
  String _tag = 'Tout';
  String _state = 'Économie de données';
  int _page = 0;
  int _burstSeq = 0;
  int _retrySeq = 0;
  bool _burst = false;
  final Set<String> _liked = {};
  final Set<String> _saved = {};
  final Set<String> _following = {};

  List<_FeedItem> get _items =>
      _feed.where((e) => _tag == 'Tout' || e.tag == _tag).toList();

  String? get _currentId {
    final items = _items;
    if (items.isEmpty) return null;
    return items[_page.clamp(0, items.length - 1)].video.id;
  }

  void _applyState(String state) {
    setState(() => _state = state);
    if (state == 'Aimé') {
      final id = _currentId;
      if (id != null) _like(id, force: true);
    }
    if (state == 'Limite gratuite atteinte') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _limit();
      });
    }
  }

  void _onPageChanged(int value) {
    _page = value;
    _applyState(_states[value % _states.length]);
  }

  void _onTap() {
    switch (_state) {
      case 'Limite gratuite atteinte':
        _limit();
      case 'Hors connexion':
      case 'Chargement vidéo':
        break;
      case 'Pause':
      case 'Économie de données':
        setState(() => _state = 'Lecture');
      default:
        setState(() => _state = 'Pause');
    }
  }

  void _like(String id, {bool force = false}) {
    var added = false;
    setState(() {
      if (force || !_liked.contains(id)) {
        _liked.add(id);
        added = true;
      } else {
        _liked.remove(id);
      }
      if (added) _burst = true;
    });
    if (added) {
      final seq = ++_burstSeq;
      Future<void>.delayed(const Duration(milliseconds: 700), () {
        if (mounted && seq == _burstSeq) setState(() => _burst = false);
      });
    }
  }

  void _retry() {
    final seq = ++_retrySeq;
    setState(() => _state = 'Chargement vidéo');
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (mounted && seq == _retrySeq) setState(() => _state = 'Lecture');
    });
  }

  void _share(VideoModel video) {
    Clipboard.setData(ClipboardData(text: 'https://spora.app/highlights/${video.id}'));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lien copié')));
  }

  void _limit() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.appBg,
    builder: (sheet) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Votre jeu mérite plus d’espace', style: AppTextStyles.display()),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.primaryTint, borderRadius: BorderRadius.circular(AppDimens.radiusCard)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(LucideIcons.video, color: AppColors.primary, size: 26),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Limite gratuite atteinte', style: AppTextStyles.bodyStrong(color: AppColors.primary)),
              const SizedBox(height: 2),
              Text('Vous avez déjà publié 1 highlight sur 1. Votre vidéo reste en ligne.', style: AppTextStyles.caption(color: AppColors.primary)),
            ])),
          ]),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusHero),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.premiumBg, borderRadius: BorderRadius.circular(AppDimens.radiusPill)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(LucideIcons.crown, size: 14, color: AppColors.goldDark),
                const SizedBox(width: 4),
                Text('Premium', style: AppTextStyles.caption(color: AppColors.goldDark).copyWith(fontWeight: FontWeight.w600)),
              ]),
            ),
            const SizedBox(height: 12),
            Text('Donnez plus de place à votre jeu', style: AppTextStyles.h1()),
            const SizedBox(height: 8),
            Text('Highlights illimités et statistiques détaillées. Le badge Premium ne vérifie pas votre identité.', style: AppTextStyles.body()),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.navy900),
                onPressed: () { Navigator.pop(sheet); context.push('/premium'); },
                icon: const Icon(LucideIcons.crown),
                label: Text('Passer à Premium', style: AppTextStyles.button(color: AppColors.navy900)),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Text('Gratuit : 1 highlight publié. Premium : highlights illimités. Chaque vidéo reste limitée à 60 s et 200 Mo et soumise à modération.',
            style: AppTextStyles.caption(), textAlign: TextAlign.center),
      ]),
    ),
  );

  void _comments() {
    final controller = TextEditingController();
    final comments = <String>['Très belle frappe !'];
    showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (sheet) => StatefulBuilder(builder: (context, update) => Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Commentaires', style: AppTextStyles.h2()),
        for (final comment in comments) ListTile(leading: const CircleAvatar(child: Icon(LucideIcons.user)), title: Text(comment, style: AppTextStyles.body())),
        TextField(controller: controller, decoration: InputDecoration(hintText: 'Ajouter un commentaire', suffixIcon: IconButton(icon: const Icon(LucideIcons.send), onPressed: () { if (controller.text.trim().isNotEmpty) update(() { comments.add(controller.text.trim()); controller.clear(); }); }))),
      ]),
    ))).whenComplete(controller.dispose);
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final bottomPad = MediaQuery.paddingOf(context).bottom.clamp(0.0, 24.0);
    return Scaffold(
      backgroundColor: AppColors.darkApp,
      body: Stack(fit: StackFit.expand, children: [
        Positioned.fill(child: items.isEmpty
            ? Center(child: Text('Aucun highlight dans cette catégorie', style: AppTextStyles.body(color: AppColors.darkTextMuted)))
            : PageView.builder(
                key: ValueKey('$_tab/$_tag'),
                scrollDirection: Axis.vertical,
                itemCount: items.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) => _feedPage(items[index], index, bottomPad),
              )),
        _topOverlay(),
        Positioned(
          left: 16, right: 16, bottom: bottomPad + 14,
          child: IgnorePointer(child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: const LinearProgressIndicator(value: .42, minHeight: 3, color: AppColors.surface, backgroundColor: AppColors.darkBorder),
          )),
        ),
      ]),
    );
  }

  // ── One swipeable feed page ──────────────────────────────────────────
  Widget _feedPage(_FeedItem item, int index, double bottomPad) {
    final video = item.video;
    return GestureDetector(
      onTap: _onTap,
      onDoubleTap: () => _like(video.id, force: true),
      child: Stack(fit: StackFit.expand, children: [
        // Full-bleed photo/video area.
        Image.network(
          sporaImage('spora-hl$index' as Object?, w: 720, h: 1280),
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) =>
              progress == null ? child : Container(color: AppColors.navy800),
          errorBuilder: (context, error, stack) => Container(
            color: AppColors.navy800,
            alignment: Alignment.center,
            child: const Icon(LucideIcons.imageOff, color: AppColors.darkTextMuted, size: 40),
          ),
        ),
        // Legibility scrims — 4 % veil per Foundations spec.
        Positioned(top: 0, left: 0, right: 0, height: 260, child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [AppColors.darkApp.withValues(alpha: .55), AppColors.darkApp.withValues(alpha: 0)],
        )))),
        Positioned(bottom: 0, left: 0, right: 0, height: 400, child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [AppColors.darkApp.withValues(alpha: 0), AppColors.darkApp.withValues(alpha: .78)],
        )))),
        // State overlay (play / pause / buffering / offline / limit).
        Align(alignment: const Alignment(0, -0.12), child: _center(item)),
        // Right action rail.
        Positioned(right: 4, bottom: bottomPad + 200, child: _rail(video)),
        // Bottom-left author block.
        Positioned(left: 16, right: 88, bottom: bottomPad + 44, child: _authorBlock(item)),
        // Heart burst on like.
        if (_burst) Center(child: TweenAnimationBuilder<double>(
          tween: Tween(begin: .4, end: 1),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
          child: Container(
            width: 84, height: 84,
            decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
            child: const Icon(LucideIcons.heart, size: 44, color: AppColors.danger),
          ),
        )),
      ]),
    );
  }

  // ── Top overlay : logo, avatar, tag chips, Pour vous / Suivis ────────
  Widget _topOverlay() => SafeArea(child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        Text.rich(
          const TextSpan(children: [
            TextSpan(text: 'SP'),
            TextSpan(text: 'O', style: TextStyle(color: AppColors.catEssais)),
            TextSpan(text: 'RA'),
          ]),
          style: AppTextStyles.display(color: AppColors.surface),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => context.read<AuthProvider>().isGuest
              ? context.push('/restricted', extra: 'vos highlights')
              : context.push('/highlights/mine'),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusInput),
            child: Container(
              width: 44, height: 44, color: AppColors.surface,
              child: Image.network(
                'https://i.pravatar.cc/120?u=spora_user',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => const Icon(LucideIcons.user, color: AppColors.navy800),
              ),
            ),
          ),
        ),
      ]),
      const SizedBox(height: 16),
      SizedBox(height: 40, child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: [for (final tag in _chips) Padding(padding: const EdgeInsets.only(right: 8), child: _chip(tag))],
      )),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (final tab in _tabs) Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: _segTab(tab)),
      ]),
      if (_state == 'Hors connexion') Padding(padding: const EdgeInsets.only(top: 12), child: _offlineBanner()),
      Align(alignment: Alignment.centerRight, child: PopupMenuButton<String>(
        tooltip: 'État de démonstration',
        initialValue: _state,
        onSelected: _applyState,
        itemBuilder: (_) => [for (final state in _states) PopupMenuItem(value: state, child: Text(state, style: AppTextStyles.caption()))],
        child: Padding(padding: const EdgeInsets.all(8), child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(LucideIcons.slidersHorizontal, size: 13, color: AppColors.darkTextMuted),
          const SizedBox(width: 4),
          Text('Démo : $_state', style: AppTextStyles.micro(color: AppColors.darkTextMuted)),
        ])),
      )),
    ]),
  ));

  Widget _chip(String tag) {
    final selected = _tag == tag;
    return GestureDetector(
      onTap: () => setState(() { _tag = tag; _page = 0; _state = 'Lecture'; }),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryTint : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          border: selected ? Border.all(color: AppColors.primary.withValues(alpha: .35)) : null,
        ),
        child: Text(tag, style: AppTextStyles.bodyStrong(color: selected ? AppColors.primary : AppColors.textSecondary)),
      ),
    );
  }

  Widget _segTab(String tab) {
    final selected = _tab == tab;
    return GestureDetector(
      onTap: () => setState(() { _tab = tab; _page = 0; _state = 'Lecture'; }),
      child: IntrinsicWidth(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(tab, style: AppTextStyles.h3(color: selected ? AppColors.surface : AppColors.darkTextMuted)),
        const SizedBox(height: 4),
        Container(height: 2, color: selected ? AppColors.surface : Colors.transparent),
      ])),
    );
  }

  Widget _offlineBanner() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppDimens.radiusCard)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(LucideIcons.wifiOff, color: AppColors.textSecondary, size: 26),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Vous êtes hors connexion', style: AppTextStyles.h3()),
        const SizedBox(height: 2),
        Text('Affiche enregistrée. La vidéo n’est pas disponible hors connexion.', style: AppTextStyles.caption(color: AppColors.textSecondary)),
      ])),
    ]),
  );

  // ── Center overlay per demo state ────────────────────────────────────
  Widget _center(_FeedItem item) {
    switch (_state) {
      case 'Chargement vidéo':
        return Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(width: 56, height: 56, child: CircularProgressIndicator(color: AppColors.surface, strokeWidth: 5)),
          const SizedBox(height: 18),
          Text('Chargement de la vidéo…', style: AppTextStyles.body(color: AppColors.surface)),
        ]);
      case 'Hors connexion':
        return Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(LucideIcons.wifiOff, size: 56, color: AppColors.surface),
          const SizedBox(height: 16),
          Text('Reconnectez-vous pour lire', style: AppTextStyles.h3(color: AppColors.surface)),
          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.surface, foregroundColor: AppColors.navy900),
            onPressed: _retry,
            child: Text('Réessayer', style: AppTextStyles.button(color: AppColors.navy900)),
          ),
        ]);
      case 'Limite gratuite atteinte':
        return FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.surface, foregroundColor: AppColors.navy900),
          onPressed: _limit,
          child: Text('Limite gratuite atteinte', style: AppTextStyles.button(color: AppColors.navy900)),
        );
      case 'Pause':
        return Column(mainAxisSize: MainAxisSize.min, children: [
          _playButton(),
          const SizedBox(height: 18),
          Text('Vidéo en pause · 00:16 / 00:42', style: AppTextStyles.body(color: AppColors.surface)),
        ]);
      case 'Économie de données':
        return Column(mainAxisSize: MainAxisSize.min, children: [
          _playButton(),
          const SizedBox(height: 18),
          Text('Appuyez pour lire · ${item.sizeMb} Mo', style: AppTextStyles.body(color: AppColors.surface)),
        ]);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _playButton() => Container(
    width: 56, height: 56,
    decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, boxShadow: AppShadows.elev2),
    child: const Icon(LucideIcons.play, color: AppColors.primary, size: 34),
  );

  // ── Right rail : like, comment, save, share, views ───────────────────
  Widget _rail(VideoModel video) {
    final liked = _liked.contains(video.id);
    final saved = _saved.contains(video.id);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _railButton(
        icon: liked ? LucideIcons.heart : LucideIcons.heart,
        color: liked ? AppColors.danger : AppColors.surface,
        label: _compact(video.likes + (liked ? 1 : 0)),
        onTap: () => _like(video.id),
      ),
      _railButton(icon: LucideIcons.messageCircle, label: _compact(video.comments), onTap: _comments),
      _railButton(
        icon: saved ? LucideIcons.bookmark : LucideIcons.bookmark,
        label: _compact(video.shares),
        onTap: () => setState(() => saved ? _saved.remove(video.id) : _saved.add(video.id)),
      ),
      _railButton(icon: LucideIcons.share2, label: 'Partager', onTap: () => _share(video)),
      Padding(padding: const EdgeInsets.only(bottom: 18), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(LucideIcons.eye, size: 30, color: AppColors.surface),
        Text(_compact(video.views), style: AppTextStyles.caption(color: AppColors.surface)),
      ])),
    ]);
  }

  Widget _railButton({required IconData icon, required String label, VoidCallback? onTap, Color color = AppColors.surface}) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      IconButton(onPressed: onTap, tooltip: label, iconSize: 30, color: color, icon: Icon(icon)),
      Text(label, style: AppTextStyles.caption(color: AppColors.surface)),
    ]),
  );

  // ── Bottom-left author block ─────────────────────────────────────────
  Widget _authorBlock(_FeedItem item) {
    final video = item.video;
    final liked = _liked.contains(video.id);
    final following = _following.contains(video.playerId);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        ClipOval(child: Image.network(
          video.playerAvatarUrl ?? 'https://i.pravatar.cc/120?u=${video.playerId}',
          width: 40, height: 40, fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(
            width: 40, height: 40, color: AppColors.navy700,
            alignment: Alignment.center,
            child: const Icon(LucideIcons.user, size: 22, color: AppColors.surface),
          ),
        )),
        const SizedBox(width: 10),
        Flexible(child: Text(video.playerName, style: AppTextStyles.h3(color: AppColors.surface), overflow: TextOverflow.ellipsis)),
        if (item.verified) ...[
          const SizedBox(width: 6),
          const Icon(LucideIcons.badgeCheck, size: 18, color: AppColors.primary),
        ],
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => setState(() => following ? _following.remove(video.playerId) : _following.add(video.playerId)),
          child: Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: following ? AppColors.darkApp.withValues(alpha: .35) : AppColors.primary,
              border: following ? Border.all(color: AppColors.surface.withValues(alpha: .6)) : null,
              borderRadius: BorderRadius.circular(AppDimens.radiusPill),
            ),
            child: Text(following ? 'Suivi' : 'Suivre', style: AppTextStyles.caption(color: AppColors.surface).copyWith(fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
      const SizedBox(height: 10),
      Text('${item.position} · ${item.level}', style: AppTextStyles.caption(color: AppColors.darkTextSecondary)),
      const SizedBox(height: 10),
      Text(video.title, style: AppTextStyles.h2(color: AppColors.surface), maxLines: 2, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 8),
      Text('${_compact(video.views)} vues · ${item.postedAgo}', style: AppTextStyles.caption(color: AppColors.darkTextSecondary)),
      const SizedBox(height: 6),
      GestureDetector(
        onTap: () => context.push('/player/${video.playerId}'),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('Voir le profil', style: AppTextStyles.button(color: AppColors.surface)),
          const SizedBox(width: 6),
          const Icon(LucideIcons.arrowRight, size: 18, color: AppColors.surface),
        ]),
      ),
      if (liked) ...[
        const SizedBox(height: 8),
        Text('Vous aimez cette vidéo', style: AppTextStyles.body(color: AppColors.surface)),
      ],
    ]);
  }
}
