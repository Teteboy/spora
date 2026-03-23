import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/main_shell.dart';
import '../screens/search/search_screen.dart';
import '../screens/highlights/highlights_screen.dart';
import '../screens/profile/player_profile_screen.dart';
import '../screens/profile/my_profile_screen.dart';
import '../screens/messaging/conversations_screen.dart';
import '../screens/messaging/chat_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/premium/premium_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/agent/agent_main_shell.dart';
import '../screens/agent/agent_dashboard_screen.dart';
import '../screens/agent/agent_players_screen.dart';
import '../screens/agent/agent_search_screen.dart';
import '../screens/agent/agent_messages_screen.dart';
import '../screens/agent/agent_profile_screen.dart';
import '../screens/recruiter/recruiter_main_shell.dart';
import '../screens/recruiter/recruiter_dashboard_screen.dart';
import '../screens/recruiter/recruiter_players_screen.dart';
import '../screens/recruiter/recruiter_search_screen.dart';
import '../screens/recruiter/recruiter_messages_screen.dart';
import '../screens/recruiter/recruiter_profile_screen.dart';
import '../models/player_model.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final _agentShellNavigatorKey = GlobalKey<NavigatorState>();
final _recruiterShellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = authProvider.isAuthenticated;
      final isSplash = state.matchedLocation == '/splash';
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/onboarding');

      if (isSplash) return null;
      if (!isAuthenticated && !isAuthRoute) return '/login';
      
      // Redirect based on user type
      if (isAuthenticated && isAuthRoute) {
        switch (authProvider.selectedUserType) {
          case UserType.player:
          case UserType.guest:
            return '/home';
          case UserType.agent:
            return '/agent/dashboard';
          case UserType.recruiter:
            return '/recruiter/dashboard';
        }
      }
      return null;
    },
    refreshListenable: authProvider,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/highlights',
            builder: (context, state) => const HighlightsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const MyProfileScreen(),
          ),
          GoRoute(
            path: '/messages',
            builder: (context, state) => const ConversationsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/player/:id',
        builder: (context, state) {
          final player = state.extra as PlayerModel?;
          return PlayerProfileScreen(player: player);
        },
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) {
          final conversationId = state.pathParameters['id']!;
          final args = state.extra as Map<String, dynamic>?;
          return ChatScreen(
            conversationId: conversationId,
            participantName: args?['name'] ?? '',
            participantAvatar: args?['avatar'],
            participantRole: args?['role'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/premium',
        builder: (context, state) => const PremiumScreen(),
      ),
      GoRoute(
        path: '/agent',
        builder: (context, state) => const AgentDashboardScreen(),
      ),
      GoRoute(
        path: '/recruiter',
        builder: (context, state) => const RecruiterDashboardScreen(),
      ),
      // Agent Shell Route
      ShellRoute(
        navigatorKey: _agentShellNavigatorKey,
        builder: (context, state, child) => AgentMainShell(child: child),
        routes: [
          GoRoute(
            path: '/agent/dashboard',
            builder: (context, state) => const AgentDashboardScreen(),
          ),
          GoRoute(
            path: '/agent/players',
            builder: (context, state) => const AgentPlayersScreen(),
          ),
          GoRoute(
            path: '/agent/search',
            builder: (context, state) => const AgentSearchScreen(),
          ),
          GoRoute(
            path: '/agent/messages',
            builder: (context, state) => const AgentMessagesScreen(),
          ),
          GoRoute(
            path: '/agent/profile',
            builder: (context, state) => const AgentProfileScreen(),
          ),
        ],
      ),
      // Recruiter Shell Route
      ShellRoute(
        navigatorKey: _recruiterShellNavigatorKey,
        builder: (context, state, child) => RecruiterMainShell(child: child),
        routes: [
          GoRoute(
            path: '/recruiter/dashboard',
            builder: (context, state) => const RecruiterDashboardScreen(),
          ),
          GoRoute(
            path: '/recruiter/players',
            builder: (context, state) => const RecruiterPlayersScreen(),
          ),
          GoRoute(
            path: '/recruiter/search',
            builder: (context, state) => const RecruiterSearchScreen(),
          ),
          GoRoute(
            path: '/recruiter/messages',
            builder: (context, state) => const RecruiterMessagesScreen(),
          ),
          GoRoute(
            path: '/recruiter/profile',
            builder: (context, state) => const RecruiterProfileScreen(),
          ),
        ],
      ),
    ],
  );
}
