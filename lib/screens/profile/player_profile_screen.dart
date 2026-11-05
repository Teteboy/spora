import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/player_model.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'profile_mock_data.dart';
import 'profile_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Public player profile — /player/:id
///
/// Variants (see design/screens/04-profiles):
/// - public view of Jordan (default, verified viewer): navy hero cover with
///   overlapping avatar, « Disponible » pill on the cover edge, verified seal
///   next to the name and underline tabs (frame « 09 · Talent »)
/// - owner view ([isOwner]): « Mon profil » + stats + « Modifier le profil »
/// - locked highlights ([viewerVerified] = false): « Profil de Jordan »,
///   classic header + locked gallery + Premium CTA
/// - under-18 (player.age < 18): « Profil protégé », masked contact details
class PlayerProfileScreen extends StatefulWidget {
  final PlayerModel? player;
  final bool isOwner;
  final bool viewerVerified;
  const PlayerProfileScreen({
    super.key,
    this.player,
    this.isOwner = false,
    this.viewerVerified = true,
  });

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  int _tab = 0; // 0 Fiche technique · 1 Highlights · 2 Parcours
  String _highlightFilter = 'Tout';

  static const Color _availableBg = Color(0xFFDFF3EA);
  static const String _coverUrl =
      'https://images.unsplash.com/photo-1526232761682-d26e03ac148e?w=800&h=450&fit=crop&auto=format&q=80';

  bool get _isMinor => _player.age < 18;
  late final PlayerModel _player = widget.player ?? ProfileMockData.jordan;

  String _positionCode() {
    final m = RegExp(r'\(([^)]+)\)').firstMatch(_player.primaryPosition);
    return m?.group(1) ?? _player.primaryPosition;
  }

  String _positionLabel() {
    final p = _player.primaryPosition;
    final i = p.indexOf('(');
    return i > 0 ? p.substring(0, i).trim() : p;
  }

  String get _metaLine =>
      '${_positionLabel()} · ${_player.age} ans · ${_player.nationality}';

  String get _clubLine => _player.city.isEmpty
      ? _player.currentClub
      : '${_player.currentClub} · ${_player.city}';

  @override
  Widget build(BuildContext context) {
    if (_isMinor) return _buildMinor(context);
    if (widget.isOwner) return _buildOwner(context);
    if (!widget.viewerVerified) return _buildLocked(context);
    return _buildPublic(context);
  }

  bool get _canMessage {
    final type = context.read<AuthProvider>().selectedUserType;
    return type != UserType.player && type != UserType.guest;
  }

  // ---------------------------------------------------------------- PUBLIC
  // Frame « 09 · Talent — Profil public de Jordan »: full-bleed navy hero with
  // overlapping avatar, verified seal by the name, underline tabs.

  Widget _buildPublic(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _heroHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.screenMargin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _nameRow(),
                  const SizedBox(height: 10),
                  _premiumMetaRow(),
                  const SizedBox(height: 10),
                  _clubRow(),
                  const SizedBox(height: 20),
                  _statsRow(),
                  const SizedBox(height: 4),
                  _tabsBar(),
                  const SizedBox(height: 20),
                  _tabContent(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _actionsBar(),
    );
  }

  /// Navy hero: cover photo + play button + back/menu buttons, overlapping
  /// avatar (bottom-left) and « Disponible » pill on the cover edge.
  Widget _heroHeader() {
    const double coverH = 190;
    const double avatarD = 84;
    const double overlap = avatarD / 2;
    return SizedBox(
      height: coverH + overlap,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: coverH,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppDimens.radiusHero),
                bottomRight: Radius.circular(AppDimens.radiusHero),
              ),
              child: Container(
                color: AppColors.navy900,
                child: Image.network(
                  _coverUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) =>
                      progress == null
                          ? child
                          : const ColoredBox(color: AppColors.navy900),
                  errorBuilder: (context, error, stackTrace) =>
                      const ColoredBox(color: AppColors.navy900),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: coverH,
            child: Center(
              child: GestureDetector(
                onTap: () => context.push('/video-player'),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.elev2,
                  ),
                  child: const Icon(LucideIcons.play,
                      color: AppColors.primary, size: 30),
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: AppDimens.screenMargin,
            child: _heroIconButton(
                icon: LucideIcons.arrowLeft,
                onTap: () => Navigator.of(context).maybePop()),
          ),
          Positioned(
            top: 16,
            right: AppDimens.screenMargin,
            child: _heroMenu(),
          ),
          Positioned(
            left: AppDimens.screenMargin,
            bottom: 0,
            child: _avatar(size: avatarD, ring: true),
          ),
          const Positioned(
            right: AppDimens.screenMargin,
            bottom: overlap - 14,
            child: BadgePill(
                label: 'Disponible', bg: _availableBg, fg: AppColors.clubGreen),
          ),
        ],
      ),
    );
  }

  Widget _heroIconButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusInput),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.elev1,
        ),
        child: Icon(icon, color: AppColors.navy900, size: 22),
      ),
    );
  }

  /// Top-right white square — report/block menu (Partager · Signaler · Bloquer).
  Widget _heroMenu() {
    return PopupMenuButton<String>(
      onSelected: _onMenuAction,
      color: AppColors.surface,
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusInput)),
      itemBuilder: (context) => [
        _menuEntry('partager', LucideIcons.share2, 'Partager'),
        _menuEntry('signaler', LucideIcons.flag, 'Signaler'),
        _menuEntry('bloquer', LucideIcons.ban, 'Bloquer'),
      ],
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusInput),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.elev1,
        ),
        child: const Icon(LucideIcons.moreVertical,
            color: AppColors.navy900, size: 22),
      ),
    );
  }

  PopupMenuItem<String> _menuEntry(
      String value, IconData icon, String label) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(label, style: AppTextStyles.bodyStrong()),
        ],
      ),
    );
  }

  void _onMenuAction(String action) {
    final message = switch (action) {
      'partager' => 'Lien du profil copié',
      'signaler' => 'Joueur signalé. Merci pour votre vigilance.',
      _ => 'Joueur bloqué',
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// Circular avatar with optional white ring; initials fallback on error.
  Widget _avatar({required double size, bool ring = false}) {
    final url =
        _player.avatarUrl ?? 'https://i.pravatar.cc/200?u=${_player.id}';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.muted,
        border: ring
            ? Border.all(color: AppColors.surface, width: 3)
            : null,
        boxShadow: ring ? AppShadows.elev1 : null,
      ),
      child: ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) =>
              progress == null
                  ? child
                  : const ColoredBox(color: AppColors.muted),
          errorBuilder: (context, error, stackTrace) =>
              _avatarFallback(size),
        ),
      ),
    );
  }

  Widget _avatarFallback(double size) {
    String initial(String s) => s.isEmpty ? '' : s[0].toUpperCase();
    final initials =
        '${initial(_player.firstName)}${initial(_player.lastName)}';
    return Container(
      width: size,
      height: size,
      color: AppColors.muted,
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: AppTextStyles.h3(color: AppColors.primary),
      ),
    );
  }

  /// Name + blue verified seal (frame 09).
  Widget _nameRow() {
    return Row(
      children: [
        Flexible(
          child: Text(_player.fullName,
              style: AppTextStyles.display(),
              overflow: TextOverflow.ellipsis),
        ),
        if (_player.isVerified) ...[
          const SizedBox(width: 8),
          const Icon(LucideIcons.badgeCheck,
              color: AppColors.primary, size: 24),
        ],
      ],
    );
  }

  Widget _premiumMetaRow() {
    return Row(
      children: [
        if (_player.isPremium) ...[
          const BadgePill(
              label: 'Premium',
              icon: LucideIcons.crown,
              bg: AppColors.premiumBg,
              fg: AppColors.goldDark),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(_metaLine,
              style: AppTextStyles.body(), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  /// Club line with a small shield crest holding the club initial.
  Widget _clubRow() {
    final initial =
        _player.currentClub.isNotEmpty ? _player.currentClub[0] : '•';
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryTint,
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(LucideIcons.shield,
                  color: AppColors.primary, size: 22),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(initial,
                    style: AppTextStyles.micro(color: AppColors.primary)
                        .copyWith(
                            fontSize: 9, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(_clubLine,
              style: AppTextStyles.body(), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _statsRow() {
    return Row(
      children: [
        Expanded(
            child: StatCell(
                value:
                    '${_player.height.toStringAsFixed(2).replaceAll('.', ',')} m',
                label: 'Taille')),
        Expanded(
            child:
                StatCell(value: _player.dominantFoot, label: 'Pied fort')),
        Expanded(child: StatCell(value: _positionCode(), label: 'Poste')),
      ],
    );
  }

  /// Underline tab bar (frame 09): selected tab in blue with a blue indicator.
  Widget _tabsBar() {
    const labels = ['Fiche technique', 'Highlights', 'Parcours'];
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _tab = i),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        labels[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyStrong(
                          color: _tab == i
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                    Container(
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: _tab == i
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusPill),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Pill-chip tabs used by the owner and locked frames.
  Widget _tabChips() {
    const labels = ['Fiche technique', 'Highlights', 'Parcours'];
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          PillChip(
              label: labels[i],
              selected: _tab == i,
              onTap: () => setState(() => _tab = i)),
          if (i < labels.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _tabContent({bool owner = false}) {
    switch (_tab) {
      case 1:
        return _highlightsTab();
      case 2:
        return _careerTab();
      default:
        return _infosTab(owner: owner);
    }
  }

  // ------------------------------------------------------------ CLASSIC
  // Shared header for the owner and locked frames: rounded cover photo,
  // avatar + status pills, name, « Identité vérifiée » and meta lines.

  List<Widget> _classicHeader({bool owner = false}) {
    return [
      const SizedBox(height: 8),
      _coverPhoto(),
      const SizedBox(height: 12),
      _identityRow(),
      const SizedBox(height: 12),
      Text(_player.fullName, style: AppTextStyles.h1()),
      if (_player.isVerified) ...[
        const SizedBox(height: 4),
        Row(children: [
          const Icon(LucideIcons.checkCircle2,
              size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text('Identité vérifiée',
              style: AppTextStyles.caption(color: AppColors.primary)),
        ]),
      ],
      const SizedBox(height: 8),
      Text(_metaLine, style: AppTextStyles.body()),
      Text(_clubLine, style: AppTextStyles.body()),
      const SizedBox(height: 16),
      _statsRow(),
      const SizedBox(height: 20),
      _tabChips(),
      const SizedBox(height: 16),
      _tabContent(owner: owner),
    ];
  }

  Widget _coverPhoto() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusHero),
      child: Container(
        height: 170,
        color: AppColors.navy900,
        child: Image.network(
          _coverUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) =>
              progress == null
                  ? child
                  : const ColoredBox(color: AppColors.navy900),
          errorBuilder: (context, error, stackTrace) =>
              const ColoredBox(color: AppColors.navy900),
        ),
      ),
    );
  }

  Widget _identityRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _avatar(size: 60),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              const BadgePill(
                  label: 'Disponible',
                  bg: _availableBg,
                  fg: AppColors.clubGreen),
              if (_player.isPremium) ...[
                const SizedBox(height: 8),
                const BadgePill(
                    label: 'Premium',
                    icon: LucideIcons.crown,
                    bg: AppColors.premiumBg,
                    fg: AppColors.goldDark),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------- FICHE TECHNIQUE

  Widget _infosTab({required bool owner}) {
    if (owner) {
      // Owner frame: stacked layout, full-width pitch, infos card.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ProfileMockData.jordanHeadline, style: AppTextStyles.h2()),
          const SizedBox(height: 8),
          Text(ProfileMockData.jordanBio, style: AppTextStyles.body()),
          const SizedBox(height: 16),
          _pitchBadge(height: 100),
          const SizedBox(height: 16),
          _footballInfosCard(),
          const SizedBox(height: 16),
          _objectiveCard(),
        ],
      );
    }
    // Frame 09: text column on the left, mini pitch on the right.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ProfileMockData.jordanHeadline,
                      style: AppTextStyles.h2()),
                  const SizedBox(height: 8),
                  Text(ProfileMockData.jordanBio,
                      style: AppTextStyles.body()),
                  const SizedBox(height: 12),
                  Text(
                      'Niveau ${_player.leagueDivision} · ${_player.weight.toInt()} kg',
                      style: AppTextStyles.caption()),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _pitchBadge(width: 150, height: 112),
          ],
        ),
        const SizedBox(height: 16),
        _objectiveCard(),
      ],
    );
  }

  Widget _footballInfosCard() {
    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informations football', style: AppTextStyles.h3()),
          const SizedBox(height: 8),
          _infoLine('Poids · ${_player.weight.toInt()} kg'),
          _infoLine('Niveau · ${_player.leagueDivision}'),
          _infoLine('Pied fort · ${_player.dominantFoot}'),
          _infoLine('Nationalité · ${_player.nationality}'),
          _infoLine('Club actuel · ${_player.currentClub}'),
          _infoLine('Membre depuis · 12 septembre 2026'),
        ],
      ),
    );
  }

  Widget _objectiveCard() {
    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Objectif sportif', style: AppTextStyles.h3()),
          const SizedBox(height: 8),
          Text(ProfileMockData.jordanObjective, style: AppTextStyles.body()),
        ],
      ),
    );
  }

  Widget _infoLine(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(text, style: AppTextStyles.body()),
      );

  /// Mini football pitch (field lines + centre circle) with the position badge.
  Widget _pitchBadge({double? width, double height = 112}) {
    final line = Colors.white.withValues(alpha: 0.85);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      child: Container(
        width: width ?? double.infinity,
        height: height,
        color: AppColors.clubGreen,
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: line, width: 1.5),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                  child: Container(height: 1.5, color: line),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: line, width: 1.5),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(_positionCode(),
                    style:
                        AppTextStyles.bodyStrong(color: AppColors.clubGreen)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------- HIGHLIGHTS

  Widget _highlightsTab() {
    if (!widget.viewerVerified && !widget.isOwner) {
      return _lockedHighlights();
    }
    const filters = ['Tout', 'BUT', 'SKILLS', 'PASSES'];
    final videos = _player.highlights;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) => PillChip(
                label: filters[i],
                selected: _highlightFilter == filters[i],
                onTap: () =>
                    setState(() => _highlightFilter = filters[i])),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: videos.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (_, i) => _videoTile(videos[i]),
        ),
      ],
    );
  }

  String _formatViews(int views) {
    if (views >= 1000) {
      final k = views / 1000;
      return '${k.toStringAsFixed(k >= 10 ? 0 : 1).replaceAll('.', ',')} K';
    }
    return '$views';
  }

  Widget _videoTile(VideoModel v) {
    return GestureDetector(
      onTap: () => context.push('/video-player'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusCard),
              child: Container(
                color: AppColors.navy800,
                child: Image.network(
                  v.thumbnailUrl ?? 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=400&h=225&fit=crop&auto=format&q=80',
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) =>
                      progress == null
                          ? child
                          : const ColoredBox(color: AppColors.navy800),
                  errorBuilder: (context, error, stackTrace) =>
                      const ColoredBox(color: AppColors.navy800),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(v.title,
              style: AppTextStyles.bodyStrong(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text('00:42 · ${_formatViews(v.views)} vues · ${v.likes} j’aime',
              style: AppTextStyles.caption(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  /// Highlights locked for non-verified viewers (frame « Highlights
  /// verrouillés »): info banner + presentation video + Premium CTA card.
  Widget _lockedHighlights() {
    return Column(
      children: [
        const InfoBanner(
          title: 'Highlights supplémentaires verrouillés',
          body:
              'Avec un compte gratuit, consultez la vidéo de présentation. Premium débloque les highlights supplémentaires, sans modifier les règles de contact ni la vérification.',
        ),
        const SizedBox(height: 16),
        _coverPhoto(),
        const SizedBox(height: 16),
        ProfileCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.lock,
                  color: AppColors.primary, size: 28),
              const SizedBox(height: 8),
              Text('Plus d’actions à découvrir', style: AppTextStyles.h3()),
              const SizedBox(height: 4),
              Text(
                  'Le badge Premium indique un abonnement, pas une identité vérifiée.',
                  style: AppTextStyles.body()),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => context.push('/premium'),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient:
                        const LinearGradient(colors: AppColors.goldGradient),
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusInput),
                  ),
                  alignment: Alignment.center,
                  child: Text('Découvrir Premium',
                      style:
                          AppTextStyles.button(color: AppColors.navy900)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
            'Coordonnées personnelles et localisation exacte masquées. Seuls les agents et clubs vérifiés peuvent voir et contacter les joueurs.',
            style: AppTextStyles.caption()),
      ],
    );
  }

  // --------------------------------------------------------------- PARCOURS

  Widget _careerTab() {
    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Parcours sportif', style: AppTextStyles.h2()),
          const SizedBox(height: 12),
          for (final e in ProfileMockData.jordanCareer)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                      e.isCurrent
                          ? LucideIcons.crosshair
                          : LucideIcons.circle,
                      color: AppColors.primary,
                      size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.title, style: AppTextStyles.bodyStrong()),
                        const SizedBox(height: 2),
                        Text('${e.period} · ${e.detail}',
                            style: AppTextStyles.body()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const Divider(color: AppColors.divider),
          Text('Parcours d’exemple déclaré par le joueur.',
              style: AppTextStyles.caption()),
        ],
      ),
    );
  }

  Widget _actionsBar() {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            if (_canMessage)
              Expanded(
                child: PrimaryButton(
                    label: 'Contacter',
                    onTap: () =>
                        context.push('/chat/${_player.id}', extra: {
                          'name': _player.fullName,
                          'avatar': _player.avatarUrl,
                          'role': 'Joueur',
                        })),
              ),
            if (_canMessage) const SizedBox(width: 12),
            Expanded(
              child: OutlineButton(
                  label: 'Ajouter à ma liste',
                  icon: LucideIcons.bookmark,
                  onTap: () => context.read<AuthProvider>().isGuest
                      ? context.push('/restricted', extra: 'votre liste de talents')
                      : context.push('/my-list')),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------- LOCKED

  /// Non-verified viewer (frame « Jordan — Highlights verrouillés »):
  /// classic header, pill tabs, locked highlights behind Premium.
  Widget _buildLocked(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: ProfileAppBar(title: 'Profil de ${_player.firstName}'),
      body: ListView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.screenMargin),
        children: [
          ..._classicHeader(),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: _actionsBar(),
    );
  }

  // ----------------------------------------------------------------- OWNER

  Widget _buildOwner(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: const ProfileAppBar(title: 'Mon profil'),
      body: ListView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.screenMargin),
        children: [
          ..._classicHeader(owner: true),
          const SizedBox(height: 16),
          _viewsCard(),
          const SizedBox(height: 16),
          _completionCard(),
          const SizedBox(height: 16),
          _premiumCard(),
          const SizedBox(height: 16),
          Text(
              'Coordonnées personnelles et localisation exacte masquées. Seuls les agents et clubs vérifiés peuvent voir et contacter les joueurs.',
              style: AppTextStyles.caption()),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: PrimaryButton(
              label: 'Modifier le profil',
              icon: LucideIcons.pencil,
              onTap: () => context.push('/edit-profile')),
        ),
      ),
    );
  }

  Widget _viewsCard() {
    const bars = [0.45, 0.65, 0.5, 0.75, 0.6, 0.85, 1.0];
    const days = ['S', 'D', 'L', 'M', 'M', 'J', 'V'];
    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${_player.profileViews} vues · +18 %',
              style: AppTextStyles.h2()),
          const SizedBox(height: 4),
          Text('Du 10 au 16 octobre 2026 · 7 jours',
              style: AppTextStyles.caption()),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < bars.length; i++)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: bars[i],
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(days[i], style: AppTextStyles.micro()),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _completionCard() {
    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profil complété à 70 %', style: AppTextStyles.h3()),
          const SizedBox(height: 8),
          Text('70 %',
              style: AppTextStyles.bodyStrong(color: AppColors.primary)),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
            child: const LinearProgressIndicator(
              value: 0.7,
              minHeight: 6,
              backgroundColor: AppColors.muted,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text('✓ Photo ajoutée · ✓ Club renseigné',
              style: AppTextStyles.caption(color: AppColors.clubGreen)),
          const SizedBox(height: 4),
          Text('À compléter : votre parcours et votre vidéo de présentation.',
              style: AppTextStyles.caption()),
          const SizedBox(height: 12),
          OutlineButton(
              label: 'Compléter mon profil',
              onTap: () => context.push('/edit-profile')),
        ],
      ),
    );
  }

  Widget _premiumCard() {
    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BadgePill(
              label: 'Premium',
              icon: LucideIcons.crown,
              bg: AppColors.premiumBg,
              fg: AppColors.goldDark),
          const SizedBox(height: 8),
          Text('Donnez plus de place à votre jeu',
              style: AppTextStyles.h3()),
          const SizedBox(height: 4),
          Text(
              'Highlights illimités et statistiques détaillées. Le badge Premium ne vérifie pas votre identité.',
              style: AppTextStyles.body()),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => context.push('/premium'),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(colors: AppColors.goldGradient),
                borderRadius:
                    BorderRadius.circular(AppDimens.radiusInput),
              ),
              alignment: Alignment.center,
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.crown,
                        color: AppColors.navy900, size: 18),
                    const SizedBox(width: 8),
                    Text('Passer à Premium',
                        style:
                            AppTextStyles.button(color: AppColors.navy900)),
                  ]),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------- MINOR

  Widget _buildMinor(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: const ProfileAppBar(title: 'Profil protégé'),
      body: ListView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.screenMargin),
        children: [
          const SizedBox(height: 16),
          ProfileCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(LucideIcons.shieldCheck,
                    color: AppColors.primary, size: 56),
                const SizedBox(height: 12),
                Text('Joueur ${_player.leagueDivision}',
                    style: AppTextStyles.display()),
                const SizedBox(height: 4),
                Text(_metaLine, style: AppTextStyles.body()),
                const SizedBox(height: 12),
                const BadgePill(
                    label: 'Consentement du tuteur validé',
                    bg: _availableBg,
                    fg: AppColors.clubGreen),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius:
                  BorderRadius.circular(AppDimens.radiusCard),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Visible aux recruteurs vérifiés uniquement',
                    style:
                        AppTextStyles.bodyStrong(color: AppColors.primary)),
                const SizedBox(height: 4),
                Text(
                    'Coordonnées et localisation précise masquées. Contact réservé aux agents et clubs vérifiés.',
                    style: AppTextStyles.body(color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                  child: StatCell(
                      value: _player.leagueDivision, label: 'Niveau')),
              Expanded(
                  child: StatCell(
                      value: _player.dominantFoot, label: 'Pied')),
              Expanded(
                  child:
                      StatCell(value: _positionCode(), label: 'Poste')),
            ],
          ),
          const SizedBox(height: 24),
          Text('Fiche sportive', style: AppTextStyles.h2()),
          const SizedBox(height: 8),
          Text(
              'Profil sportif de démonstration. Le nom public et la visibilité respectent les choix validés par le représentant légal.',
              style: AppTextStyles.body()),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Contacter via SPORA', onTap: () {}),
          const SizedBox(height: 12),
          Text(
              'Vue d’un recruteur vérifié · E-mail vérifié requis. Avant consentement, le profil n’apparaît pas.',
              style: AppTextStyles.caption()),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
