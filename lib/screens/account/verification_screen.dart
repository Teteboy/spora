import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import 'account_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum _VerifStage { identity, role, review, status }

enum _VerifStatus { pending, approved, refused }

/// /verification — badge Vérifié request.
/// Identité → Preuve de rôle → Soumission → Statuts.
class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  _VerifStage _stage = _VerifStage.identity;
  _VerifStatus _status = _VerifStatus.pending;
  bool _submitting = false;

  // Step 1 — identity
  late final TextEditingController _legalName;
  String? _docCountry;
  String? _rectoName;
  String? _versoName;

  // Step 2 — role proof
  String _role = 'Agent';
  late final TextEditingController _organisation;
  late final TextEditingController _reference;
  String? _proofName;

  // Step 3 — review
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _legalName = TextEditingController(text: auth.currentUser?.name ?? '');
    _organisation = TextEditingController();
    _reference = TextEditingController();
    _role = switch (auth.selectedUserType) {
      UserType.agent => 'Agent',
      UserType.recruiter => 'Club',
      _ => 'Joueur',
    };
  }

  @override
  void dispose() {
    _legalName.dispose();
    _organisation.dispose();
    _reference.dispose();
    super.dispose();
  }

  void _goTo(_VerifStage stage) =>
      setState(() => _stage = stage);

  void _back() {
    switch (_stage) {
      case _VerifStage.identity:
        accountBack(context);
      case _VerifStage.role:
        _goTo(_VerifStage.identity);
      case _VerifStage.review:
        _goTo(_VerifStage.role);
      case _VerifStage.status:
        accountBack(context);
    }
  }

  String _fakeDoc(String tag) => 'document_$tag.jpg';

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _status = _VerifStatus.pending;
      _stage = _VerifStage.status;
    });
    showAccountSnack(context, 'Votre demande de vérification a été envoyée.');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: KeyedSubtree(key: ValueKey(_stage), child: _buildStage()),
    );
  }

  Widget _buildStage() {
    switch (_stage) {
      case _VerifStage.identity:
        return _buildIdentity();
      case _VerifStage.role:
        return _buildRole();
      case _VerifStage.review:
        return _buildReview();
      case _VerifStage.status:
        return _buildStatus();
    }
  }

  // ── Étape 1 sur 3 — Identité ──────────────────────────────────────────────

  Widget _buildIdentity() {
    final p = AccountPalette.of(context);
    final valid = _legalName.text.trim().isNotEmpty &&
        _docCountry != null &&
        _rectoName != null &&
        _versoName != null;
    return AccountScaffold(
      title: 'Vérification',
      onBack: _back,
      bottom: GradientButton(
        label: 'Continuer',
        onPressed: valid ? () => _goTo(_VerifStage.role) : null,
      ),
      children: [
        const PageHeading(
          'Confirmez votre identité',
          eyebrow: 'Étape 1 sur 3',
          subtitle:
              'Les documents sont examinés par l’administration SPORA. Ils ne sont pas affichés sur votre profil.',
        ),
        LabeledField(
          label: 'Nom légal complet',
          hint: 'Nadia Mensah',
          controller: _legalName,
          onChanged: (_) => setState(() {}),
        ),
        LabeledField(
          label: 'Pays du document',
          hint: 'Côte d’Ivoire',
          controller: TextEditingController(text: _docCountry),
          readOnly: true,
          onTap: () async {
            final v = await _pickDocCountry();
            if (v != null) setState(() => _docCountry = v);
          },
          trailing: Icon(LucideIcons.chevronDown, color: p.text3),
        ),
        UploadCard(
          title: 'Pièce d’identité · Recto',
          hint: 'Document complet, net et non expiré',
          fileName: _rectoName,
          onAdd: () => setState(() => _rectoName = _fakeDoc('recto')),
          onRemove: () => setState(() => _rectoName = null),
        ),
        UploadCard(
          title: 'Pièce d’identité · Verso',
          hint: 'Document complet, net et non expiré',
          fileName: _versoName,
          onAdd: () => setState(() => _versoName = _fakeDoc('verso')),
          onRemove: () => setState(() => _versoName = null),
        ),
        const InfoBanner(
          title: 'Vérification indépendante de Premium',
          body: 'L’abonnement n’accorde pas le badge d’identité vérifiée.',
          boldBody: true,
        ),
      ],
    );
  }

  Future<String?> _pickDocCountry() {
    const countries = [
      'Cameroun', 'Côte d’Ivoire', 'Sénégal', 'France', 'Nigeria',
      'Ghana', 'Mali', 'Maroc', 'Autre',
    ];
    final p = AccountPalette.of(context);
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: p.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppDimens.radiusSheet)),
      ),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text('Pays du document', style: AppTextStyles.h2()),
            ),
            for (final c in countries)
              ListTile(
                title: Text(c, style: AppTextStyles.bodyLarge(color: p.text)),
                trailing:
                    c == _docCountry ? const Icon(LucideIcons.check, color: AppColors.primary) : null,
                onTap: () => Navigator.of(ctx).pop(c),
              ),
          ],
        ),
      ),
    );
  }

  // ── Étape 2 sur 3 — Preuve de rôle ────────────────────────────────────────

  Widget _buildRole() {
    final p = AccountPalette.of(context);
    final valid = _organisation.text.trim().isNotEmpty && _proofName != null;
    return AccountScaffold(
      title: 'Vérification',
      onBack: _back,
      bottom: GradientButton(
        label: 'Continuer',
        onPressed: valid ? () => _goTo(_VerifStage.review) : null,
      ),
      children: [
        const PageHeading('Justifiez votre rôle', eyebrow: 'Étape 2 sur 3'),
        Wrap(
          spacing: 10,
          children: [
            for (final r in const ['Agent', 'Club', 'Joueur'])
              ChoicePill(
                label: r,
                selected: _role == r,
                onTap: () => setState(() => _role = r),
              ),
          ],
        ),
        const SizedBox(height: AppDimens.lg),
        LabeledField(
          label: 'Organisation',
          hint: 'Horizon Talent',
          controller: _organisation,
          onChanged: (_) => setState(() {}),
        ),
        LabeledField(
          label: 'Référence professionnelle',
          hint: 'Numéro de licence · Facultatif',
          controller: _reference,
        ),
        UploadCard(
          title: 'Licence ou preuve d’appartenance',
          hint: 'Document complet, net et non expiré',
          fileName: _proofName,
          onAdd: () => setState(() => _proofName = _fakeDoc('licence')),
          onRemove: () => setState(() => _proofName = null),
        ),
        Text(
          'Le type de justificatif et les règles de conservation restent à valider avec l’équipe juridique.',
          style: AppTextStyles.body(color: p.text2),
        ),
      ],
    );
  }

  // ── Étape 3 sur 3 — Soumission ────────────────────────────────────────────

  Widget _buildReview() {
    final p = AccountPalette.of(context);
    return AccountScaffold(
      title: 'Vérification',
      onBack: _back,
      bottom: GradientButton(
        label: 'Envoyer ma demande',
        loading: _submitting,
        onPressed: _confirmed ? _submit : null,
      ),
      children: [
        const PageHeading('Vérifiez votre demande', eyebrow: 'Étape 3 sur 3'),
        AccountCard(
          child: Column(
            children: [
              _ReviewRow(
                title: 'Identité',
                subtitle:
                    '${_legalName.text.trim()} · Pièces jointes ajoutées',
              ),
              const SizedBox(height: AppDimens.lg),
              _ReviewRow(
                title: 'Preuve de rôle',
                subtitle: '$_role · ${_organisation.text.trim()}',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.md),
        InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          onTap: () => setState(() => _confirmed = !_confirmed),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: Checkbox(
                    value: _confirmed,
                    activeColor: AppColors.primary,
                    onChanged: (v) =>
                        setState(() => _confirmed = v ?? false),
                  ),
                ),
                const SizedBox(width: AppDimens.sm),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Je confirme que les documents me concernent et que les informations sont exactes.',
                      style: AppTextStyles.body(color: p.text),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimens.lg),
        const InfoBanner(
          title: 'Examen par l’équipe SPORA',
          body: 'Le badge sera accordé seulement après validation. '
              'Aucun délai d’approbation garanti.',
          boldBody: true,
        ),
      ],
    );
  }

  // ── Suivi — Statuts de vérification ───────────────────────────────────────

  Widget _buildStatus() {
    final p = AccountPalette.of(context);
    Widget card(_VerifStatus s, String pill, Color color, String title,
        String body, {Widget? action}) {
      final active = _status == s;
      return Padding(
        padding: const EdgeInsets.only(bottom: AppDimens.md),
        child: AccountCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StatusPill(label: pill, color: color),
                  const Spacer(),
                  if (active)
                    Text('Votre statut',
                        style: AppTextStyles.caption(color: p.text3)),
                ],
              ),
              const SizedBox(height: AppDimens.md),
              Text(title, style: AppTextStyles.h3(color: p.text)),
              const SizedBox(height: AppDimens.xs),
              Text(body, style: AppTextStyles.body(color: p.text2)),
              if (action != null) ...[
                const SizedBox(height: AppDimens.md),
                action,
              ],
            ],
          ),
        ),
      );
    }

    return AccountScaffold(
      title: 'Vérification',
      onBack: _back,
      children: [
        const PageHeading(
          'Statuts de vérification',
          eyebrow: 'Suivi de la demande',
          subtitle: 'Trois états possibles de votre demande.',
        ),
        card(
          _VerifStatus.pending,
          'En attente',
          AppColors.primary,
          'Documents reçus',
          'Votre dossier est en cours d’examen.',
        ),
        card(
          _VerifStatus.approved,
          'Approuvée',
          AppColors.clubGreen,
          'Identité et rôle validés',
          'Votre badge bleu est visible sur votre profil.',
        ),
        card(
          _VerifStatus.refused,
          'Refusée',
          AppColors.errorText,
          'Document illisible',
          'Le nom n’est pas lisible. Ajoutez une photo nette du document complet.',
          action: SecondaryButton(
            label: 'Renvoyer un justificatif',
            height: 48,
            onPressed: () => _goTo(_VerifStage.identity),
          ),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(LucideIcons.checkCircle,
            color: AppColors.primary, size: 24),
        const SizedBox(width: AppDimens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyLarge(color: p.text)),
              Text(subtitle, style: AppTextStyles.body(color: p.text)),
            ],
          ),
        ),
      ],
    );
  }
}
