import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/messaging_provider.dart';

class RecruiterMainShell extends StatefulWidget {
  final Widget child;
  const RecruiterMainShell({super.key, required this.child});

  @override
  State<RecruiterMainShell> createState() => _RecruiterMainShellState();
}

class _RecruiterMainShellState extends State<RecruiterMainShell> {
  int _currentIndex = 0;

  final List<_NavItem> _items = const [
    _NavItem(
        icon: Icons.dashboard_outlined,
        label: 'Dashboard',
        route: '/recruiter/dashboard'),
    _NavItem(
        icon: Icons.people_outline,
        label: 'Candidats',
        route: '/recruiter/players'),
    _NavItem(
        icon: Icons.search, label: 'Recherche', route: '/recruiter/search'),
    _NavItem(
        icon: Icons.message_outlined,
        label: 'Messages',
        route: '/recruiter/messages'),
    _NavItem(
        icon: Icons.person_outline,
        label: 'Profil',
        route: '/recruiter/profile'),
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
  Widget build(BuildContext context) {
    // Update current index based on route
    final location = GoRouterState.of(context).matchedLocation;
    final index = _items.indexWhere((item) => location.startsWith(item.route));
    if (index != -1 && index != _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _currentIndex = index);
        }
      });
    }

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

  void _onTap(int index) {
    setState(() => _currentIndex = index);
    context.go(_items[index].route);
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem(
      {required this.icon, required this.label, required this.route});
}
