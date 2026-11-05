import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Inbox — frame "Messages" (Tous / Non lus / Propositions).
class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  int _tab = 0; // 0 Tous · 1 Non lus · 2 Propositions
  final _searchCtrl = TextEditingController();

  // Local mock conversations (provider kept read-only per spec).
  late final List<_Conv> _convs = [
    _Conv(
      id: 'c1',
      initials: 'AR',
      name: 'Académie des Rives',
      role: 'Club',
      verified: true,
      message: 'Bonjour Jordan, avez-vous une vidéo récente ?',
      time: DateTime.now().subtract(const Duration(minutes: 23)),
      unread: 2,
      isClub: true,
      hasProposal: true,
    ),
    _Conv(
      id: 'c2',
      initials: 'NM',
      name: 'Nadia Mensah',
      role: 'Agent',
      verified: true,
      message: 'Bonjour Jordan, votre profil a retenu mon attention.',
      time: DateTime.now().subtract(const Duration(minutes: 56)),
      unread: 1,
      hasProposal: true,
    ),
    _Conv(
      id: 'c3',
      initials: 'ÉL',
      name: 'Étoile du Littoral',
      role: 'Club',
      verified: true,
      message: 'Une proposition vous attend.',
      time: DateTime.now().subtract(const Duration(hours: 3)),
      unread: 0,
      isClub: true,
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  int get _unreadTotal => _convs.fold(0, (s, c) => s + c.unread);
  int get _unreadConvs => _convs.where((c) => c.unread > 0).length;

  List<_Conv> get _visible {
    final q = _searchCtrl.text.trim().toLowerCase();
    Iterable<_Conv> list = _convs;
    if (_tab == 1) list = list.where((c) => c.unread > 0);
    if (_tab == 2) list = list.where((c) => c.hasProposal);
    if (q.isNotEmpty) {
      list = list.where((c) =>
          c.name.toLowerCase().contains(q) ||
          c.message.toLowerCase().contains(q));
    }
    final sorted = list.toList()
      ..sort((a, b) => b.time.compareTo(a.time));
    return sorted;
  }

  void _open(_Conv c) {
    setState(() => c.unread = 0); // unread clears on open
    context.push('/chat/${c.id}', extra: {
      'name': c.name,
      'avatar': c.isClub ? null : 'https://i.pravatar.cc/150?u=${c.id}',
      'role': c.role,
      'isClub': c.isClub,
    });
  }

  @override
  Widget build(BuildContext context) {
    final userType = context.watch<AuthProvider>().selectedUserType;
    final visible = _visible;

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.screenMargin, vertical: AppDimens.lg),
          children: [
            Row(
              children: [
                Expanded(
                    child:
                        Text('Messages', style: AppTextStyles.display())),
                _notifButton(),
              ],
            ),
            const SizedBox(height: AppDimens.section),

            // Search card
            Container(
              padding: const EdgeInsets.all(AppDimens.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text('Recherche',
                              style: AppTextStyles.bodyLarge())),
                      const Icon(LucideIcons.search,
                          color: AppColors.textMuted, size: 20),
                    ],
                  ),
                  const SizedBox(height: AppDimens.xs),
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    style: AppTextStyles.body(),
                    decoration: InputDecoration(
                      hintText: 'Rechercher une conversation…',
                      hintStyle:
                          AppTextStyles.body(color: AppColors.textMuted),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.lg),

            // Tabs
            Row(
              children: [
                _tabPill('Tous', _tab == 0, () => setState(() => _tab = 0)),
                const SizedBox(width: AppDimens.sm),
                _tabPill(
                  _unreadTotal > 0 ? 'Non lus · $_unreadTotal' : 'Non lus',
                  _tab == 1,
                  () => setState(() => _tab = 1),
                ),
                const SizedBox(width: AppDimens.sm),
                _tabPill('Propositions', _tab == 2,
                    () => setState(() => _tab = 2)),
              ],
            ),
            const SizedBox(height: AppDimens.lg),

            if (_tab == 1 && visible.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.lg),
                child: Text('$_unreadConvs conversations non lues',
                    style: AppTextStyles.h1()),
              ),

            if (_tab == 2 && visible.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.lg),
                child:
                    Text('Propositions reçues', style: AppTextStyles.h1()),
              ),

            if (visible.isEmpty)
              _emptyState(userType)
            else ...[
              for (final c in visible) ...[
                _convCard(c),
                const SizedBox(height: AppDimens.lg),
              ],
            ],

            // Info banner
            Container(
              padding: const EdgeInsets.all(AppDimens.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius: BorderRadius.circular(AppDimens.radiusCard),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _tab == 0
                        ? 'Des échanges professionnels'
                        : 'Vous gardez le contrôle',
                    style: AppTextStyles.bodyStrong(color: AppColors.primary),
                  ),
                  const SizedBox(height: AppDimens.xs),
                  Text(
                    _tab == 0
                        ? 'Un joueur répond à un recruteur ou échange après une candidature. Pas de sollicitation non demandée.'
                        : 'En tant que joueur, vous pouvez répondre aux recruteurs vérifiés. Vous pouvez aussi échanger après une candidature. Un e-mail vérifié est requis pour envoyer un message.',
                    style: AppTextStyles.body(color: AppColors.primary),
                  ),
                ],
              ),
            ),

            if (_tab != 0 && _unreadTotal > 0) ...[
              const SizedBox(height: AppDimens.lg),
              _outlineButton('Tout marquer comme lu', () {
                setState(() {
                  for (final c in _convs) {
                    c.unread = 0;
                  }
                });
              }),
            ],
            const SizedBox(height: AppDimens.section),
          ],
        ),
      ),
    );
  }

  Widget _tabPill(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryTint : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyStrong(
              color: selected ? AppColors.primary : AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _convCard(_Conv c) {
    return GestureDetector(
      onTap: () => _open(c),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _avatar(c),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name, style: AppTextStyles.h3()),
                      const SizedBox(height: AppDimens.xs),
                      Row(
                        children: [
                          _roleChip(c.role, c.isClub),
                          if (c.verified) ...[
                            const SizedBox(width: AppDimens.xs),
                            const Icon(LucideIcons.badgeCheck,
                                size: 20, color: AppColors.primary),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppDimens.sm),
                      Text(
                        c.hasProposal && _tab == 2
                            ? 'Proposition · Détection U21 · Douala'
                            : c.message,
                        style: AppTextStyles.body(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimens.xs),
                      Text(
                        '${_fmtTime(c.time)} · Identité vérifiée',
                        style: AppTextStyles.caption(),
                      ),
                    ],
                  ),
                ),
                if (c.unread > 0)
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryTint,
                      shape: BoxShape.circle,
                    ),
                    child: Text('${c.unread}',
                        style:
                            AppTextStyles.bodyStrong(color: AppColors.primary)),
                  ),
              ],
            ),
            if (c.hasProposal && _tab == 2) ...[
              const SizedBox(height: AppDimens.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimens.md),
                decoration: BoxDecoration(
                  color: AppColors.clubGreen.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppDimens.radiusInput),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Invitation à une détection',
                        style:
                            AppTextStyles.bodyStrong(color: AppColors.clubGreen)),
                    const SizedBox(height: AppDimens.xs),
                    Text('14–15 novembre 2026 · 18–21 ans · Sans frais',
                        style:
                            AppTextStyles.body(color: AppColors.clubGreen)),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.md),
              _outlineButton('Voir l’opportunité', () {},
                  color: AppColors.textPrimary),
            ],
          ],
        ),
      ),
    );
  }

  Widget _avatar(_Conv c) {
    if (c.isClub) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.clubGreen.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.shield,
                color: AppColors.clubGreen, size: 28),
            const SizedBox(height: AppDimens.xxs),
            Text(c.initials,
                style: AppTextStyles.micro(color: AppColors.clubGreen)),
          ],
        ),
      );
    }
    return ClipOval(
      child: Image.network(
        'https://i.pravatar.cc/150?u=${c.id}',
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _initialsAvatar(c),
        errorBuilder: (context, error, stack) => _initialsAvatar(c),
      ),
    );
  }

  Widget _initialsAvatar(_Conv c) => Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.primaryTint,
          shape: BoxShape.circle,
        ),
        child: Text(c.initials,
            style: AppTextStyles.h2(color: AppColors.primary)),
      );

  Widget _roleChip(String role, bool isClub) {
    final color = isClub ? AppColors.clubGreen : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isClub
            ? AppColors.clubGreen.withValues(alpha: 0.10)
            : AppColors.primaryTint,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Text(role, style: AppTextStyles.caption(color: color)),
    );
  }

  Widget _outlineButton(String label, VoidCallback onTap, {Color? color}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusCard)),
        ),
        child: Text(label,
            style:
                AppTextStyles.button(color: color ?? AppColors.primary)),
      ),
    );
  }

  Widget _notifButton() => GestureDetector(
        onTap: () => context.push('/notifications'),
        child: Container(
          width: AppDimens.minTouch,
          height: AppDimens.minTouch,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusInput),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(LucideIcons.bell,
              size: 22, color: AppColors.textPrimary),
        ),
      );

  Widget _emptyState(UserType userType) {
    final isAgent = userType == UserType.agent || userType == UserType.recruiter;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.huge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 160,
              height: 160,
              decoration: const BoxDecoration(
                color: AppColors.primaryTint,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.messageCircle,
                  size: 64, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: AppDimens.xxl),
          Text('Aucun message pour\nl’instant',
              style: AppTextStyles.display()),
          const SizedBox(height: AppDimens.lg),
          Text(
            isAgent
                ? 'Contactez un joueur depuis son profil.'
                : 'Complétez votre profil et publiez un highlight pour être repéré.',
            style: AppTextStyles.bodyLarge(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimens.xl),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(colors: AppColors.primaryGradient),
                borderRadius: BorderRadius.circular(AppDimens.radiusCard),
              ),
              child: ElevatedButton(
                onPressed: () =>
                    context.go(isAgent ? '/discover' : '/profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusCard)),
                ),
                child: Text(
                  isAgent ? 'Découvrir les joueurs' : 'Compléter mon profil',
                  style: AppTextStyles.button(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

class _Conv {
  final String id;
  final String initials;
  final String name;
  final String role;
  final bool verified;
  final String message;
  final DateTime time;
  int unread;
  final bool isClub;
  final bool hasProposal;

  _Conv({
    required this.id,
    required this.initials,
    required this.name,
    required this.role,
    required this.verified,
    required this.message,
    required this.time,
    required this.unread,
    this.isClub = false,
    this.hasProposal = false,
  });
}
