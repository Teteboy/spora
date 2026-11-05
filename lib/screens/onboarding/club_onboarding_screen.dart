import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import 'agent_onboarding_screen.dart' show SearchCriteriaForm;
import 'onboarding_draft.dart';
import 'onboarding_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum _ClubStage { welcome, identity, needs, ready }

/// Club onboarding — /onboarding/club (role recruteur).
/// Bienvenue → Identité du club → Besoins de recrutement → Votre club est prêt.
class ClubOnboardingScreen extends StatefulWidget {
  const ClubOnboardingScreen({super.key});

  @override
  State<ClubOnboardingScreen> createState() => _ClubOnboardingScreenState();
}

class _ClubOnboardingScreenState extends State<ClubOnboardingScreen> {
  _ClubStage _stage = _ClubStage.welcome;
  bool _restoring = true;
  bool _finishing = false;

  // Club identity
  String clubName = '';
  String? country;
  String city = '';
  String? division;
  String? recruiterRole;
  String proEmail = '';
  Uint8List? crest;
  final SearchCriteria criteria = SearchCriteria();

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final saved = await OnboardingStore.load(OnboardingStore.clubKey);
    if (!mounted) return;
    setState(() {
      if (saved != null) {
        clubName = saved['clubName'] is String ? saved['clubName'] as String : '';
        country = saved['country'] is String ? saved['country'] as String : null;
        city = saved['city'] is String ? saved['city'] as String : '';
        division =
            saved['division'] is String ? saved['division'] as String : null;
        recruiterRole = saved['recruiterRole'] is String
            ? saved['recruiterRole'] as String
            : null;
        proEmail = saved['proEmail'] is String ? saved['proEmail'] as String : '';
        crest = OnboardingStore.decodeImage(saved['crest']);
        final c = SearchCriteria.fromJson(saved['criteria']);
        criteria
          ..positions = c.positions
          ..ages = c.ages
          ..levels = c.levels
          ..regions = c.regions
          ..alerts = c.alerts;
      }
      final user = context.read<AuthProvider>().currentUser;
      if (user != null && proEmail.isEmpty) proEmail = user.email;
      _restoring = false;
    });
  }

  Map<String, dynamic> _toJson() => {
        'clubName': clubName,
        'country': country,
        'city': city,
        'division': division,
        'recruiterRole': recruiterRole,
        'proEmail': proEmail,
        'crest': OnboardingStore.encodeImage(crest),
        'criteria': criteria.toJson(),
      };

  void _save() => OnboardingStore.save(OnboardingStore.clubKey, _toJson());

  void _goTo(_ClubStage stage) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _stage = stage);
    _save();
  }

  void _back() {
    switch (_stage) {
      case _ClubStage.welcome:
        _save();
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/register');
        }
      case _ClubStage.identity:
        _goTo(_ClubStage.welcome);
      case _ClubStage.needs:
        _goTo(_ClubStage.identity);
      case _ClubStage.ready:
        _goTo(_ClubStage.needs);
    }
  }

  Future<void> _finish(String route) async {
    if (_finishing) return;
    setState(() => _finishing = true);
    final router = GoRouter.of(context);
    final auth = context.read<AuthProvider>();
    await criteria.saveAsFilters('club');
    await OnboardingStore.clear(OnboardingStore.clubKey);
    if (!auth.isAuthenticated) {
      await auth.register(
        name: clubName.isEmpty ? 'Nouveau club' : clubName,
        email: proEmail.isEmpty ? 'club@spora.com' : proEmail,
        password: '',
        role: UserRole.recruiter,
      );
    }
    router.go(route);
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
      canPop: _stage == _ClubStage.welcome,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_finishing) _back();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: KeyedSubtree(key: ValueKey(_stage), child: _buildStage()),
      ),
    );
  }

  Widget _buildStage() {
    switch (_stage) {
      case _ClubStage.welcome:
        return _ClubWelcome(
            onBack: _back, onStart: () => _goTo(_ClubStage.identity));
      case _ClubStage.identity:
        return _ClubIdentityStep(
          screen: this,
          onChanged: () => setState(_save),
          onBack: _back,
          onContinue: () => _goTo(_ClubStage.needs),
        );
      case _ClubStage.needs:
        return _ClubNeedsStep(
          criteria: criteria,
          onChanged: () => setState(_save),
          onBack: _back,
          onContinue: () => _goTo(_ClubStage.ready),
        );
      case _ClubStage.ready:
        return _ClubReady(
          loading: _finishing,
          onBack: _back,
          onExplore: () => _finish('/home'),
          onVerification: () => _finish('/verification'),
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Bienvenue — intro
// ---------------------------------------------------------------------------

class _ClubWelcome extends StatelessWidget {
  const _ClubWelcome({required this.onBack, required this.onStart});
  final VoidCallback onBack;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return OnbScaffold(
      title: 'Bienvenue',
      boxedBack: true,
      onBack: onBack,
      eyebrow: 'Bienvenue dans l’équipe',
      eyebrowColor: AppColors.clubGreen,
      bottom: OnbPrimaryButton(
        label: 'Présenter mon club',
        icon: LucideIcons.arrowRight,
        onPressed: onStart,
      ),
      children: [
        const SizedBox(height: 12),
        Text('Trouvez les profils qui renforcent votre effectif.',
            style: AppTextStyles.display()),
        const SizedBox(height: 12),
        Text(
          'En deux étapes, présentez votre club puis vos besoins de recrutement. Vous pourrez tout ajuster depuis votre profil.',
          style: AppTextStyles.bodyLarge(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        const OnbCard(
          child: Column(children: [
            OnbInfoRow(
              icon: LucideIcons.shield,
              title: 'Identité du club',
              subtitle: 'Emblème, pays, ville et division.',
            ),
            Divider(height: 1, color: AppColors.divider),
            OnbInfoRow(
              icon: LucideIcons.searchCheck,
              title: 'Besoins de recrutement',
              subtitle: 'Postes, âge, niveaux et régions ciblés.',
            ),
            Divider(height: 1, color: AppColors.divider),
            OnbInfoRow(
              icon: LucideIcons.badgeCheck,
              title: 'Badge Vérifié',
              subtitle: 'Accordé par l’équipe SPORA après examen.',
            ),
          ]),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Étape 1 sur 2 — Identité du club
// ---------------------------------------------------------------------------

class _ClubIdentityStep extends StatefulWidget {
  const _ClubIdentityStep({
    required this.screen,
    required this.onChanged,
    required this.onBack,
    required this.onContinue,
  });

  final _ClubOnboardingScreenState screen;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  State<_ClubIdentityStep> createState() => _ClubIdentityStepState();
}

class _ClubIdentityStepState extends State<_ClubIdentityStep> {
  late final TextEditingController _club =
      TextEditingController(text: widget.screen.clubName);
  late final TextEditingController _city =
      TextEditingController(text: widget.screen.city);
  late final TextEditingController _email =
      TextEditingController(text: widget.screen.proEmail);
  bool _submitted = false;
  bool _processingCrest = false;

  _ClubOnboardingScreenState get s => widget.screen;

  @override
  void dispose() {
    _club.dispose();
    _city.dispose();
    _email.dispose();
    super.dispose();
  }

  void _update(VoidCallback fn) {
    setState(fn);
    widget.onChanged();
  }

  String? _required(String v, String msg) =>
      _submitted && v.trim().isEmpty ? msg : null;

  String? get _emailError {
    if (!_submitted) return null;
    if (_email.text.trim().isEmpty) return 'Indiquez votre e-mail professionnel';
    if (!isValidEmail(_email.text)) return 'Adresse e-mail invalide';
    return null;
  }

  bool get _valid =>
      _club.text.trim().isNotEmpty &&
      s.country != null &&
      _city.text.trim().isNotEmpty &&
      s.division != null &&
      s.recruiterRole != null &&
      isValidEmail(_email.text);

  Future<void> _pickCountry() async {
    FocusScope.of(context).unfocus();
    final v = await showOnbOptionsSheet(context,
        title: 'Pays', options: kCountries, selected: s.country);
    if (v == null || !mounted) return;
    _update(() => s.country = v);
  }

  Future<void> _pickDivision() async {
    FocusScope.of(context).unfocus();
    final v = await showOnbOptionsSheet(context,
        title: 'Division ou niveau',
        options: kClubDivisions,
        selected: s.division);
    if (v == null || !mounted) return;
    _update(() => s.division = v);
  }

  Future<void> _pickRole() async {
    FocusScope.of(context).unfocus();
    final v = await showOnbOptionsSheet(context,
        title: 'Rôle du recruteur',
        options: kRecruiterRoles,
        selected: s.recruiterRole);
    if (v == null || !mounted) return;
    _update(() => s.recruiterRole = v);
  }

  Future<void> _pickCrest() async {
    final action = await showOnbChoiceSheet<String>(
      context,
      title: 'Emblème du club',
      choices: [
        const OnbChoice('gallery', 'Choisir dans la galerie',
            icon: LucideIcons.galleryHorizontal),
        const OnbChoice('camera', 'Prendre une photo',
            icon: LucideIcons.camera),
        if (s.crest != null)
          const OnbChoice('remove', 'Supprimer l’emblème',
              icon: LucideIcons.trash2, destructive: true),
      ],
    );
    if (action == null || !mounted) return;
    if (action == 'remove') {
      _update(() => s.crest = null);
      return;
    }
    setState(() => _processingCrest = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: action == 'camera' ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 90,
      );
      if (picked == null || !mounted) return;
      final bytes = await picked.readAsBytes();
      if (bytes.lengthInBytes > 2 * 1024 * 1024) {
        if (mounted) {
          showOnbSnack(context, 'Image trop lourde : 2 Mo maximum.',
              error: true);
        }
        return;
      }
      final cropped = await cropToSquare(bytes);
      if (!mounted) return;
      _update(() => s.crest = cropped);
    } catch (_) {
      if (mounted) {
        showOnbSnack(context, 'Impossible de lire cette image.', error: true);
      }
    } finally {
      if (mounted) setState(() => _processingCrest = false);
    }
  }

  void _continue() {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    if (_valid) {
      widget.onContinue();
    } else {
      showOnbSnack(context, 'Complétez les champs obligatoires pour continuer.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnbScaffold(
      title: 'Identité du club',
      boxedBack: true,
      onBack: widget.onBack,
      eyebrow: 'Étape 1 sur 2',
      eyebrowColor: AppColors.clubGreen,
      trailingEyebrow: 'Votre structure',
      progress: 1 / 3,
      bottom: OnbPrimaryButton(
        label: 'Continuer',
        icon: LucideIcons.arrowRight,
        onPressed: _continue,
      ),
      children: [
        OnbMediaPicker(
          icon: LucideIcons.shield,
          label: 'Ajouter l’emblème du club',
          changeLabel: 'Changer l’emblème du club',
          image: s.crest,
          linkColor: AppColors.clubGreen,
          helper: 'Emblème officiel · 2 Mo maximum',
          onTap: _processingCrest ? () {} : _pickCrest,
        ),
        const SizedBox(height: 16),
        OnbField(
          label: 'Nom du club *',
          hint: 'Académie des Rives',
          controller: _club,
          textCapitalization: TextCapitalization.words,
          errorText: _required(_club.text, 'Indiquez le nom du club'),
          onChanged: (v) => _update(() => s.clubName = v),
        ),
        const SizedBox(height: 16),
        OnbSelectBox(
          label: 'Pays *',
          hint: 'Choisir un pays',
          value: s.country,
          errorText:
              _submitted && s.country == null ? 'Choisissez un pays' : null,
          onTap: _pickCountry,
        ),
        const SizedBox(height: 16),
        OnbField(
          label: 'Ville *',
          hint: 'Douala',
          controller: _city,
          textCapitalization: TextCapitalization.words,
          errorText: _required(_city.text, 'Indiquez la ville'),
          onChanged: (v) => _update(() => s.city = v),
        ),
        const SizedBox(height: 16),
        OnbSelectBox(
          label: 'Division ou niveau *',
          hint: 'Choisir une division',
          value: s.division,
          errorText:
              _submitted && s.division == null ? 'Choisissez une division' : null,
          onTap: _pickDivision,
        ),
        const SizedBox(height: 16),
        OnbSelectBox(
          label: 'Rôle du recruteur *',
          hint: 'Votre fonction dans le club',
          value: s.recruiterRole,
          errorText: _submitted && s.recruiterRole == null
              ? 'Choisissez votre rôle'
              : null,
          onTap: _pickRole,
        ),
        const SizedBox(height: 16),
        OnbField(
          label: 'E-mail professionnel *',
          hint: 'recrutement@rives.example',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.done,
          errorText: _emailError,
          onChanged: (v) => _update(() => s.proEmail = v),
        ),
        const SizedBox(height: 20),
        const OnbBanner(
          title: 'Identité de démonstration',
          message: 'Académie fictive, sans lien avec un recrutement réel.',
          tone: OnbTone.success,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Étape 2 sur 2 — Besoins de recrutement
// ---------------------------------------------------------------------------

class _ClubNeedsStep extends StatelessWidget {
  const _ClubNeedsStep({
    required this.criteria,
    required this.onChanged,
    required this.onBack,
    required this.onContinue,
  });

  final SearchCriteria criteria;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return OnbScaffold(
      title: 'Besoins de recrutement',
      boxedBack: true,
      onBack: onBack,
      eyebrow: 'Étape 2 sur 2',
      eyebrowColor: AppColors.clubGreen,
      trailingEyebrow: 'Votre effectif idéal',
      progress: 1,
      bottom: OnbPrimaryButton(
        label: 'Continuer',
        icon: LucideIcons.arrowRight,
        onPressed: onContinue,
      ),
      children: [
        Text('Quels talents recherchez-vous ?', style: AppTextStyles.display()),
        const SizedBox(height: 20),
        const OnbSectionLabel('Postes'),
        SearchCriteriaForm(criteria: criteria, onChanged: onChanged),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Bienvenue — done ("Votre club est prêt !")
// ---------------------------------------------------------------------------

class _ClubReady extends StatelessWidget {
  const _ClubReady({
    required this.loading,
    required this.onBack,
    required this.onExplore,
    required this.onVerification,
  });

  final bool loading;
  final VoidCallback onBack;
  final VoidCallback onExplore;
  final VoidCallback onVerification;

  @override
  Widget build(BuildContext context) {
    return OnbScaffold(
      title: 'Bienvenue',
      boxedBack: true,
      onBack: onBack,
      eyebrow: 'Bienvenue dans l’équipe',
      eyebrowColor: AppColors.clubGreen,
      progress: 0.7,
      bottom: OnbPrimaryButton(
        label: 'Explorer SPORA',
        loading: loading,
        onPressed: onExplore,
      ),
      children: [
        const SizedBox(height: 12),
        const OnbDoneHeader(
          headline: 'Votre club est prêt !',
          subtitle: 'Faites le prochain pas, à votre rythme.',
          color: AppColors.clubGreen,
        ),
        const SizedBox(height: 24),
        OnbCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.badgeCheck,
                      color: AppColors.primary, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Demander la vérification\nL’équipe SPORA examine votre identité et votre rôle. Le badge bleu est indépendant de Premium.',
                      style: AppTextStyles.bodyLarge(
                          color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OnbPrimaryButton(
                label: 'Demander la vérification',
                solidColor: AppColors.clubGreen,
                onPressed: onVerification,
              ),
              const SizedBox(height: 8),
              OnbTextButton(label: 'Plus tard', onPressed: onExplore),
            ],
          ),
        ),
      ],
    );
  }
}
