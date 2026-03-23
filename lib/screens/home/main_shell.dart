import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/messaging_provider.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<_NavItem> _items = const [
    _NavItem(icon: Icons.home_outlined, label: 'Accueil', route: '/home'),
    _NavItem(icon: Icons.search, label: 'Découvrir', route: '/search'),
    _NavItem(
      icon: Icons.message_outlined,
      label: 'Messages',
      route: '/messages',
    ),
    _NavItem(icon: Icons.star, label: 'Highlights', route: '/highlights'),
    _NavItem(icon: Icons.person_outline, label: 'Profil', route: '/profile'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessagingProvider>().loadConversations();
      context.read<MessagingProvider>().loadNotifications();
    });
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
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
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
                          child: Icon(
                            item.icon,
                            color: isActive
                                ? AppColors.gold
                                : AppColors.textSecondary,
                            size: isActive ? 26 : 22,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w400,
                            color: isActive
                                ? AppColors.gold
                                : AppColors.textSecondary,
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
  final String route;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
