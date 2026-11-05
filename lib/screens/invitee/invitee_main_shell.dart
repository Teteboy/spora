import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Restricted tab shell for invitees — Figma bottom nav reduced to the
/// three destinations a guest can use:
/// Découvrir · Highlights · Profil
class InviteeMainShell extends StatefulWidget {
  final Widget child;
  const InviteeMainShell({super.key, required this.child});

  @override
  State<InviteeMainShell> createState() => _InviteeMainShellState();
}

class _InviteeMainShellState extends State<InviteeMainShell> {
  int _currentIndex = 0;

  static const _routes = [
    '/invitee/discover',
    '/invitee/highlights',
    '/invitee/profile',
  ];

  static const _items = [
    _NavItem(icon: LucideIcons.search, label: 'Découvrir'),
    _NavItem(icon: LucideIcons.play, label: 'Highlights'),
    _NavItem(icon: LucideIcons.user, label: 'Profil'),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).matchedLocation;
    final i = _routes.indexWhere((r) => location.startsWith(r));
    if (i >= 0 && i != _currentIndex) _currentIndex = i;
  }

  void _onTap(int index) {
    setState(() => _currentIndex = index);
    context.go(_routes[index]);
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
                            item.icon,
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
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
