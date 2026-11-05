import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/messaging_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Main tab shell — Figma bottom nav:
/// Accueil · Découvrir · [Highlights FAB] · Opportunités · Profil
class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _routes = ['/home', '/discover', '/highlights', '/opportunities', '/profile'];

  static const _items = [
    _NavItem(icon: LucideIcons.home, activeIcon: LucideIcons.home, label: 'Accueil', route: '/home'),
    _NavItem(icon: LucideIcons.search, activeIcon: LucideIcons.search, label: 'Découvrir', route: '/discover'),
    _NavItem(icon: LucideIcons.play, activeIcon: LucideIcons.play, label: 'Highlights', route: '/highlights', isFab: true),
    _NavItem(icon: LucideIcons.briefcase, activeIcon: LucideIcons.briefcase, label: 'Opportunités', route: '/opportunities'),
    _NavItem(icon: LucideIcons.user, activeIcon: LucideIcons.user, label: 'Profil', route: '/profile'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessagingProvider>().loadConversations();
      context.read<MessagingProvider>().loadNotifications();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).matchedLocation;
    final i = _routes.indexWhere((r) => location.startsWith(r));
    if (i >= 0 && i != _currentIndex) _currentIndex = i;
  }

  void _onTap(int index) {
    setState(() => _currentIndex = index);
    context.go(_items[index].route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 72,
            child: Row(
              children: List.generate(_items.length, (i) {
                final item = _items[i];
                final isActive = i == _currentIndex;
                if (item.isFab) return _buildFab(item, isActive, () => _onTap(i));
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primaryTint
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isActive ? item.activeIcon : item.icon,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textMuted,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontFamily: 'TikTok Sans',
                            fontSize: 9,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w400,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  /// Raised circular play button in the center, per Figma bottom nav.
  Widget _buildFab(_NavItem item, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: isActive ? AppShadows.glowBrand : AppShadows.elev2,
              ),
              child: const Icon(LucideIcons.play, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontFamily: 'TikTok Sans',
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final bool isFab;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    this.isFab = false,
  });
}

