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
import 'onboarding_draft.dart';
import 'onboarding_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum _AgentStage { welcome, agency, criteria, ready }

/// Agent onboarding — /onboarding/agent
/// Bienvenue → Votre agence → Critères de recherche → Votre agence est prête.
class AgentOnboardingScreen extends StatefulWidget {
  const AgentOnboardingScreen({super.key});

  @override
  State<AgentOnboardingScreen> createState() => _AgentOnboardingScreenState();
}

class _AgentOnboardingScreenState extends State<AgentOnboardingScreen> {
  _AgentStage _stage = _AgentStage.welcome;
  bool _restoring = true;
  bool _finishing = false;

  // Agency form
  String agencyName = '';
  String agentName = '';
  String proEmail = '';
  String? country;
  String licence = '';
  String website = '';
  Uint8List? logo;
  final SearchCriteria criteria = SearchCriteria();

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final saved = await OnboardingStore.load(OnboardingStore.agentKey);
    if (!mounted) return;
    setState(() {
      if (saved != null) {
        agencyName = saved['agencyName'] is String ? saved['agencyName'] as String : '';
        agentName = saved['agentName'] is String ? saved['agentName'] as String : '';
        proEmail = saved['proEmail'] is String ? saved['proEmail'] as String : '';
        country = saved['country'] is String ? saved['country'] as String : null;
        licence = saved['licence'] is String ? saved['licence'] as String : '';
        website = saved['website'] is String ? saved['website'] as String : '';
        logo = OnboardingStore.decodeImage(saved['logo']);
        final c = SearchCriteria.fromJson(saved['criteria']);
        criteria
          ..positions = c.positions
          ..ages = c.ages
          ..levels = c.levels
          ..regions = c.regions
          ..alerts = c.alerts;
      }
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        if (proEmail.isEmpty) proEmail = user.email;
        if (agentName.isEmpty) agentName = user.name;
      }
      _restoring = false;
    });
  }

  Map<String, dynamic> _toJson() => {
        'agencyName': agencyName,
        'agentName': agentName,
        'proEmail': proEmail,
        'country': country,
        'licence': licence,
        'website': website,
        'logo': OnboardingStore.encodeImage(logo),
        'criteria': criteria.toJson(),
      };

  void _save() => OnboardingStore.save(OnboardingStore.agentKey, _toJson());

  void _goTo(_AgentStage stage) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _stage = stage);
    _save();
  }

  void _back() {
    switch (_stage) {
      case _AgentStage.welcome:
        _save();
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/register');
        }
      case _AgentStage.agency:
        _goTo(_AgentStage.welcome);
      case _AgentStage.criteria:
        _goTo(_AgentStage.agency);
      case _AgentStage.ready:
        _goTo(_AgentStage.criteria);
    }
  }

  Future<void> _finish(String route) async {
    if (_finishing) return;
    setState(() => _finishing = true);
    final router = GoRouter.of(context);
    final auth = context.read<AuthProvider>();
    await criteria.saveAsFilters('agent');
    await OnboardingStore.clear(OnboardingStore.agentKey);
    if (!auth.isAuthenticated) {
      await auth.register(
        name: agentName.isEmpty ? 'Nouvel agent' : agentName,
        email: proEmail.isEmpty ? 'agent@spora.com' : proEmail,
        password: '',
        role: UserRole.agent,
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
      canPop: _stage == _AgentStage.welcome,
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
      case _AgentStage.welcome:
        return _AgentWelcome(onBack: _back, onStart: () => _goTo(_AgentStage.agency));
      case _AgentStage.agency:
        return _AgentAgencyStep(
          screen: this,
          onChanged: () => setState(_save),
          onBack: _back,
          onContinue: () => _goTo(_AgentStage.criteria),
        );
      case _AgentStage.criteria:
        return _AgentCriteriaStep(
          criteria: criteria,
          onChanged: () => setState(_save),
          onBack: _back,
          onContinue: () => _goTo(_AgentStage.ready),
        );
      case _AgentStage.ready:
        return _AgentReady(
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

class _AgentWelcome extends StatelessWidget {
  const _AgentWelcome({required this.onBack, required this.onStart});
  final VoidCallback onBack;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return OnbScaffold(
      title: 'Bienvenue',
      boxedBack: true,
      onBack: onBack,
      eyebrow: 'Bienvenue dans l’équipe',
      bottom: OnbPrimaryButton(
        label: 'Configurer mon agence',
        icon: LucideIcons.arrowRight,
        onPressed: onStart,
      ),
      children: [
        const SizedBox(height: 12),
        Text('Repérez les talents avant tout le monde.',
            style: AppTextStyles.display()),
        const SizedBox(height: 12),
        Text(
          'En deux étapes, décrivez votre agence puis vos critères de recherche. Vous pourrez tout ajuster depuis votre profil.',
          style: AppTextStyles.bodyLarge(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        const OnbCard(
          child: Column(children: [
            OnbInfoRow(
              icon: LucideIcons.building2,
              title: 'Votre agence',
              subtitle: 'Identité professionnelle et coordonnées.',
            ),
            Divider(height: 1, color: AppColors.divider),
            OnbInfoRow(
              icon: LucideIcons.searchCheck,
              title: 'Critères de recherche',
              subtitle: 'Postes, âge, niveaux et régions suivis.',
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
// Étape 1 sur 2 — Votre agence
// ---------------------------------------------------------------------------

class _AgentAgencyStep extends StatefulWidget {
  const _AgentAgencyStep({
    required this.screen,
    required this.onChanged,
    required this.onBack,
    required this.onContinue,
  });

  final _AgentOnboardingScreenState screen;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  State<_AgentAgencyStep> createState() => _AgentAgencyStepState();
}

class _AgentAgencyStepState extends State<_AgentAgencyStep> {
  late final TextEditingController _agency =
      TextEditingController(text: widget.screen.agencyName);
  late final TextEditingController _agent =
      TextEditingController(text: widget.screen.agentName);
  late final TextEditingController _email =
      TextEditingController(text: widget.screen.proEmail);
  late final TextEditingController _licence =
      TextEditingController(text: widget.screen.licence);
  late final TextEditingController _website =
      TextEditingController(text: widget.screen.website);
  bool _submitted = false;
  bool _processingLogo = false;

  _AgentOnboardingScreenState get s => widget.screen;

  @override
  void dispose() {
    _agency.dispose();
    _agent.dispose();
    _email.dispose();
    _licence.dispose();
    _website.dispose();
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

  String? get _websiteError {
    if (_website.text.trim().isEmpty) return null;
    if (!isValidUrl(_website.text)) return 'Adresse de site web invalide';
    return null;
  }

  bool get _valid =>
      _agency.text.trim().isNotEmpty &&
      _agent.text.trim().isNotEmpty &&
      isValidEmail(_email.text) &&
      s.country != null &&
      (_website.text.trim().isEmpty || isValidUrl(_website.text));

  Future<void> _pickCountry() async {
    FocusScope.of(context).unfocus();
    final v = await showOnbOptionsSheet(context,
        title: 'Pays', options: kCountries, selected: s.country);
    if (v == null || !mounted) return;
    _update(() => s.country = v);
  }

  Future<void> _pickLogo() async {
    final action = await showOnbChoiceSheet<String>(
      context,
      title: 'Logo de l’agence',
      choices: [
        const OnbChoice('gallery', 'Choisir dans la galerie',
            icon: LucideIcons.galleryHorizontal),
        const OnbChoice('camera', 'Prendre une photo',
            icon: LucideIcons.camera),
        if (s.logo != null)
          const OnbChoice('remove', 'Supprimer le logo',
              icon: LucideIcons.trash2, destructive: true),
      ],
    );
    if (action == null || !mounted) return;
    if (action == 'remove') {
      _update(() => s.logo = null);
      return;
    }
    setState(() => _processingLogo = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: action == 'camera' ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 90,
      );
      if (picked == null || !mounted) return;
      final bytes = await picked.readAsBytes();
      final cropped = await cropToSquare(bytes);
      if (!mounted) return;
      _update(() => s.logo = cropped);
    } catch (_) {
      if (mounted) showOnbSnack(context, 'Impossible de lire cette image.', error: true);
    } finally {
      if (mounted) setState(() => _processingLogo = false);
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
      title: 'Votre agence',
      boxedBack: true,
      onBack: widget.onBack,
      eyebrow: 'Étape 1 sur 2',
      trailingEyebrow: 'Identité professionnelle',
      progress: 1 / 3,
      bottom: OnbPrimaryButton(
        label: 'Continuer',
        icon: LucideIcons.arrowRight,
        onPressed: _continue,
      ),
      children: [
        OnbMediaPicker(
          icon: LucideIcons.building2,
          label: 'Ajouter le logo de l’agence',
          changeLabel: 'Changer le logo de l’agence',
          image: s.logo,
          onTap: _processingLogo ? () {} : _pickLogo,
        ),
        const SizedBox(height: 16),
        OnbField(
          label: 'Nom de l’agence *',
          hint: 'Horizon Talent',
          controller: _agency,
          textCapitalization: TextCapitalization.words,
          errorText: _required(_agency.text, 'Indiquez le nom de l’agence'),
          onChanged: (v) => _update(() => s.agencyName = v),
        ),
        const SizedBox(height: 16),
        OnbField(
          label: 'Agent responsable *',
          hint: 'Nadia Mensah',
          controller: _agent,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.name],
          errorText: _required(_agent.text, 'Indiquez l’agent responsable'),
          onChanged: (v) => _update(() => s.agentName = v),
        ),
        const SizedBox(height: 16),
        OnbField(
          label: 'E-mail professionnel *',
          hint: 'nadia@horizon.example',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          errorText: _emailError,
          onChanged: (v) => _update(() => s.proEmail = v),
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
          label: 'Numéro de licence · facultatif',
          hint: 'Votre numéro de licence',
          controller: _licence,
          onChanged: (v) => _update(() => s.licence = v),
        ),
        const SizedBox(height: 16),
        OnbField(
          label: 'Site web',
          hint: 'https://horizon.example',
          controller: _website,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.done,
          errorText: _websiteError,
          onChanged: (v) => _update(() => s.website = v),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Étape 2 sur 2 — Critères de recherche
// ---------------------------------------------------------------------------

class _AgentCriteriaStep extends StatelessWidget {
  const _AgentCriteriaStep({
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
      title: 'Critères de recherche',
      boxedBack: true,
      onBack: onBack,
      eyebrow: 'Étape 2 sur 2',
      trailingEyebrow: 'Votre radar à talents',
      progress: 1,
      bottom: OnbPrimaryButton(
        label: 'Continuer',
        icon: LucideIcons.arrowRight,
        onPressed: onContinue,
      ),
      children: [
        Text('Vos critères de recherche', style: AppTextStyles.display()),
        const SizedBox(height: 20),
        const OnbSectionLabel('Postes'),
        SearchCriteriaForm(criteria: criteria, onChanged: onChanged),
      ],
    );
  }
}

/// Shared criteria form (postes · âge · niveau · régions · alertes).
/// Also used by the club onboarding flow.
class SearchCriteriaForm extends StatefulWidget {
  const SearchCriteriaForm(
      {super.key, required this.criteria, required this.onChanged});

  final SearchCriteria criteria;
  final VoidCallback onChanged;

  @override
  State<SearchCriteriaForm> createState() => SearchCriteriaFormState();
}

class SearchCriteriaFormState extends State<SearchCriteriaForm> {
  SearchCriteria get c => widget.criteria;

  void _update(VoidCallback fn) {
    setState(fn);
    widget.onChanged();
  }

  Future<void> _pickAge() async {
    final v = await showOnbAgeRangeSheet(context,
        initial: c.ages,
        min: SearchCriteria.minAge,
        max: SearchCriteria.maxAge);
    if (v == null || !mounted) return;
    _update(() => c.ages = v);
  }

  Future<void> _pickLevels() async {
    final v = await showOnbMultiSelectSheet(context,
        title: 'Niveaux', options: kPlayerLevels, selected: c.levels);
    if (v == null || !mounted) return;
    _update(() => c.levels = v);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnbPillWrap(
          children: [
            for (final g in kPositionGroups)
              OnbPill(
                label: g.code,
                semanticLabel: g.label,
                selected: c.positions.contains(g.code),
                onTap: () => _update(() {
                  if (!c.positions.remove(g.code)) c.positions.add(g.code);
                }),
              ),
          ],
        ),
        const SizedBox(height: 20),
        OnbSelectBox(
          label: 'Tranche d’âge',
          value: c.ageLabel,
          icon: LucideIcons.chevronDown,
          onTap: _pickAge,
        ),
        const SizedBox(height: 20),
        OnbSelectBox(
          label: 'Niveau',
          value: c.levelsLabel,
          icon: LucideIcons.chevronDown,
          onTap: _pickLevels,
        ),
        const SizedBox(height: 20),
        OnbPillWrap(
          children: [
            for (final r in kRegions)
              OnbPill(
                label: r,
                selected: c.regions.contains(r),
                onTap: () => _update(() {
                  if (!c.regions.remove(r)) c.regions.add(r);
                }),
              ),
          ],
        ),
        const SizedBox(height: 20),
        OnbToggleRow(
          label: 'Recevoir des alertes pour les nouveaux talents',
          value: c.alerts,
          onChanged: (v) => _update(() => c.alerts = v),
        ),
        const SizedBox(height: 20),
        const OnbBanner(
          title: 'Vous gardez le contrôle',
          message: 'Ces critères pourront être ajustés depuis votre profil.',
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Bienvenue — done ("Votre agence est prête !")
// ---------------------------------------------------------------------------

class _AgentReady extends StatelessWidget {
  const _AgentReady({
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
      progress: 0.7,
      bottom: OnbPrimaryButton(
        label: 'Explorer SPORA',
        loading: loading,
        onPressed: onExplore,
      ),
      children: [
        const SizedBox(height: 12),
        const OnbDoneHeader(
          headline: 'Votre agence est prête !',
          subtitle: 'Faites le prochain pas, à votre rythme.',
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
