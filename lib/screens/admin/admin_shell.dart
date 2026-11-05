import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Persistent administration layout: fixed 240 px navy sidebar on wide
/// screens (< 900 px it collapses into a [Drawer] with a hamburger),
/// plus a light top bar with page context and the admin avatar.
class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});
  final Widget child;

  static const double _sidebarWidth = 240;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 900;
      return Scaffold(
        backgroundColor: AppColors.appBg,
        drawer: wide ? null : const Drawer(child: _AdminSidebar()),
        body: Row(
          children: [
            if (wide)
              const SizedBox(width: _sidebarWidth, child: _AdminSidebar()),
            Expanded(
              child: Column(
                children: [
                  _AdminTopBar(showMenu: !wide),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Sidebar ─────────────────────────────────────────────────────────────────

class _NavItem {
  const _NavItem(this.label, this.route, this.icon);
  final String label;
  final String route;
  final IconData icon;
}

const _mainItems = [
  _NavItem('Tableau de bord', '/admin/dashboard', LucideIcons.layoutGrid),
  _NavItem('Modération vidéos', '/admin/moderation', LucideIcons.video),
  _NavItem('Utilisateurs', '/admin/users', LucideIcons.users),
  _NavItem('Vérifications', '/admin/verifications', LucideIcons.shieldCheck),
  _NavItem('Signalements', '/admin/reports', LucideIcons.flag),
  _NavItem('Protection des mineurs', '/admin/minors', LucideIcons.shield),
  _NavItem('Opportunités', '/admin/opportunities', LucideIcons.briefcase),
  _NavItem('Abonnements', '/admin/subscriptions', LucideIcons.crown),
  _NavItem('Finances', '/admin/finances', LucideIcons.wallet),
  _NavItem('Journal d\'audit', '/admin/audit', LucideIcons.receipt),
];

const _superItems = [
  _NavItem('Vue globale', '/admin/super', LucideIcons.globe),
  _NavItem('Équipe', '/admin/super/team', LucideIcons.users),
  _NavItem('Rôles', '/admin/super/roles', LucideIcons.shieldCheck),
  _NavItem('Configuration', '/admin/super/config', LucideIcons.settings),
  _NavItem('Intégrations', '/admin/super/integrations', LucideIcons.puzzle),
  _NavItem('Sécurité', '/admin/super/security', LucideIcons.lock),
];

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    return Container(
      color: AppColors.navy900,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppDimens.xl, AppDimens.xl, AppDimens.xl, AppDimens.lg),
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.h1(color: AppColors.textLight),
                  children: const [
                    TextSpan(text: 'SP'),
                    TextSpan(
                        text: 'O', style: TextStyle(color: AppColors.gold)),
                    TextSpan(text: 'RA'),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.xl),
              child: Text('ESPACE ADMINISTRATION',
                  style: AppTextStyles.eyebrow(
                      color: AppColors.darkTextMuted)),
            ),
            const SizedBox(height: AppDimens.md),
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppDimens.md),
                children: [
                  for (final item in _mainItems)
                    _SidebarTile(item: item, location: location),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppDimens.md),
                    child: Divider(color: AppColors.darkBorder, height: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: AppDimens.md, bottom: AppDimens.sm),
                    child: Text('SUPERADMIN',
                        style: AppTextStyles.eyebrow(
                            color: AppColors.darkTextMuted)),
                  ),
                  for (final item in _superItems)
                    _SidebarTile(item: item, location: location),
                ],
              ),
            ),
            // Admin identity + logout
            Padding(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Amina Diallo',
                      style:
                          AppTextStyles.bodyStrong(color: AppColors.textLight)),
                  const SizedBox(height: AppDimens.xxs),
                  Text('Administratrice · 2FA active',
                      style: AppTextStyles.caption(
                          color: AppColors.darkTextMuted)),
                  const SizedBox(height: AppDimens.sm),
                  InkWell(
                    onTap: () => context.go('/admin/login'),
                    child: Text('Se déconnecter →',
                        style:
                            AppTextStyles.caption(color: AppColors.primary)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({required this.item, required this.location});
  final _NavItem item;
  final String location;

  @override
  Widget build(BuildContext context) {
    final active = location == item.route ||
        location.startsWith('${item.route}/');
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.xxs),
      child: InkWell(
        onTap: () {
          if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
            Navigator.of(context).pop();
          }
          context.go(item.route);
        },
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.md, vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.navy700 : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          ),
          child: Row(
            children: [
              Icon(item.icon,
                  size: 20,
                  color: active
                      ? AppColors.textLight
                      : AppColors.darkTextMuted),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Text(
                  item.label,
                  style: AppTextStyles.body(
                          color: active
                              ? AppColors.textLight
                              : AppColors.darkTextSecondary)
                      .copyWith(
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.w400),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Top bar ─────────────────────────────────────────────────────────────────

class _AdminTopBar extends StatelessWidget {
  const _AdminTopBar({required this.showMenu});
  final bool showMenu;

  static const _titles = <String, String>{
    '/admin/dashboard': 'Tableau de bord',
    '/admin/moderation': 'Modération vidéos',
    '/admin/users': 'Utilisateurs',
    '/admin/verifications': 'Vérifications',
    '/admin/reports': 'Signalements',
    '/admin/minors': 'Protection des mineurs',
    '/admin/opportunities': 'Opportunités',
    '/admin/subscriptions': 'Abonnements',
    '/admin/finances': 'Finances',
    '/admin/audit': 'Journal d\'audit',
    '/admin/super': 'Vue globale',
    '/admin/super/team': 'Équipe',
    '/admin/super/roles': 'Rôles',
    '/admin/super/config': 'Configuration',
    '/admin/super/integrations': 'Intégrations',
    '/admin/super/security': 'Sécurité',
  };

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final title = _titles.entries
        .where((e) => location.startsWith(e.key))
        .map((e) => e.value)
        .fold<String>('Administration',
            (best, t) => t.length > best.length || best == 'Administration' ? t : best);
    return Container(
      height: AppDimens.topBar + 8,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (showMenu)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(LucideIcons.menu, color: AppColors.textPrimary),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          Expanded(
            child: Text('SPORA / Administration / $title',
                style: AppTextStyles.caption(),
                overflow: TextOverflow.ellipsis),
          ),
          const _Tag('Démonstration'),
          const SizedBox(width: AppDimens.md),
          const Icon(LucideIcons.bell,
              size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppDimens.md),
          const _Tag('Admin'),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Text(label,
          style: AppTextStyles.caption(color: AppColors.textSecondary)),
    );
  }
}
