import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock_data.dart';
import '../../models/player_model.dart';
import '../home/home_screen.dart' show positionShort;
import 'discover_states.dart';
import 'filters_screen.dart';
import '../../core/constants/spora_images.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum DiscoverTab { players, agents, clubs }

enum _FeedState { loading, ready, refreshing, offline, error }

/// SPORA Discover — /discover
/// Segmented Joueurs / Agents / Clubs with search, filters and sort.
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  DiscoverTab _tab = DiscoverTab.players;
  _FeedState _state = _FeedState.loading;
  // Frame 06: applied chips "Attaquant ×" + "Disponible ×".
  DiscoverFilters _filters =
      const DiscoverFilters(position: 'ATT', availableOnly: true);
  String _sort = 'Plus pertinents';
  bool _offline = false;

  static const _sorts = [
    'Plus pertinents',
    'Plus récents',
    'Mieux notés',
    'Plus jeunes',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _state = _FeedState.loading);
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() => _state = _FeedState.ready);
  }

  Future<void> _refresh() async {
    setState(() => _state = _FeedState.refreshing);
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() => _state = _FeedState.ready);
  }

  bool _isAvailable(PlayerModel p) => DiscoverFilters.isAvailable(p);

  List<PlayerModel> get _players {
    var list = MockData.trendingPlayers.where(_filters.matches).toList();
    if (_sort == 'Mieux notés') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sort == 'Plus jeunes') {
      list.sort((a, b) => a.age.compareTo(b.age));
    }
    return list;
  }

  Future<void> _openFilters() async {
    final result = await context.push<DiscoverFilters>('/filters',
        extra: _filters);
    if (result != null && mounted) {
      setState(() => _filters = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildBanner(),
            _buildSegmented(),
            _buildSearchRow(context),
            _buildChips(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimens.screenMargin,
          AppDimens.sm, AppDimens.screenMargin, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Découvrir', style: AppTextStyles.display()),
          GestureDetector(
            onTap: () => context.read<AuthProvider>().isGuest
                ? context.push('/restricted', extra: 'la messagerie')
                : context.go('/messages'),
            child: Container(
              width: AppDimens.minTouch,
              height: AppDimens.minTouch,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(AppDimens.radiusInput),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(LucideIcons.messageCircle,
                  size: 22, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    switch (_tab) {
      case DiscoverTab.players:
        return const SizedBox(height: AppDimens.sm);
      case DiscoverTab.clubs:
        // Frame 07 — full-bleed navy banner, square corners.
        return Container(
          width: double.infinity,
          color: AppColors.navy900,
          padding: const EdgeInsets.fromLTRB(AppDimens.screenMargin,
              AppDimens.xxl, AppDimens.screenMargin, AppDimens.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Les clubs cherchent\nles talents.',
                  style:
                      AppTextStyles.display(color: AppColors.textLight)),
              const SizedBox(height: AppDimens.md),
              Text('Votre prochain défi commence ici.',
                  style: AppTextStyles.bodyLarge(
                      color: AppColors.darkTextSecondary)),
            ],
          ),
        );
      case DiscoverTab.agents:
        // Frame agents — tinted card with margins.
        return Padding(
          padding: const EdgeInsets.fromLTRB(AppDimens.screenMargin,
              AppDimens.sm, AppDimens.screenMargin, AppDimens.sm),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimens.xl),
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius:
                  BorderRadius.circular(AppDimens.radiusCard),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trouvez le bon accompagnement',
                    style:
                        AppTextStyles.h3(color: AppColors.primary)),
                const SizedBox(height: AppDimens.xs),
                Text('Des agents et des agences à découvrir.',
                    style:
                        AppTextStyles.body(color: AppColors.primary)),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildSegmented() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.screenMargin, vertical: AppDimens.sm),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.xs),
        decoration: BoxDecoration(
          color: AppColors.muted,
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        ),
        child: Row(
          children: [
            _segment('Joueurs', DiscoverTab.players),
            _segment('Agents', DiscoverTab.agents),
            _segment('Clubs', DiscoverTab.clubs),
          ],
        ),
      ),
    );
  }

  Widget _segment(String label, DiscoverTab tab) {
    final active = _tab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(vertical: AppDimens.sm),
          decoration: BoxDecoration(
            color: active ? AppColors.surface : Colors.transparent,
            borderRadius:
                BorderRadius.circular(AppDimens.radiusPill),
            boxShadow: active ? AppShadows.elev1 : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyStrong(
                color: active ? AppColors.primary : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchRow(BuildContext context) {
    final hint = switch (_tab) {
      DiscoverTab.players => 'Rechercher un joueur…',
      DiscoverTab.agents => 'Un agent, une agence, un pays…',
      DiscoverTab.clubs => 'Un club, un pays…',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.screenMargin, vertical: AppDimens.xs),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/search'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.lg, vertical: AppDimens.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusCard),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recherche', style: AppTextStyles.caption()),
                    Row(children: [
                      const Icon(LucideIcons.search,
                          size: 18, color: AppColors.textMuted),
                      const SizedBox(width: AppDimens.sm),
                      Expanded(
                        child: Text(hint,
                            style: AppTextStyles.body(
                                color: AppColors.textHint),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimens.sm),
          GestureDetector(
            onTap: _openFilters,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(AppDimens.radiusCard),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(LucideIcons.slidersHorizontal,
                  size: 22, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChips() {
    if (_tab != DiscoverTab.players) {
      return const SizedBox(height: AppDimens.xs);
    }
    final chips = _filters.activeLabels(isAvailableLabel: true);
    if (chips.isEmpty) return const SizedBox(height: AppDimens.xs);
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: AppDimens.screenMargin),
        children: [
          for (final c in chips)
            Padding(
              padding: const EdgeInsets.only(right: AppDimens.sm),
              child: _FilterChipPill(
                label: c.$1,
                onRemove: () => setState(
                    () => _filters = _filters.without(c.$2)),
              ),
            ),
          GestureDetector(
            onTap: _openFilters,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: AppDimens.sm),
              child: Text('Filtres',
                  style: AppTextStyles.bodyStrong(
                      color: AppColors.textSecondary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_offline) {
      return ListView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.screenMargin),
        children: [
          const OfflineBanner(),
          const SizedBox(height: AppDimens.md),
          Text('2 profils en cache', style: AppTextStyles.bodyStrong()),
          const SizedBox(height: AppDimens.md),
          ...MockData.trendingPlayers
              .take(2)
              .map((p) => PlayerListTile(player: p)),
          TextButton(
            onPressed: () => setState(() => _offline = false),
            child: Text('Réessayer',
                style: AppTextStyles.bodyStrong(color: AppColors.primary)),
          ),
        ],
      );
    }
    switch (_state) {
      case _FeedState.loading:
        return const DiscoverLoading();
      case _FeedState.error:
        return ErrorState(onRetry: _load);
      case _FeedState.refreshing:
      case _FeedState.ready:
      case _FeedState.offline:
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _refresh,
          child: _buildResults(),
        );
    }
  }

  Widget _buildResults() {
    final forYou = MockData.trendingPlayers.take(3).toList();
    return ListView(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.screenMargin),
      children: [
        if (_state == _FeedState.refreshing) const DiscoverRefreshing(),
        _buildCountRow(),
        const SizedBox(height: AppDimens.md),
        ..._buildCards(),
        const SizedBox(height: AppDimens.section),
        if (_tab == DiscoverTab.players && forYou.isNotEmpty) ...[
          Text('Pour vous', style: AppTextStyles.h2()),
          const SizedBox(height: AppDimens.sm),
          Text('Sélectionnés selon vos recherches récentes',
              style: AppTextStyles.caption()),
          const SizedBox(height: AppDimens.md),
          ...forYou.map((p) => PlayerListTile(player: p)),
        ],
        const SizedBox(height: AppDimens.xxxl),
      ],
    );
  }

  Widget _buildCountRow() {
    final (count, label) = switch (_tab) {
      DiscoverTab.players => (_players.length, 'joueurs'),
      DiscoverTab.agents => (_agents.length, 'agents disponibles'),
      DiscoverTab.clubs => (_clubs.length, 'clubs disponibles'),
    };
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$count $label', style: AppTextStyles.h3()),
        if (_tab == DiscoverTab.players)
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _sort,
              isDense: true,
              icon: const Icon(LucideIcons.chevronDown,
                  size: 16, color: AppColors.textSecondary),
              style: AppTextStyles.body(),
              items: _sorts
                  .map((s) =>
                      DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _sort = v ?? _sort),
            ),
          )
        else
          Text('Tous les pays',
              style: AppTextStyles.bodyStrong(
                  color: _tab == DiscoverTab.clubs
                      ? AppColors.clubGreen
                      : AppColors.primary)),
      ],
    );
  }

  List<Widget> _buildCards() {
    switch (_tab) {
      case DiscoverTab.players:
        final players = _players;
        if (players.isEmpty) {
          return [
            SizedBox(
              height: 380,
              child: EmptyResultsState(
                onReset: () =>
                    setState(() => _filters = const DiscoverFilters()),
              ),
            ),
          ];
        }
        return [
          for (var i = 0; i < players.length; i++)
            i == 0
                ? _PlayerFeatureCard(
                    player: players[i],
                    available: _isAvailable(players[i]),
                  )
                : PlayerListTile(player: players[i]),
        ];
      case DiscoverTab.agents:
        return _agents.map((a) => _AgentCard(agent: a)).toList();
      case DiscoverTab.clubs:
        return _clubs.map((c) => _ClubCard(club: c)).toList();
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Compact player row (results after the featured card)
// ─────────────────────────────────────────────────────────────
class PlayerListTile extends StatelessWidget {
  final PlayerModel player;
  const PlayerListTile({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/player/${player.id}', extra: player),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimens.md),
        padding: const EdgeInsets.all(AppDimens.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          boxShadow: AppShadows.elev1,
        ),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusInput),
            child: Image.network(
              sporaImage('row-${player.id}', w: 160, h: 160),
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              loadingBuilder: (c, w, p) => p == null
                  ? w
                  : Container(
                      width: 56, height: 56, color: AppColors.muted),
              errorBuilder: (_, __, ___) => Container(
                width: 56,
                height: 56,
                color: AppColors.navy800,
                child: const Icon(LucideIcons.user,
                    color: AppColors.textMuted),
              ),
            ),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Flexible(
                    child: Text(player.fullName,
                        style: AppTextStyles.bodyStrong(),
                        overflow: TextOverflow.ellipsis),
                  ),
                  if (player.isVerified) ...[
                    const SizedBox(width: 4),
                    const Icon(LucideIcons.badgeCheck,
                        size: 16, color: AppColors.primary),
                  ],
                ]),
                const SizedBox(height: 4),
                Text(
                  '${positionShort(player.primaryPosition)} · ${player.age} ans · ${player.nationality}',
                  style: AppTextStyles.caption(),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight, color: AppColors.textMuted),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Filter chip pill
// ─────────────────────────────────────────────────────────────
class _FilterChipPill extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _FilterChipPill({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.md, vertical: AppDimens.xs),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label,
            style: AppTextStyles.bodyStrong(color: AppColors.primary)),
        const SizedBox(width: AppDimens.xs),
        GestureDetector(
          onTap: onRemove,
          child: const Icon(LucideIcons.x,
              size: 14, color: AppColors.primary),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Player feature card (first result — large)
// ─────────────────────────────────────────────────────────────
class _PlayerFeatureCard extends StatelessWidget {
  final PlayerModel player;
  final bool available;
  const _PlayerFeatureCard(
      {required this.player, required this.available});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.network(
                sporaImage('feature-${player.id}', w: 800, h: 600),
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (c, w, p) =>
                    p == null ? w : Container(color: AppColors.muted),
                errorBuilder: (_, __, ___) =>
                    Container(color: AppColors.muted),
              ),
            ),
            if (available)
              Positioned(
                top: AppDimens.md,
                left: AppDimens.md,
                child: _BadgePill(
                  label: 'Disponible',
                  color: AppColors.clubGreen,
                  icon: null,
                ),
              ),
            if (player.isPremium)
              const Positioned(
                top: AppDimens.md,
                right: AppDimens.md,
                child: _BadgePill(
                  label: 'Premium',
                  color: AppColors.goldDark,
                  icon: LucideIcons.crown,
                ),
              ),
          ]),
          Padding(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Flexible(
                    child: Text(player.fullName,
                        style: AppTextStyles.h2(),
                        overflow: TextOverflow.ellipsis),
                  ),
                  if (player.isVerified) ...[
                    const SizedBox(width: AppDimens.xs),
                    const Icon(LucideIcons.badgeCheck,
                        size: 18, color: AppColors.primary),
                  ],
                ]),
                const SizedBox(height: AppDimens.xs),
                Text(
                  '${player.age} ans · ${player.nationality} · ${player.city} · ${player.leagueDivision}',
                  style: AppTextStyles.body(),
                ),
                const SizedBox(height: AppDimens.md),
                Container(
                  padding:
                      const EdgeInsets.all(AppDimens.md),
                  decoration: BoxDecoration(
                    color: AppColors.appBg,
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusInput),
                  ),
                  child: Row(children: [
                    _stat('${player.height.toStringAsFixed(2)} m', 'Taille'),
                    _stat(_footLabel(player.dominantFoot), 'Pied fort'),
                    _stat(positionShort(player.primaryPosition), 'Poste'),
                  ]),
                ),
                const SizedBox(height: AppDimens.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/player/${player.id}',
                        extra: player),
                    icon: const Icon(LucideIcons.arrowRight, size: 18),
                    label: const Text('Voir le profil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy900,
                      foregroundColor: Colors.white,
                      textStyle: AppTextStyles.button(),
                      padding: const EdgeInsets.symmetric(
                          vertical: AppDimens.md),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimens.radiusPill)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _footLabel(String foot) => switch (foot) {
        'Droite' => 'Droit',
        'Gauche' => 'Gauche',
        'Les deux' => 'Ambidextre',
        _ => foot,
      };

  Widget _stat(String value, String label) => Expanded(
        child: Column(children: [
          Text(value, style: AppTextStyles.h3()),
          Text(label, style: AppTextStyles.caption()),
        ]),
      );
}

class _BadgePill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  const _BadgePill({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
        ],
        Text(label,
            style: AppTextStyles.caption(color: color)
                .copyWith(fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Inline mocks — agents & clubs
// ─────────────────────────────────────────────────────────────
class _AgentMock {
  final String id, name, agency, country;
  final int years, players;
  final bool verified;
  const _AgentMock(this.id, this.name, this.agency, this.country,
      this.years, this.players, this.verified);
}

const _agents = [
  _AgentMock('a1', 'Nadia Mensah', 'Horizon Talent', 'Côte d’Ivoire',
      8, 12, true),
  _AgentMock('a2', 'Malik Diop', 'Terrain Avenir', 'Sénégal', 6, 12,
      true),
];

class _ClubMock {
  final String id, name, initials, location, kind;
  final bool verified;
  final List<String> recruiting;
  const _ClubMock(this.id, this.name, this.initials, this.location,
      this.kind, this.verified, this.recruiting);
}

const _clubs = [
  _ClubMock('c1', 'Académie des Rives', 'AR', 'Cameroun · Douala',
      'Académie U21', true, ['ATT', 'MIL']),
  _ClubMock('c2', 'FC Horizon Dakar', 'FH', 'Sénégal · Dakar',
      'Club professionnel', true, ['DEF', 'GAR']),
];

class _AgentCard extends StatelessWidget {
  final _AgentMock agent;
  const _AgentCard({required this.agent});

  @override
  Widget build(BuildContext context) {
    final initials = agent.name
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join();
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: AppColors.primaryTint,
            padding: const EdgeInsets.all(AppDimens.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(agent.agency,
                    style:
                        AppTextStyles.h3(color: AppColors.primary)),
                Text('Agence de représentation · Démonstration',
                    style:
                        AppTextStyles.caption(color: AppColors.primary)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: Column(
              children: [
                Row(children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primaryTint,
                    child: Text(initials,
                        style:
                            AppTextStyles.h3(color: AppColors.primary)),
                  ),
                  const SizedBox(width: AppDimens.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(agent.name, style: AppTextStyles.h3()),
                      Text(agent.country, style: AppTextStyles.body()),
                      if (agent.verified)
                        Container(
                          margin:
                              const EdgeInsets.only(top: AppDimens.xs),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTint,
                            borderRadius: BorderRadius.circular(
                                AppDimens.radiusPill),
                          ),
                          child: Text('Vérifié',
                              style: AppTextStyles.micro(
                                      color: AppColors.primary)
                                  .copyWith(
                                      fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ]),
                const SizedBox(height: AppDimens.lg),
                Row(children: [
                  _stat('${agent.years} ans', 'Expérience'),
                  _stat('${agent.players}', 'Joueurs'),
                ]),
                const SizedBox(height: AppDimens.lg),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context
                        .push('/agent-profile/${agent.id}'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      textStyle: AppTextStyles.button(
                          color: AppColors.textPrimary),
                      padding: const EdgeInsets.symmetric(
                          vertical: AppDimens.md),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimens.radiusPill)),
                    ),
                    child: const Text('Voir le profil'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String v, String l) => Expanded(
        child: Column(children: [
          Text(v, style: AppTextStyles.h3()),
          Text(l, style: AppTextStyles.caption()),
        ]),
      );
}

class _ClubCard extends StatelessWidget {
  final _ClubMock club;
  const _ClubCard({required this.club});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(children: [
            AspectRatio(
              aspectRatio: 16 / 7,
              child: Image.network(
                sporaImage(club.id, w: 640, h: 280),
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: AppColors.muted),
              ),
            ),
            if (club.verified)
              const Positioned(
                top: AppDimens.md,
                left: AppDimens.md,
                child: _BadgePill(
                    label: 'Vérifié',
                    color: AppColors.primary,
                    icon: LucideIcons.badgeCheck),
              ),
          ]),
          Padding(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(
                          AppDimens.radiusInput),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.shield,
                            size: 16, color: AppColors.clubGreen),
                        Text(club.initials,
                            style: AppTextStyles.micro(
                                    color: AppColors.clubGreen)
                                .copyWith(
                                    fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(club.name, style: AppTextStyles.h3()),
                        Text('${club.location} · ${club.kind}',
                            style: AppTextStyles.body()),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: AppDimens.md),
                Row(children: [
                  Text('Recrute', style: AppTextStyles.body()),
                  const SizedBox(width: AppDimens.sm),
                  ...club.recruiting.map((r) => Container(
                        margin: const EdgeInsets.only(
                            right: AppDimens.sm),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color:
                              AppColors.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                              AppDimens.radiusPill),
                        ),
                        child: Text(r,
                            style: AppTextStyles.caption(
                                    color: AppColors.clubGreen)
                                .copyWith(
                                    fontWeight: FontWeight.w600)),
                      )),
                ]),
                const SizedBox(height: AppDimens.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        context.push('/club/${club.id}'),
                    icon: const Icon(LucideIcons.arrowRight, size: 18),
                    label: const Text('Découvrir le club'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.clubGreen,
                      foregroundColor: Colors.white,
                      textStyle: AppTextStyles.button(),
                      padding: const EdgeInsets.symmetric(
                          vertical: AppDimens.md),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimens.radiusPill)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
