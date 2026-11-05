import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import 'agent_onboarding_screen.dart';
import 'club_onboarding_screen.dart';
import 'onboarding_draft.dart';
import 'onboarding_widgets.dart';
import 'steps/guardian_consent_step.dart';
import 'steps/profile_ready_step.dart';
import 'steps/step1_general_info.dart';
import 'steps/step2_football_info.dart';
import 'steps/step3_highlights.dart';

export 'agent_onboarding_screen.dart' show AgentOnboardingScreen;
export 'club_onboarding_screen.dart' show ClubOnboardingScreen;

/// Role-aware onboarding entry point.
///
/// Routes: `/onboarding/player` → `OnboardingScreen(role: UserType.player)`
/// (or `PlayerOnboardingScreen`), `/onboarding/agent` → `AgentOnboardingScreen`,
/// `/onboarding/club` → `ClubOnboardingScreen`. Without [role] it dispatches on
/// `AuthProvider.selectedUserType`.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, this.role});

  final UserType? role;

  @override
  Widget build(BuildContext context) {
    final type = role ?? context.read<AuthProvider>().selectedUserType;
    switch (type) {
      case UserType.agent:
        return const AgentOnboardingScreen();
      case UserType.recruiter:
        return const ClubOnboardingScreen();
      case UserType.player:
      case UserType.guest:
        return const PlayerOnboardingScreen();
    }
  }
}

/// Player onboarding: 3 steps (+ guardian sub-step for minors) → Profil prêt.
class PlayerOnboardingScreen extends StatefulWidget {
  const PlayerOnboardingScreen({super.key});

  @override
  State<PlayerOnboardingScreen> createState() => _PlayerOnboardingScreenState();
}

class _PlayerOnboardingScreenState extends State<PlayerOnboardingScreen> {
  PlayerDraft _draft = PlayerDraft();
  bool _restoring = true;
  bool _emailLocked = false;
  bool _finishing = false;
  bool _finished = false;
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final saved = await OnboardingStore.load(OnboardingStore.playerKey);
    if (!mounted) return;
    final user = context.read<AuthProvider>().currentUser;
    setState(() {
      if (saved != null) _draft = PlayerDraft.fromJson(saved);
      if (user != null && user.email.isNotEmpty) {
        _draft.email = user.email;
        _emailLocked = true;
        if (_draft.firstName.isEmpty && _draft.lastName.isEmpty) {
          final parts = user.name.trim().split(RegExp(r'\s+'));
          if (parts.isNotEmpty && parts.first.isNotEmpty) {
            _draft.firstName = parts.first;
            _draft.lastName = parts.skip(1).join(' ');
          }
        }
      }
      _restoring = false;
    });
    if (saved != null && _draft.stage != PlayerStage.general) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showOnbSnack(context, 'Nous avons repris votre profil là où vous l’aviez laissé.');
      });
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    if (!_finished) OnboardingStore.save(OnboardingStore.playerKey, _draft.toJson());
    super.dispose();
  }

  void _changed() {
    setState(() {});
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 400), _saveNow);
  }

  void _saveNow() {
    if (_finished) return;
    OnboardingStore.save(OnboardingStore.playerKey, _draft.toJson());
  }

  void _goTo(PlayerStage stage) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _draft.stage = stage);
    _saveTimer?.cancel();
    _saveNow();
  }

  void _back() {
    switch (_draft.stage) {
      case PlayerStage.general:
        _saveNow();
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/register');
        }
      case PlayerStage.guardian:
        _goTo(PlayerStage.general);
      case PlayerStage.guardianPending:
        _goTo(PlayerStage.guardian);
      case PlayerStage.football:
        _goTo(_draft.isMinor ? PlayerStage.guardianPending : PlayerStage.general);
      case PlayerStage.highlights:
        _goTo(PlayerStage.football);
      case PlayerStage.ready:
        _goTo(PlayerStage.highlights);
    }
  }

  Future<void> _finish(String route) async {
    if (_finishing) return;
    setState(() => _finishing = true);
    final router = GoRouter.of(context);
    final auth = context.read<AuthProvider>();
    _finished = true;
    _saveTimer?.cancel();
    await OnboardingStore.clear(OnboardingStore.playerKey);
    if (!auth.isAuthenticated) {
      await auth.register(
        name: _draft.fullName.isEmpty ? 'Nouveau joueur' : _draft.fullName,
        email: _draft.email.isEmpty ? 'player@spora.com' : _draft.email,
        password: '',
        role: UserRole.player,
      );
    }
    router.go(route);
  }

  Widget _buildStage() {
    final d = _draft;
    switch (d.stage) {
      case PlayerStage.general:
        return Step1GeneralInfo(
          draft: d,
          emailLocked: _emailLocked,
          onChanged: _changed,
          onBack: _back,
          onContinue: () => _goTo(d.isMinor ? PlayerStage.guardian : PlayerStage.football),
        );
      case PlayerStage.guardian:
        return GuardianConsentStep(
          draft: d,
          onChanged: _changed,
          onBack: _back,
          onSubmit: () {
            d.guardianRequestedAt = DateTime.now();
            _goTo(PlayerStage.guardianPending);
          },
        );
      case PlayerStage.guardianPending:
        return GuardianPendingStep(
          draft: d,
          onBack: _back,
          onEdit: () => _goTo(PlayerStage.guardian),
          onResend: () {
            d.guardianRequestedAt = DateTime.now();
            _changed();
            showOnbSnack(context, 'Demande renvoyée à votre tuteur.');
          },
          onContinue: () => _goTo(PlayerStage.football),
        );
      case PlayerStage.football:
        return Step2FootballInfo(
          draft: d,
          onChanged: _changed,
          onBack: _back,
          onContinue: () => _goTo(PlayerStage.highlights),
        );
      case PlayerStage.highlights:
        return Step3Highlights(
          draft: d,
          onChanged: _changed,
          onBack: _back,
          onContinue: () => _goTo(PlayerStage.ready),
        );
      case PlayerStage.ready:
        return ProfileReadyStep(
          draft: d,
          loading: _finishing,
          onBack: _back,
          onExplore: () => _finish('/home'),
          onViewProfile: () => _finish('/profile'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_restoring) {
      return const Scaffold(
        backgroundColor: AppColors.appBg,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    return PopScope(
      canPop: _draft.stage == PlayerStage.general,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_finishing) _back();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: KeyedSubtree(key: ValueKey(_draft.stage), child: _buildStage()),
      ),
    );
  }
}
