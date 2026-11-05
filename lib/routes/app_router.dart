import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../models/player_model.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/auth/role_choice_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/email_sent_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/auth/password_updated_screen.dart';
import '../screens/auth/verify_email_screen.dart';
import '../screens/auth/email_confirmed_screen.dart';
import '../screens/auth/session_expired_screen.dart';
import '../screens/auth/account_suspended_screen.dart';
import '../screens/auth/protected_connection_screen.dart';
import '../screens/auth/invite_code_screen.dart';
import '../screens/invitee/invitee_main_shell.dart';
import '../screens/invitee/invitee_profile_screen.dart';
import '../screens/invitee/restricted_access_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/main_shell.dart';
import '../screens/home/home_screen.dart';
import '../screens/discover/discover_screen.dart';
import '../screens/discover/filters_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/highlights/highlights_screen.dart';
import '../screens/highlights/publish_highlight_screen.dart';
import '../screens/highlights/my_highlights_screen.dart';
import '../screens/opportunities/opportunities_screen.dart';
import '../screens/opportunities/opportunity_detail_screen.dart';
import '../screens/opportunities/apply_screen.dart';
import '../screens/opportunities/publish_opportunity_screen.dart';
import '../screens/opportunities/my_opportunities_screen.dart';
import '../screens/opportunities/candidates_screen.dart';
import '../screens/opportunities/my_applications_screen.dart';
import '../screens/messaging/conversations_screen.dart';
import '../screens/messaging/chat_screen.dart';
import '../screens/messaging/first_message_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/profile/player_profile_screen.dart';
import '../screens/profile/my_profile_screen.dart';
import '../screens/profile/agent_profile_screen.dart';
import '../screens/profile/club_profile_screen.dart';
import '../screens/profile/my_list_screen.dart';
import '../screens/profile/video_player_screen.dart';
import '../screens/profile/profile_views_screen.dart';
import '../screens/premium/premium_screen.dart';
import '../screens/premium/momo_payment_screen.dart';
import '../screens/premium/card_payment_screen.dart';
import '../screens/premium/three_ds_screen.dart';
import '../screens/premium/premium_welcome_screen.dart';
import '../screens/premium/subscription_screen.dart';
import '../screens/premium/cancel_subscription_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/account/edit_profile_screen.dart';
import '../screens/account/notification_settings_screen.dart';
import '../screens/account/privacy_screen.dart';
import '../screens/account/security_screen.dart';
import '../screens/account/help_screen.dart';
import '../screens/account/report_problem_screen.dart';
import '../screens/account/delete_account_screen.dart';
import '../screens/account/verification_screen.dart';
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
import '../screens/admin/admin_shell.dart';
import '../screens/admin/admin_login_screen.dart';
import '../screens/admin/admin_2fa_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/video_moderation_screen.dart';
import '../screens/admin/users_screen.dart';
import '../screens/admin/verifications_screen.dart';
import '../screens/admin/reports_screen.dart';
import '../screens/admin/minors_screen.dart';
import '../screens/admin/admin_opportunities_screen.dart';
import '../screens/admin/subscriptions_screen.dart';
import '../screens/admin/finances_screen.dart';
import '../screens/admin/audit_log_screen.dart';
import '../screens/admin/superadmin_screens.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final _adminShellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = authProvider.isAuthenticated;
      final loc = state.matchedLocation;
      final isSplash = loc == '/splash';
      final isAdmin = loc.startsWith('/admin');
      final isAuthRoute = loc.startsWith('/login') ||
          loc.startsWith('/register') ||
          loc.startsWith('/welcome') ||
          loc.startsWith('/role') ||
          loc.startsWith('/forgot-password') ||
          loc.startsWith('/email-sent') ||
          loc.startsWith('/reset-password') ||
          loc.startsWith('/password-updated') ||
          loc.startsWith('/session-expired') ||
          loc.startsWith('/account-suspended') ||
          loc.startsWith('/protected-connection') ||
          loc.startsWith('/invite') ||
          loc.startsWith('/onboarding') ||
          loc.startsWith('/verify-email') ||
          loc.startsWith('/email-confirmed');

      if (isSplash || isAdmin) return null;
      if (!isAuthenticated && !isAuthRoute) return '/welcome';
      final roleHome = switch (authProvider.selectedUserType) {
        UserType.agent => '/agent/dashboard',
        UserType.recruiter => '/recruiter/dashboard',
        UserType.guest => '/invitee/discover',
        _ => '/home',
      };
      if (isAuthenticated && (loc == '/login' || loc == '/welcome')) {
        return roleHome;
      }
      if (isAuthenticated && loc == '/home' && roleHome != '/home') {
        return roleHome;
      }
      // Highlights exists in every role's shell — remap the shared path.
      if (isAuthenticated && loc == '/highlights') {
        final roleHighlights = switch (authProvider.selectedUserType) {
          UserType.agent => '/agent/highlights',
          UserType.recruiter => '/recruiter/highlights',
          UserType.guest => '/invitee/highlights',
          _ => null,
        };
        if (roleHighlights != null) return roleHighlights;
      }
      // Invitee (guest) access control: read-only discovery. Anything outside
      // the allowlist is redirected to the locked screen; the equivalent
      // player-shell tab paths are remapped to the invitee shell.
      if (isAuthenticated && authProvider.isGuest) {
        const remapped = {
          '/discover': '/invitee/discover',
          '/highlights': '/invitee/highlights',
          '/profile': '/invitee/profile',
        };
        if (remapped.containsKey(loc)) return remapped[loc];
        const allowed = [
          '/invitee',
          '/restricted',
          '/player/',
          '/club/',
          '/agent-profile/',
          '/video-player',
          '/search',
          '/filters',
          '/settings',
          '/help',
        ];
        if (!allowed.any((p) => loc.startsWith(p))) return '/restricted';
      } else if (isAuthenticated && loc.startsWith('/invitee')) {
        return roleHome;
      }
      return null;
    },
    refreshListenable: authProvider,
    routes: [
      // ── Entry & auth ─────────────────────────────────────────────
      GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (c, s) => const WelcomeScreen()),
      GoRoute(path: '/role', builder: (c, s) => const RoleChoiceScreen()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/forgot-password', builder: (c, s) => const ForgotPasswordScreen()),
      GoRoute(path: '/email-sent', builder: (c, s) => EmailSentScreen(email: s.extra as String?)),
      GoRoute(path: '/reset-password', builder: (c, s) => const ResetPasswordScreen()),
      GoRoute(path: '/password-updated', builder: (c, s) => const PasswordUpdatedScreen()),
      GoRoute(path: '/verify-email', builder: (c, s) => VerifyEmailScreen(email: s.extra as String?)),
      GoRoute(path: '/email-confirmed', builder: (c, s) => const EmailConfirmedScreen()),
      GoRoute(path: '/session-expired', builder: (c, s) => const SessionExpiredScreen()),
      GoRoute(path: '/account-suspended', builder: (c, s) => const AccountSuspendedScreen()),
      GoRoute(path: '/protected-connection', builder: (c, s) => const ProtectedConnectionScreen()),
      GoRoute(path: '/invite', builder: (c, s) => const InviteCodeScreen()),
      GoRoute(
        path: '/restricted',
        builder: (c, s) => RestrictedAccessScreen(feature: s.extra as String?),
      ),

      // ── Onboarding ───────────────────────────────────────────────
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
      GoRoute(path: '/onboarding/player', builder: (c, s) => const PlayerOnboardingScreen()),
      GoRoute(path: '/onboarding/agent', builder: (c, s) => const AgentOnboardingScreen()),
      GoRoute(path: '/onboarding/club', builder: (c, s) => const ClubOnboardingScreen()),

      // ── Main shell (5 tabs) ──────────────────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
          GoRoute(path: '/discover', builder: (c, s) => const DiscoverScreen()),
          GoRoute(path: '/highlights', builder: (c, s) => const HighlightsScreen()),
          GoRoute(path: '/opportunities', builder: (c, s) => const OpportunitiesScreen()),
          GoRoute(path: '/messages', builder: (c, s) => const ConversationsScreen()),
          GoRoute(path: '/profile', builder: (c, s) => const MyProfileScreen()),
        ],
      ),

      // ── Invitee shell (3 tabs, read-only) ────────────────────────
      GoRoute(path: '/invitee', redirect: (c, s) => '/invitee/discover'),
      ShellRoute(
        builder: (context, state, child) => InviteeMainShell(child: child),
        routes: [
          GoRoute(path: '/invitee/discover', builder: (c, s) => const DiscoverScreen()),
          GoRoute(path: '/invitee/highlights', builder: (c, s) => const HighlightsScreen()),
          GoRoute(path: '/invitee/profile', builder: (c, s) => const InviteeProfileScreen()),
        ],
      ),

      // ── Discover / search ────────────────────────────────────────
      GoRoute(path: '/search', builder: (c, s) => const SearchScreen()),
      GoRoute(path: '/filters', builder: (c, s) => const FiltersScreen()),

      // ── Profiles ─────────────────────────────────────────────────
      GoRoute(
        path: '/player/:id',
        builder: (c, s) => PlayerProfileScreen(player: s.extra as PlayerModel?),
      ),
      GoRoute(
        path: '/agent-profile/:id',
        builder: (c, s) => AgentPublicProfileScreen(agentId: s.pathParameters['id']),
      ),
      GoRoute(
        path: '/club/:id',
        builder: (c, s) => ClubProfileScreen(clubId: s.pathParameters['id']),
      ),
      GoRoute(path: '/my-list', builder: (c, s) => const MyListScreen()),
      GoRoute(
        path: '/video-player',
        builder: (c, s) => VideoPlayerScreen(title: s.extra as String?),
      ),
      GoRoute(path: '/profile-views', builder: (c, s) => const ProfileViewsScreen()),

      // ── Highlights ───────────────────────────────────────────────
      GoRoute(path: '/highlights/publish', builder: (c, s) => const PublishHighlightScreen()),
      GoRoute(path: '/highlights/mine', builder: (c, s) => const MyHighlightsScreen()),

      // ── Opportunities ────────────────────────────────────────────
      GoRoute(
        path: '/opportunity/:id',
        builder: (c, s) => OpportunityDetailScreen(opportunityId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/opportunity/:id/apply',
        builder: (c, s) => ApplyScreen(opportunityId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/opportunity/:id/candidates',
        builder: (c, s) => CandidatesScreen(opportunityId: s.pathParameters['id']!),
      ),
      GoRoute(path: '/opportunities/publish', builder: (c, s) => const PublishOpportunityScreen()),
      GoRoute(path: '/opportunities/mine', builder: (c, s) => const MyOpportunitiesScreen()),
      GoRoute(path: '/applications', builder: (c, s) => const MyApplicationsScreen()),

      // ── Messaging / notifications ────────────────────────────────
      GoRoute(
        path: '/chat/:id',
        builder: (c, s) {
          final args = s.extra as Map<String, dynamic>?;
          return ChatScreen(
            conversationId: s.pathParameters['id']!,
            participantName: args?['name'] ?? '',
            participantAvatar: args?['avatar'],
            participantRole: args?['role'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/first-message',
        builder: (c, s) {
          final args = s.extra as Map<String, dynamic>? ?? {};
          return FirstMessageScreen(
            participantName: args['name'] ?? '',
            participantSubtitle: args['subtitle'] ?? '',
            conversationId: args['conversationId'],
          );
        },
      ),
      GoRoute(path: '/notifications', builder: (c, s) => const NotificationsScreen()),

      // ── Premium ──────────────────────────────────────────────────
      GoRoute(path: '/premium', builder: (c, s) => const PremiumScreen()),
      GoRoute(path: '/premium/momo', builder: (c, s) => const MomoPaymentScreen()),
      GoRoute(path: '/premium/card', builder: (c, s) => const CardPaymentScreen()),
      GoRoute(path: '/premium/3ds', builder: (c, s) => const ThreeDsScreen()),
      GoRoute(path: '/premium/welcome', builder: (c, s) => const PremiumWelcomeScreen()),
      GoRoute(
        path: '/premium/subscription',
        builder: (c, s) {
          final extra = s.extra as Map<String, dynamic>?;
          return SubscriptionScreen(expired: extra?['expired'] == true);
        },
      ),
      GoRoute(path: '/premium/cancel', builder: (c, s) => const CancelSubscriptionScreen()),

      // ── Account & settings ───────────────────────────────────────
      GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
      GoRoute(path: '/edit-profile', builder: (c, s) => const EditProfileScreen()),
      GoRoute(path: '/settings/notifications', builder: (c, s) => const NotificationSettingsScreen()),
      GoRoute(path: '/settings/privacy', builder: (c, s) => const PrivacyScreen()),
      GoRoute(path: '/settings/security', builder: (c, s) => const SecurityScreen()),
      GoRoute(path: '/help', builder: (c, s) => const HelpScreen()),
      GoRoute(
        path: '/report',
        builder: (c, s) => ReportProblemScreen(targetName: s.extra as String?),
      ),
      GoRoute(path: '/delete-account', builder: (c, s) => const DeleteAccountScreen()),
      GoRoute(path: '/verification', builder: (c, s) => const VerificationScreen()),

      // ── Agent module ─────────────────────────────────────────────
      GoRoute(path: '/agent', redirect: (c, s) => '/agent/dashboard'),
      ShellRoute(
        builder: (context, state, child) => AgentMainShell(child: child),
        routes: [
          GoRoute(path: '/agent/dashboard', builder: (c, s) => const AgentDashboardScreen()),
          GoRoute(path: '/agent/players', builder: (c, s) => const AgentPlayersScreen()),
          GoRoute(path: '/agent/search', builder: (c, s) => const AgentSearchScreen()),
          GoRoute(path: '/agent/highlights', builder: (c, s) => const HighlightsScreen()),
          GoRoute(path: '/agent/messages', builder: (c, s) => const AgentMessagesScreen()),
          GoRoute(path: '/agent/profile', builder: (c, s) => const AgentProfileScreen()),
        ],
      ),

      // ── Recruiter (club) module ──────────────────────────────────
      GoRoute(path: '/recruiter', redirect: (c, s) => '/recruiter/dashboard'),
      ShellRoute(
        builder: (context, state, child) => RecruiterMainShell(child: child),
        routes: [
          GoRoute(path: '/recruiter/dashboard', builder: (c, s) => const RecruiterDashboardScreen()),
          GoRoute(path: '/recruiter/players', builder: (c, s) => const RecruiterPlayersScreen()),
          GoRoute(path: '/recruiter/search', builder: (c, s) => const RecruiterSearchScreen()),
          GoRoute(path: '/recruiter/highlights', builder: (c, s) => const HighlightsScreen()),
          GoRoute(path: '/recruiter/messages', builder: (c, s) => const RecruiterMessagesScreen()),
          GoRoute(path: '/recruiter/profile', builder: (c, s) => const RecruiterProfileScreen()),
        ],
      ),

      // ── Admin module ─────────────────────────────────────────────
      GoRoute(path: '/admin/login', builder: (c, s) => const AdminLoginScreen()),
      GoRoute(path: '/admin/2fa', builder: (c, s) => const Admin2faScreen()),
      ShellRoute(
        navigatorKey: _adminShellNavigatorKey,
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/admin', redirect: (c, s) => '/admin/dashboard'),
          GoRoute(path: '/admin/dashboard', builder: (c, s) => const AdminDashboardScreen()),
          GoRoute(path: '/admin/moderation', builder: (c, s) => const VideoModerationScreen()),
          GoRoute(
            path: '/admin/moderation/:id',
            builder: (c, s) => HighlightReviewScreen(itemId: s.pathParameters['id']!),
          ),
          GoRoute(path: '/admin/users', builder: (c, s) => const AdminUsersScreen()),
          GoRoute(
            path: '/admin/users/:id',
            builder: (c, s) => AdminUserDetailScreen(userId: s.pathParameters['id']!),
          ),
          GoRoute(path: '/admin/verifications', builder: (c, s) => const VerificationsScreen()),
          GoRoute(path: '/admin/reports', builder: (c, s) => const AdminReportsScreen()),
          GoRoute(path: '/admin/minors', builder: (c, s) => const MinorsScreen()),
          GoRoute(path: '/admin/opportunities', builder: (c, s) => const AdminOpportunitiesScreen()),
          GoRoute(path: '/admin/subscriptions', builder: (c, s) => const AdminSubscriptionsScreen()),
          GoRoute(path: '/admin/finances', builder: (c, s) => const FinancesScreen()),
          GoRoute(path: '/admin/audit', builder: (c, s) => const AuditLogScreen()),
          GoRoute(path: '/admin/super', builder: (c, s) => const SuperOverviewScreen()),
          GoRoute(path: '/admin/super/team', builder: (c, s) => const SuperTeamScreen()),
          GoRoute(path: '/admin/super/roles', builder: (c, s) => const SuperRolesScreen()),
          GoRoute(path: '/admin/super/config', builder: (c, s) => const SuperConfigScreen()),
          GoRoute(path: '/admin/super/integrations', builder: (c, s) => const SuperIntegrationsScreen()),
          GoRoute(path: '/admin/super/security', builder: (c, s) => const SuperSecurityScreen()),
        ],
      ),
    ],
  );
}
