import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../account/account_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// "/profile" tab — frames "16 · Compte — Mon profil" (player),
/// "M03 · Mon compte agent" and "M04 · Mon compte club".
class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _CompletionItem {
  final String label;
  final bool done;
  final String route;
  const _CompletionItem(this.label, this.done, this.route);
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  bool _available = true;

  UserType _role(AuthProvider auth) =>
      auth.selectedUserType == UserType.guest ? UserType.player : auth.selectedUserType;

  // Frame 16 shows a "70 %" ring: 7 items done out of 10, with the last
  // completed item (Football) then the first two missing ones displayed.
  List<_CompletionItem> _completion() {
    return const [
      _CompletionItem('Identité', true, '/edit-profile'),
      _CompletionItem('Photo', true, '/edit-profile'),
      _CompletionItem('Poste', true, '/edit-profile'),
      _CompletionItem('Club', true, '/edit-profile'),
      _CompletionItem('Bio', true, '/edit-profile'),
      _CompletionItem('Réseaux', true, '/edit-profile'),
      _CompletionItem('Football', true, '/edit-profile'),
      _CompletionItem('Parcours', false, '/edit-profile'),
      _CompletionItem('Vidéo', false, '/highlights/publish'),
      _CompletionItem('Highlights', false, '/highlights/mine'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final p = AccountPalette.of(context);
    final role = _role(auth);
    final isPlayer = role == UserType.player;
    final isPremium = auth.currentUser?.isPremium ?? false;
    final canPop = context.canPop();

    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppDimens.screenMargin, 0, AppDimens.screenMargin, AppDimens.section),
          children: [
            _TopBar(
              showBack: canPop || !isPlayer,
              isPlayer: isPlayer,
              onMore: () => _showMoreSheet(context),
            ),
            if (isPlayer)
              _PlayerHeader(
                name: _displayName(auth, role),
                isPremium: isPremium,
                avatarUrl: auth.currentUser?.avatarUrl,
              )
            else
              _ProHeroCard(role: role, name: _displayName(auth, role), isPremium: isPremium),
            const SizedBox(height: AppDimens.lg),
            SecondaryButton(
              label: 'Modifier le profil',
              icon: isPlayer ? LucideIcons.pencil : null,
              onPressed: () => context.push('/edit-profile'),
            ),
            if (isPlayer) ...[
              const SizedBox(height: AppDimens.lg),
              _CompletionCard(items: _completion()),
              const SizedBox(height: AppDimens.md),
              AccountCard(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg, vertical: 4),
                child: SwitchRow(
                  title: 'Disponible pour une opportunité',
                  subtitle: _available
                      ? 'Les recruteurs voient que vous êtes ouvert'
                      : 'Votre disponibilité est masquée',
                  value: _available,
                  onChanged: (v) => setState(() => _available = v),
                ),
              ),
            ],
            _ActivitySection(role: role),
            _MenuCard(
              role: role,
              isPremium: isPremium,
              onSignOut: () => _confirmSignOut(context),
            ),
            if (!isPlayer) ...[
              const SizedBox(height: AppDimens.lg),
              InfoBanner(
                icon: LucideIcons.info,
                title: 'Rôle d’inscription conservé',
                body:
                    'Votre compte est un compte ${role == UserType.agent ? 'Agent' : 'Club'}.',
              ),
            ],
            const SizedBox(height: AppDimens.lg),
            AccountCard(
              padding: const EdgeInsets.symmetric(vertical: AppDimens.xs),
              child: IconRow(
                icon: LucideIcons.trash2,
                title: 'Supprimer mon compte',
                iconColor: AppColors.errorText,
                titleColor: AppColors.errorText,
                chevron: true,
                onTap: () => context.push('/delete-account'),
              ),
            ),
            const SizedBox(height: AppDimens.bottomNav),
          ],
        ),
      ),
    );
  }

  String _displayName(AuthProvider auth, UserType role) {
    final n = auth.currentUser?.name;
    if (n != null && n.isNotEmpty) return n.split(' - ').first;
    switch (role) {
      case UserType.agent:
        return 'Nadia Mensah';
      case UserType.recruiter:
        return 'Académie des Rives';
      default:
        return 'Jordan Mbala';
    }
  }

  void _showMoreSheet(BuildContext context) {
    final p = AccountPalette.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: p.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusSheet))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconRow(
                icon: LucideIcons.share2,
                title: 'Partager mon profil',
                onTap: () {
                  Navigator.pop(ctx);
                  showAccountSnack(context, 'Lien du profil copié');
                },
              ),
              IconRow(
                icon: LucideIcons.settings,
                title: 'Paramètres',
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/settings');
                },
              ),
              IconRow(
                icon: LucideIcons.flag,
                title: 'Signaler un problème',
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/report');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final allDevices = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AccountPalette.of(context).surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusSheet))),
      builder: (ctx) => const _SignOutSheet(),
    );
    if (allDevices == null || !context.mounted) return;
    final auth = context.read<AuthProvider>();
    await auth.logout();
    if (!context.mounted) return;
    context.go('/login');
  }
}

class _SignOutSheet extends StatefulWidget {
  const _SignOutSheet();

  @override
  State<_SignOutSheet> createState() => _SignOutSheetState();
}

class _SignOutSheetState extends State<_SignOutSheet> {
  bool _all = false;

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppDimens.xl, AppDimens.md, AppDimens.xl, AppDimens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: p.border, borderRadius: BorderRadius.circular(AppDimens.radiusPill)),
              ),
            ),
            const SizedBox(height: AppDimens.xl),
            Text('Se déconnecter ?', style: AppTextStyles.h1(color: p.text)),
            const SizedBox(height: AppDimens.sm),
            Text('Vous pourrez vous reconnecter à tout moment avec votre e-mail.',
                style: AppTextStyles.body(color: p.text2)),
            const SizedBox(height: AppDimens.lg),
            AccountCard(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg, vertical: 4),
              child: SwitchRow(
                title: 'Déconnecter tous les appareils',
                subtitle: 'Ferme aussi les sessions ouvertes ailleurs',
                value: _all,
                onChanged: (v) => setState(() => _all = v),
              ),
            ),
            const SizedBox(height: AppDimens.xl),
            DangerButton(
              label: _all ? 'Se déconnecter partout' : 'Se déconnecter',
              onPressed: () => Navigator.pop(context, _all),
            ),
            const SizedBox(height: AppDimens.md),
            SecondaryButton(label: 'Annuler', onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool showBack;
  final bool isPlayer;
  final VoidCallback onMore;
  const _TopBar({required this.showBack, required this.isPlayer, required this.onMore});

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    return SizedBox(
      height: 72,
      child: Row(
        children: [
          if (showBack) ...[
            _TopBarTile(
              icon: LucideIcons.arrowLeft,
              tooltip: 'Retour',
              onTap: () => accountBack(context, fallback: '/home'),
            ),
            const SizedBox(width: AppDimens.sm),
          ],
          Expanded(
            child: Text('Mon profil',
                style: showBack ? AppTextStyles.h1(color: p.text) : AppTextStyles.display(color: p.text)),
          ),
          if (isPlayer)
            _TopBarTile(
              icon: LucideIcons.bell,
              tooltip: 'Notifications',
              onTap: () => context.push('/notifications'),
            )
          else
            _TopBarTile(
              icon: LucideIcons.moreHorizontal,
              tooltip: 'Plus',
              onTap: onMore,
            ),
        ],
      ),
    );
  }
}

/// Bordered icon tile used by [_TopBar] (Figma header pattern, 44 px).
class _TopBarTile extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _TopBarTile({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusInput),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusInput),
          onTap: onTap,
          child: Container(
            width: AppDimens.minTouch,
            height: AppDimens.minTouch,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.radiusInput),
              border: Border.all(color: p.border),
            ),
            child: Icon(icon, size: 22, color: p.text, semanticLabel: tooltip),
          ),
        ),
      ),
    );
  }
}

class _PlayerHeader extends StatelessWidget {
  final String name;
  final bool isPremium;
  final String? avatarUrl;
  const _PlayerHeader({required this.name, required this.isPremium, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: p.muted,
          backgroundImage: NetworkImage(avatarUrl ?? 'https://i.pravatar.cc/200?u=jordan'),
        ),
        const SizedBox(width: AppDimens.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.h1(color: p.text)),
                  ),
                  const SizedBox(width: 6),
                  const Icon(LucideIcons.badgeCheck, color: AppColors.primary, size: 20, semanticLabel: 'Vérifié'),
                ],
              ),
              const SizedBox(height: 2),
              Text('Attaquant · Paris FC U21', style: AppTextStyles.body(color: p.text2)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  const StatusPill(label: 'Vérifié', color: AppColors.primary),
                  if (isPremium) const _PremiumPill(),
                ],
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => context.push('/player/me'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('Voir mon profil public →',
                      style: AppTextStyles.body(color: AppColors.primary)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PremiumPill extends StatelessWidget {
  const _PremiumPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.goldGradient),
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.crown, size: 14, color: AppColors.textLight),
          const SizedBox(width: 4),
          Text('Premium',
              style: AppTextStyles.caption(color: AppColors.textLight).copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ProHeroCard extends StatelessWidget {
  final UserType role;
  final String name;
  final bool isPremium;
  const _ProHeroCard({required this.role, required this.name, required this.isPremium});

  @override
  Widget build(BuildContext context) {
    final isAgent = role == UserType.agent;
    final bg = isAgent ? AppColors.navy800 : AppColors.clubGreen;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.section),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppDimens.radiusHero)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                ),
                child: Icon(
                  isAgent ? LucideIcons.briefcase : LucideIcons.shield,
                  color: isAgent ? AppColors.primary : AppColors.clubGreen,
                  size: 32,
                ),
              ),
              const Spacer(),
              Wrap(
                spacing: 6,
                children: [
                  if (isPremium) const _PremiumPill(),
                  const StatusPill(
                      label: 'Vérifié ✓', color: AppColors.primary, background: AppColors.primaryTint),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimens.xl),
          Text(name, style: AppTextStyles.h1(color: AppColors.textLight).copyWith(fontSize: 26, height: 32 / 26)),
          const SizedBox(height: AppDimens.lg),
          Text(isAgent ? 'Horizon Talent · Côte d’Ivoire' : 'Douala · Cameroun · U21',
              style: AppTextStyles.body(color: AppColors.textLight.withValues(alpha: 0.9))),
          const SizedBox(height: AppDimens.md),
          Text(isAgent ? '8 ans d’expérience · Agent indépendant' : 'Éric N. · Responsable recrutement',
              style: AppTextStyles.caption(color: AppColors.textLight.withValues(alpha: 0.85))),
        ],
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  final List<_CompletionItem> items;
  const _CompletionCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    final done = items.where((e) => e.done).length;
    final pct = ((done / items.length) * 100).round();
    final missing = items.where((e) => !e.done).toList();
    // Show the last completed item + the first two missing items, like the
    // design ("✓ Football", "+ Parcours", "+ Vidéo").
    final shown = <_CompletionItem>[
      ...items.where((e) => e.done).toList().reversed.take(1),
      ...missing.take(2),
    ];
    return AccountCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Semantics(
                label: 'Profil complété à $pct pour cent',
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: CustomPaint(
                    painter: _RingPainter(pct / 100, p.border),
                    child: Center(
                      child: Text('$pct %', style: AppTextStyles.bodyStrong(color: p.text)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pct >= 100 ? 'Profil complet' : 'Votre profil prend forme',
                        style: AppTextStyles.h3(color: p.text)),
                    const SizedBox(height: 2),
                    Text(
                        missing.isEmpty
                            ? 'Bravo, votre profil est prêt à être découvert.'
                            : 'Complétez-le pour être mieux découvert.',
                        style: AppTextStyles.caption(color: p.text2)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Wrap(
            spacing: AppDimens.sm,
            runSpacing: AppDimens.sm,
            children: shown
                .map((e) => InkWell(
                      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                      onTap: e.done ? null : () => context.push(e.route),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: e.done ? p.successTint : p.tint,
                          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                        ),
                        child: Text(e.done ? '✓ ${e.label}' : '+ ${e.label}',
                            style: AppTextStyles.caption(
                                    color: e.done ? AppColors.clubGreen : AppColors.primary)
                                .copyWith(fontWeight: FontWeight.w600)),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color track;
  _RingPainter(this.value, this.track);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 5.0;
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    final bg = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final fg = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..strokeWidth = stroke;
    canvas.drawArc(r, 0, math.pi * 2, false, bg);
    canvas.drawArc(r, -math.pi / 2, math.pi * 2 * value, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.value != value || old.track != track;
}

class _ActivitySection extends StatelessWidget {
  final UserType role;
  const _ActivitySection({required this.role});

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    final isPlayer = role == UserType.player;
    final List<(String, String, String?)> stats;
    switch (role) {
      case UserType.agent:
        stats = const [('12', 'Joueurs suivis', '/my-list'), ('8', 'Messages', '/messages'), ('24', 'Dans ma liste', '/my-list')];
        break;
      case UserType.recruiter:
        stats = const [('3', 'Offres actives', '/opportunities/mine'), ('8', 'Messages', '/messages'), ('24', 'Dans ma liste', '/my-list')];
        break;
      default:
        stats = const [('1 284', 'Vues du profil', '/profile-views'), ('12', 'Highlights', '/highlights/mine'), ('2', 'Candidatures', '/applications')];
    }
    final statRow = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: stats
          .map((s) => Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppDimens.radiusInput),
                  onTap: s.$3 == null
                      ? null
                      : () => s.$3 == '/messages' ? context.go(s.$3!) : context.push(s.$3!),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppDimens.sm),
                    child: Column(
                      crossAxisAlignment: isPlayer
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        Text(s.$1, style: AppTextStyles.statNumber(color: p.text)),
                        const SizedBox(height: 4),
                        Text(s.$2,
                            textAlign: isPlayer ? TextAlign.center : TextAlign.start,
                            style: AppTextStyles.caption(color: p.text3)),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
    // Agent / club frames (M03 / M04) wrap the stats inside a white card;
    // the player frame (16) shows them directly on the background.
    if (!isPlayer) {
      return Padding(
        padding: const EdgeInsets.only(top: AppDimens.lg, bottom: AppDimens.lg),
        child: AccountCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Votre activité', style: AppTextStyles.bodyStrong(color: p.text)),
              const SizedBox(height: AppDimens.sm),
              statRow,
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppDimens.section, bottom: AppDimens.md),
          child: Row(
            children: [
              Expanded(child: Text('Votre activité', style: AppTextStyles.bodyStrong(color: p.text))),
              Text('30 derniers jours', style: AppTextStyles.caption(color: p.text3)),
            ],
          ),
        ),
        statRow,
        const SizedBox(height: AppDimens.lg),
      ],
    );
  }
}

class _MenuEntry {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailing;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool bold;
  const _MenuEntry(this.icon, this.title, this.onTap,
      {this.subtitle, this.trailing, this.iconColor, this.bold = false});
}

class _MenuCard extends StatelessWidget {
  final UserType role;
  final bool isPremium;
  final VoidCallback onSignOut;
  const _MenuCard({required this.role, required this.isPremium, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    final isPlayer = role == UserType.player;
    final entries = <_MenuEntry>[
      if (isPlayer) ...[
        // Frame 16 rows: highlights, candidatures, statistiques, Premium…
        _MenuEntry(LucideIcons.video, 'Mes highlights', () => context.push('/highlights/mine'),
            trailing: '12 vidéos', iconColor: p.text2),
        _MenuEntry(LucideIcons.briefcase, 'Mes candidatures', () => context.push('/applications'),
            trailing: '2 en cours', iconColor: p.text2),
        _MenuEntry(LucideIcons.barChart3, 'Mes statistiques', () => context.push('/profile-views'),
            iconColor: p.text2),
        _MenuEntry(LucideIcons.crown, 'Premium', () => context.push('/premium/subscription'),
            iconColor: AppColors.goldDark, bold: true),
        _MenuEntry(LucideIcons.settings, 'Paramètres', () => context.push('/settings'), iconColor: p.text2),
        _MenuEntry(LucideIcons.helpCircle, 'Aide et support', () => context.push('/help'), iconColor: p.text2),
        _MenuEntry(LucideIcons.logOut, 'Se déconnecter', onSignOut, iconColor: p.text2),
      ] else ...[
        // Frames M03 / M04 rows (agent & club), Abonnement added per spec.
        _MenuEntry(LucideIcons.briefcase, 'Mes opportunités', () => context.push('/opportunities/mine'),
            subtitle: role == UserType.agent ? '2 ouvertes · 1 en validation' : '3 ouvertes · 1 brouillon'),
        _MenuEntry(LucideIcons.bookmark, 'Ma liste', () => context.push('/my-list'),
            subtitle: 'Joueurs et notes privées'),
        _MenuEntry(LucideIcons.badgeCheck, 'Vérification', () => context.push('/verification'),
            subtitle: 'Profil vérifié · Voir ma demande'),
        _MenuEntry(LucideIcons.crown, 'Abonnement', () => context.push('/premium/subscription'),
            subtitle: isPremium ? 'Premium actif' : 'Découvrir Premium', iconColor: AppColors.goldDark),
        _MenuEntry(LucideIcons.settings, 'Paramètres', () => context.push('/settings'),
            subtitle: 'Langue, confidentialité et sécurité'),
        _MenuEntry(LucideIcons.helpCircle, 'Aide et support', () => context.push('/help'),
            subtitle: 'FAQ et contact'),
        _MenuEntry(LucideIcons.logOut, 'Se déconnecter', onSignOut),
      ],
    ];

    return AccountCard(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.xs),
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            IconRow(
              icon: entries[i].icon,
              title: entries[i].title,
              subtitle: entries[i].subtitle,
              trailingText: entries[i].trailing,
              iconColor: entries[i].iconColor,
              bold: entries[i].bold,
              chevron: true,
              onTap: entries[i].onTap,
            ),
            if (i < entries.length - 1) const RowDivider(),
          ],
        ],
      ),
    );
  }
}
