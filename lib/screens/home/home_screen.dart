import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:badges/badges.dart' as badges;
import '../../providers/player_provider.dart';
import '../../providers/messaging_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/spora_images.dart';
import '../../models/player_model.dart';
import '../../widgets/spora_logo.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// SPORA Home — /home
/// Role-aware: player → « 03 · Home & Discover — Accueil complet »,
/// agent → « Accueil agent », recruiter → « Accueil club ».
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlayerProvider>().loadHomeData();
      context.read<MessagingProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userType = context.read<AuthProvider>().selectedUserType;
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: Consumer<PlayerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.trendingPlayers.isEmpty) {
            return const _HomeLoading();
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<PlayerProvider>().loadHomeData(),
            child: CustomScrollView(
              slivers: [
                _buildTopBar(context),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.screenMargin),
                    child: switch (userType) {
                      UserType.agent =>
                        _AgentHome(players: provider.trendingPlayers),
                      UserType.recruiter =>
                        _ClubHome(players: provider.trendingPlayers),
                      _ => _PlayerHome(provider: provider),
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.appBg,
      floating: true,
      elevation: 0,
      titleSpacing: AppDimens.screenMargin,
      title: const SporaLogo(height: 24, flat: true),
      actions: [
        Consumer<MessagingProvider>(
          builder: (context, msg, _) => _TopBarButton(
            icon: LucideIcons.bell,
            badgeCount: msg.unreadNotifications,
            onTap: () => context.push('/notifications'),
          ),
        ),
        const SizedBox(width: AppDimens.sm),
        _TopBarButton(
          icon: LucideIcons.messageCircle,
          onTap: () => context.go('/messages'),
        ),
        const SizedBox(width: AppDimens.screenMargin),
      ],
    );
  }
}

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;
  const _TopBarButton(
      {required this.icon, required this.onTap, this.badgeCount = 0});

  @override
  Widget build(BuildContext context) {
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
        child: badges.Badge(
          showBadge: badgeCount > 0,
          badgeContent: Text('$badgeCount',
              style: const TextStyle(color: Colors.white, fontSize: 9)),
          badgeStyle:
              const badges.BadgeStyle(badgeColor: AppColors.danger),
          child: Icon(icon, size: 26, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

/// Network image that always looks intentional: muted block while loading,
/// dark navy placeholder on error.
Widget _netImage(
  String url, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  IconData errorIcon = LucideIcons.imageOff,
}) {
  return Image.network(
    url,
    width: width,
    height: height,
    fit: fit,
    loadingBuilder: (context, child, progress) => progress == null
        ? child
        : Container(
            width: width, height: height, color: AppColors.muted),
    errorBuilder: (context, error, stack) => Container(
      width: width,
      height: height,
      color: AppColors.navy800,
      alignment: Alignment.center,
      child: Icon(errorIcon, color: AppColors.darkTextMuted, size: 28),
    ),
  );
}

/// 'Attaquant (ST)' → 'Attaquant' — label form used in player metas.
String positionName(String position) {
  final i = position.indexOf('(');
  return (i == -1 ? position : position.substring(0, i)).trim();
}

// ─────────────────────────────────────────────────────────────
// PLAYER HOME — « 03 · Home & Discover — Accueil complet »
// ─────────────────────────────────────────────────────────────
class _PlayerHome extends StatelessWidget {
  final PlayerProvider provider;
  const _PlayerHome({required this.provider});

  static const _spotlights = [
    (name: 'Jordan Mbala', meta: 'Attaquant · 19 ans', seed: 'jordan-mbala'),
    (name: 'Kevin Njoya', meta: 'Milieu · 21 ans', seed: 'kevin-njoya'),
  ];

  @override
  Widget build(BuildContext context) {
    final players = provider.trendingPlayers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppDimens.sm),

        // ── Hero ──────────────────────────────────────────────
        const _HeroCard(),
        const SizedBox(height: AppDimens.section),

        // ── Stats ─────────────────────────────────────────────
        const Row(
          children: [
            _Stat(value: '10K+', label: 'Joueurs'),
            _Stat(value: '24', label: 'Agents'),
            _Stat(value: '6', label: 'Clubs'),
            _Stat(value: '18', label: 'Opportunités'),
          ],
        ),
        const SizedBox(height: AppDimens.sm),
        Center(
          child: Text('Chiffres de démonstration',
              style: AppTextStyles.micro()),
        ),
        const SizedBox(height: AppDimens.section),

        // ── À la une ──────────────────────────────────────────
        Text('À LA UNE', style: AppTextStyles.eyebrow()),
        const SizedBox(height: AppDimens.xs),
        Text('Highlight du moment', style: AppTextStyles.h1()),
        const SizedBox(height: AppDimens.md),
        const _VideoCard(
          seed: 'home-highlight-but',
          tag: 'BUT',
          duration: '00:42',
          title:
              'Frappe exceptionnelle depuis l’extérieur de la surface',
          author: 'Jordan M. · Attaquant · France',
          meta: '18,4 K vues · il y a 2 jours',
        ),
        const SizedBox(height: AppDimens.lg),
        const _MiniVideoTile(
          seed: 'home-mini-skills',
          title: 'Skills et éliminations',
          author: 'Kevin Njoya',
          duration: '00:15',
          views: '5,2 K vues',
        ),
        const _MiniVideoTile(
          seed: 'home-mini-passe',
          title: 'Passe décisive',
          author: 'Samuel Kouassi',
          duration: '00:28',
          views: '3,8 K vues',
        ),
        const _MiniVideoTile(
          seed: 'home-mini-arrets',
          title: 'Meilleurs arrêts',
          author: 'David Tchoupo',
          duration: '00:45',
          views: '4,1 K vues',
        ),
        const SizedBox(height: AppDimens.sm),

        // ── Talents disponibles ───────────────────────────────
        Text('TALENTS DISPONIBLES', style: AppTextStyles.eyebrow()),
        const SizedBox(height: AppDimens.xs),
        Text('Joueurs à découvrir', style: AppTextStyles.h1()),
        const SizedBox(height: AppDimens.md),
        SizedBox(
          height: 214,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _spotlights.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppDimens.md),
            itemBuilder: (context, i) {
              final t = _spotlights[i];
              return _TalentSpotlightCard(
                name: t.name,
                meta: t.meta,
                seed: t.seed,
                player: i < players.length ? players[i] : null,
              );
            },
          ),
        ),
        const SizedBox(height: AppDimens.section),

        // ── Opportunité du moment ─────────────────────────────
        Text('Opportunité du moment', style: AppTextStyles.h1()),
        const SizedBox(height: AppDimens.md),
        GestureDetector(
          onTap: () => context.push('/opportunity/opp1'),
          child: const OpportunityTeaserCard(),
        ),
        const SizedBox(height: AppDimens.section),

        // ── Performances récentes ─────────────────────────────
        Text('Les performances récentes', style: AppTextStyles.h1()),
        const SizedBox(height: AppDimens.md),
        const Row(
          children: [
            _FilterChip(label: 'BUT', selected: true),
            SizedBox(width: AppDimens.sm),
            _FilterChip(label: 'SKILLS'),
            SizedBox(width: AppDimens.sm),
            _FilterChip(label: 'PASSES'),
          ],
        ),
        const SizedBox(height: AppDimens.md),
        const _VideoCard(
          seed: 'home-actions-semaine',
          tag: 'BUT',
          duration: '00:42',
          title: 'Les meilleures actions de la semaine',
          author: 'Jordan M. · Attaquant · France',
          meta: '18,4 K vues · il y a 2 jours',
        ),
        const SizedBox(height: AppDimens.section),

        // ── Premium ───────────────────────────────────────────
        const _PremiumCard(),
        const SizedBox(height: AppDimens.xxxl),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.h1()),
          Text(label,
              style: AppTextStyles.caption(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Hero — photo card, gradient overlay, CTAs + social proof
// ─────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  const _HeroCard();

  static const _faces = [
    (name: 'Jordan M.', meta: 'Attaquant · 19 ans', avatar: 'jordan_m'),
    (name: 'Kevin N.', meta: 'Milieu · 21 ans', avatar: 'kevin_n'),
    (name: 'Samuel K.', meta: 'Défenseur · 20 ans', avatar: 'samuel_k'),
  ];

  @override
  Widget build(BuildContext context) {
    final hasProfile =
        context.read<AuthProvider>().currentPlayerProfile != null;
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.navy900,
        borderRadius: BorderRadius.circular(AppDimens.radiusHero),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: _netImage(
              sporaImage('home-hero', w: 900, h: 1100),
              errorIcon: LucideIcons.goal,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.navy900.withValues(alpha: 0.20),
                    AppColors.navy900.withValues(alpha: 0.72),
                    AppColors.navy900.withValues(alpha: 0.96),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.md, vertical: AppDimens.xs),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusPill),
                  ),
                  child: Text(
                    'LA PLATEFORME DES TALENTS DU FOOTBALL',
                    style: AppTextStyles.micro(color: AppColors.textLight)
                        .copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1),
                  ),
                ),
                const SizedBox(height: AppDimens.xl),
                Text('Le prochain talent est\npeut-être ici.',
                    style:
                        AppTextStyles.display(color: AppColors.textLight)),
                const SizedBox(height: AppDimens.sm),
                Text(
                  'Découvrez les joueurs qui font la différence, '
                  'présentez votre talent et connectez-vous avec les '
                  'agents et clubs à la recherche de nouveaux profils.',
                  style: AppTextStyles.body(
                      color: AppColors.darkTextSecondary),
                ),
                const SizedBox(height: AppDimens.xl),
                _HeroButton(
                  label: 'Explorer les talents',
                  gradient: AppColors.primaryGradient,
                  textColor: Colors.white,
                  shadow: AppShadows.glowBrand,
                  onTap: () => context.go('/discover'),
                ),
                const SizedBox(height: AppDimens.md),
                _HeroButton(
                  label: 'Créer mon profil',
                  color: AppColors.surface,
                  textColor: AppColors.textPrimary,
                  onTap: () => hasProfile
                      ? context.push('/edit-profile')
                      : context.push('/onboarding'),
                ),
                const SizedBox(height: AppDimens.xl),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimens.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusInput),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Déjà 10 000+ talents sur SPORA',
                          style: AppTextStyles.bodyStrong(
                              color: AppColors.primary)),
                      const SizedBox(height: AppDimens.sm),
                      for (final f in _faces)
                        _TalentFaceRow(
                            name: f.name, meta: f.meta, avatar: f.avatar),
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
}

class _HeroButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final List<Color>? gradient;
  final Color? color;
  final Color textColor;
  final List<BoxShadow>? shadow;

  const _HeroButton({
    required this.label,
    required this.onTap,
    required this.textColor,
    this.gradient,
    this.color,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppDimens.md),
        decoration: BoxDecoration(
          color: color,
          gradient: gradient == null
              ? null
              : LinearGradient(colors: gradient!),
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          boxShadow: shadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: AppTextStyles.button(color: textColor)),
            const SizedBox(width: AppDimens.sm),
            Icon(LucideIcons.arrowRight,
                size: 18, color: textColor),
          ],
        ),
      ),
    );
  }
}

class _TalentFaceRow extends StatelessWidget {
  final String name;
  final String meta;
  final String avatar;
  const _TalentFaceRow(
      {required this.name, required this.meta, required this.avatar});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppDimens.xs),
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.sm, vertical: AppDimens.xs),
      decoration: BoxDecoration(
        color: AppColors.appBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      ),
      child: Row(
        children: [
          ClipOval(
            child: _netImage(
              'https://i.pravatar.cc/64?u=$avatar',
              width: 28,
              height: 28,
              errorIcon: LucideIcons.user,
            ),
          ),
          const SizedBox(width: AppDimens.sm),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                      text: name,
                      style: AppTextStyles.caption(
                              color: AppColors.textPrimary)
                          .copyWith(fontWeight: FontWeight.w600)),
                  TextSpan(
                      text: ' · $meta',
                      style: AppTextStyles.caption()),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Video card — photo, tag + duration chips, play circle, meta
// ─────────────────────────────────────────────────────────────
class _VideoCard extends StatelessWidget {
  final String seed;
  final String tag;
  final String duration;
  final String title;
  final String author;
  final String meta;

  const _VideoCard({
    required this.seed,
    required this.tag,
    required this.duration,
    required this.title,
    required this.author,
    required this.meta,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/video-player', extra: title),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _netImage(
                    sporaImage(seed, w: 800, h: 450),
                    errorIcon: LucideIcons.film,
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.10),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.25),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                      color: AppColors.surface, shape: BoxShape.circle),
                  child: const Icon(LucideIcons.play,
                      size: 32, color: AppColors.primary),
                ),
                Positioned(
                  top: AppDimens.md,
                  left: AppDimens.md,
                  child: Row(
                    children: [
                      _TagPill(label: tag, color: AppColors.primary),
                      const SizedBox(width: AppDimens.xs),
                      _TagPill(
                          label: duration, color: AppColors.navy800),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.h3()),
                  const SizedBox(height: AppDimens.xs),
                  Text(author, style: AppTextStyles.caption()),
                  Text(meta, style: AppTextStyles.caption()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  final Color color;
  const _TagPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Text(label,
          style: AppTextStyles.micro(color: AppColors.textLight)
              .copyWith(fontWeight: FontWeight.w700)),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Compact video row — 56px thumb, title, author · durée, vues
// ─────────────────────────────────────────────────────────────
class _MiniVideoTile extends StatelessWidget {
  final String seed;
  final String title;
  final String author;
  final String duration;
  final String views;

  const _MiniVideoTile({
    required this.seed,
    required this.title,
    required this.author,
    required this.duration,
    required this.views,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/video-player', extra: title),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppDimens.md),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(AppDimens.radiusInput),
              child: _netImage(
                sporaImage(seed, w: 160, h: 160),
                width: 56,
                height: 56,
                errorIcon: LucideIcons.film,
              ),
            ),
            const SizedBox(width: AppDimens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.bodyStrong(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  Text('$author · $duration',
                      style: AppTextStyles.caption()),
                  Text(views, style: AppTextStyles.caption()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Talent spotlight — large photo card (horizontal scroll)
// ─────────────────────────────────────────────────────────────
class _TalentSpotlightCard extends StatelessWidget {
  final String name;
  final String meta;
  final String seed;
  final PlayerModel? player;

  const _TalentSpotlightCard({
    required this.name,
    required this.meta,
    required this.seed,
    this.player,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.push('/player/${player?.id ?? 'jordan_mbala'}',
              extra: player),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.56,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _netImage(
                    sporaImage(seed, w: 520, h: 420),
                    errorIcon: LucideIcons.user,
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.22),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimens.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: AppTextStyles.h3(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(meta,
                      style: AppTextStyles.caption(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Filter chip — static (demo) chips for « Les performances récentes »
// ─────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _FilterChip({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.lg, vertical: AppDimens.sm),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: Border.all(
            color: selected ? AppColors.primary : AppColors.border),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(
                color: selected
                    ? AppColors.textLight
                    : AppColors.textSecondary)
            .copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Premium — navy card with gold CTA
// ─────────────────────────────────────────────────────────────
class _PremiumCard extends StatelessWidget {
  const _PremiumCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.xl),
      decoration: BoxDecoration(
        color: AppColors.navy900,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.crown,
              color: AppColors.gold, size: 30),
          const SizedBox(height: AppDimens.md),
          Text('Donnez de l’élan à votre talent',
              style: AppTextStyles.h2(color: AppColors.textLight)),
          const SizedBox(height: AppDimens.xs),
          Text('Highlights illimités avec SPORA Premium.',
              style:
                  AppTextStyles.body(color: AppColors.darkTextSecondary)),
          const SizedBox(height: AppDimens.lg),
          GestureDetector(
            onTap: () => context.push('/premium'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  vertical: AppDimens.md),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius:
                    BorderRadius.circular(AppDimens.radiusPill),
              ),
              alignment: Alignment.center,
              child: Text('Découvrir Premium',
                  style:
                      AppTextStyles.button(color: AppColors.navy900)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Opportunity teaser — shared with club home
// ─────────────────────────────────────────────────────────────
class OpportunityTeaserCard extends StatelessWidget {
  const OpportunityTeaserCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 7,
            child: _netImage(
              sporaImage('opp-det-u21', w: 900, h: 420),
              errorIcon: LucideIcons.users,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusPill),
                  ),
                  child: Text('Ouverte',
                      style:
                          AppTextStyles.caption(color: AppColors.clubGreen)
                              .copyWith(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: AppDimens.sm),
                Text('Détection U21 · Douala', style: AppTextStyles.h3()),
                const SizedBox(height: AppDimens.sm),
                const _OppLine('Académie des Rives'),
                const _OppLine('Douala, Cameroun'),
                const _OppLine('14–15 novembre 2026'),
                const _OppLine('18–21 ans · ATT · MIL · 24 places'),
                const _OppLine('Clôture le 8 novembre 2026'),
                const SizedBox(height: AppDimens.xs),
                Text('Offre d’exemple · Académie fictive · Sans frais',
                    style: AppTextStyles.micro()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OppLine extends StatelessWidget {
  final String text;
  const _OppLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.xxs),
      child: Text(text, style: AppTextStyles.body()),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// AGENT HOME — « Accueil agent »
// ─────────────────────────────────────────────────────────────
class _AgentHome extends StatelessWidget {
  final List<PlayerModel> players;
  const _AgentHome({required this.players});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppDimens.lg),
        Text(
            'Bonjour ${(context.read<AuthProvider>().currentUser?.name ?? 'Nadia').split(' ').first}',
            style: AppTextStyles.display()),
        const SizedBox(height: AppDimens.xs),
        Text('Votre prochain talent vous attend.',
            style:
                AppTextStyles.bodyLarge(color: AppColors.textSecondary)),
        const SizedBox(height: AppDimens.section),
        Text('Vos recherches enregistrées', style: AppTextStyles.h2()),
        const SizedBox(height: AppDimens.md),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.circular(AppDimens.radiusCard),
            border: Border.all(color: AppColors.border),
          ),
          child: const Column(
            children: [
              _SavedSearchTile(
                title: 'Attaquants U21 disponibles',
                subtitle:
                    'France · Cameroun · 12 nouveaux profils',
              ),
              Divider(height: 1, color: AppColors.divider, indent: 62),
              _SavedSearchTile(
                title: 'Milieux · Senior',
                subtitle: 'Côte d’Ivoire · 4 nouveaux profils',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.section),
        Text('Nouveaux talents pour vous', style: AppTextStyles.h2()),
        const SizedBox(height: AppDimens.md),
        ...players.take(2).map((p) => PlayerListTile(player: p)),
        const SizedBox(height: AppDimens.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.go('/discover'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border),
              backgroundColor: AppColors.surface,
              textStyle:
                  AppTextStyles.button(color: AppColors.textPrimary),
              padding: const EdgeInsets.symmetric(
                  vertical: AppDimens.md),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusPill)),
            ),
            child: const Text('Voir tous les talents'),
          ),
        ),
        const SizedBox(height: AppDimens.xxxl),
      ],
    );
  }
}

class _SavedSearchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SavedSearchTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/search'),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.lg, vertical: AppDimens.lg),
        child: Row(
          children: [
            const Icon(LucideIcons.search,
                size: 22, color: AppColors.primary),
            const SizedBox(width: AppDimens.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyStrong()),
                  Text(subtitle, style: AppTextStyles.caption()),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight,
                size: 20, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CLUB (recruiter) HOME — « Accueil club »
// ─────────────────────────────────────────────────────────────
class _ClubHome extends StatelessWidget {
  final List<PlayerModel> players;
  const _ClubHome({required this.players});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppDimens.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimens.lg),
          decoration: BoxDecoration(
            color: AppColors.green.withValues(alpha: 0.12),
            borderRadius:
                BorderRadius.circular(AppDimens.radiusCard),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Académie des Rives',
                  style: AppTextStyles.h3(color: AppColors.clubGreen)),
              Text('Club fictif · Votre espace recrutement',
                  style:
                      AppTextStyles.caption(color: AppColors.clubGreen)),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.section),
        Text('Vos opportunités actives',
            style: AppTextStyles.display()),
        const SizedBox(height: AppDimens.md),
        GestureDetector(
          onTap: () => context.push('/opportunity/mine1'),
          child: const OpportunityTeaserCard(),
        ),
        const SizedBox(height: AppDimens.lg),
        const Row(
          children: [
            _ClubStat(value: '24', label: 'Candidats'),
            _ClubStat(value: '8', label: 'À examiner'),
            _ClubStat(value: '3', label: 'Présélections'),
          ],
        ),
        const SizedBox(height: AppDimens.lg),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.push('/opportunities/publish'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.clubGreen,
              foregroundColor: Colors.white,
              textStyle: AppTextStyles.button(),
              padding: const EdgeInsets.symmetric(
                  vertical: AppDimens.md),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusPill)),
            ),
            child: const Text('Publier une opportunité'),
          ),
        ),
        const SizedBox(height: AppDimens.section),
        Text('Talents pour votre équipe', style: AppTextStyles.h2()),
        const SizedBox(height: AppDimens.md),
        ...players.take(2).map((p) => PlayerListTile(player: p)),
        const SizedBox(height: AppDimens.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.go('/discover'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border),
              backgroundColor: AppColors.surface,
              textStyle:
                  AppTextStyles.button(color: AppColors.textPrimary),
              padding: const EdgeInsets.symmetric(
                  vertical: AppDimens.md),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusPill)),
            ),
            child: const Text('Explorer les talents'),
          ),
        ),
        const SizedBox(height: AppDimens.xxxl),
      ],
    );
  }
}

class _ClubStat extends StatelessWidget {
  final String value;
  final String label;
  const _ClubStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.display()),
          Text(label, style: AppTextStyles.bodyStrong()),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Compact player list tile — shared by agent/club homes & discover
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
          borderRadius:
              BorderRadius.circular(AppDimens.radiusCard),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(AppDimens.radiusInput),
              child: _netImage(
                player.avatarUrl ??
                    sporaImage(player.id, w: 128, h: 128),
                width: 64,
                height: 64,
                errorIcon: LucideIcons.user,
              ),
            ),
            const SizedBox(width: AppDimens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(player.fullName,
                      style: AppTextStyles.h3(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AppDimens.xxs),
                  Text(
                    '${positionName(player.primaryPosition)} · ${player.age} ans · ${player.nationality}',
                    style: AppTextStyles.body(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('${player.city} · ${player.leagueDivision}',
                      style: AppTextStyles.caption(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (player.isVerified)
              const Icon(LucideIcons.badgeCheck,
                  size: 20, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Loading — « Chargement de votre accueil… »
// ─────────────────────────────────────────────────────────────
class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.appBg,
          floating: true,
          elevation: 0,
          titleSpacing: AppDimens.screenMargin,
          title: const SporaLogo(height: 24, flat: true),
          actions: const [
            _TopBarButton(
                icon: LucideIcons.bell, onTap: _noop),
            SizedBox(width: AppDimens.sm),
            _TopBarButton(
                icon: LucideIcons.messageCircle, onTap: _noop),
            SizedBox(width: AppDimens.screenMargin),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.screenMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimens.lg),
                Text('Chargement de votre accueil…',
                    style: AppTextStyles.body()),
                const SizedBox(height: AppDimens.lg),
                const _SkeletonCard(
                    imageHeight: 190, withButton: true),
                const SizedBox(height: AppDimens.section),
                Text('Highlight du moment',
                    style: AppTextStyles.h1()),
                const SizedBox(height: AppDimens.md),
                const _SkeletonCard(imageHeight: 160),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

void _noop() {}

class _SkeletonCard extends StatelessWidget {
  final double imageHeight;
  final bool withButton;
  const _SkeletonCard({required this.imageHeight, this.withButton = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: AppColors.shimmerBase,
            highlightColor: AppColors.shimmerHighlight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _block(imageHeight, AppDimens.radiusInput),
                const SizedBox(height: AppDimens.lg),
                _bar(),
                const SizedBox(height: AppDimens.sm),
                _bar(widthFactor: 0.55),
              ],
            ),
          ),
          if (withButton) ...[
            const SizedBox(height: AppDimens.lg),
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius:
                    BorderRadius.circular(AppDimens.radiusInput),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _block(double height, double radius) => Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  static Widget _bar({double widthFactor = 1}) =>
      FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.shimmerBase,
            borderRadius:
                BorderRadius.circular(AppDimens.radiusPill),
          ),
        ),
      );
}

// Kept for discover_screen.dart imports.
String positionShort(String position) {
  final match = RegExp(r'\(([^)]+)\)').firstMatch(position);
  if (match != null) return match.group(1)!;
  return position.split(' ').first;
}
