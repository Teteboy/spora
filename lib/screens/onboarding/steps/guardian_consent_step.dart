import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../onboarding_draft.dart';
import '../onboarding_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Sub-step of étape 1 for players under 18 — "Consentement du tuteur".
class GuardianConsentStep extends StatefulWidget {
  const GuardianConsentStep({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.onBack,
    required this.onSubmit,
  });

  final PlayerDraft draft;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  @override
  State<GuardianConsentStep> createState() => _GuardianConsentStepState();
}

class _GuardianConsentStepState extends State<GuardianConsentStep> {
  late final TextEditingController _name = TextEditingController(text: widget.draft.guardianName);
  late final TextEditingController _phone = TextEditingController(text: widget.draft.guardianPhone);
  late final TextEditingController _email = TextEditingController(text: widget.draft.guardianEmail);
  bool _submitted = false;

  PlayerDraft get d => widget.draft;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  String? get _nameError =>
      _submitted && d.guardianName.trim().isEmpty ? 'Indiquez le nom du représentant légal' : null;
  String? get _relationError =>
      _submitted && d.guardianRelation == null ? 'Précisez le lien avec le joueur' : null;
  String? get _phoneError {
    if (!_submitted) return null;
    final digits = d.guardianPhone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 'Indiquez le téléphone du tuteur';
    if (digits.length < 8) return 'Numéro de téléphone incomplet';
    return null;
  }

  String? get _emailError {
    if (d.guardianEmail.trim().isEmpty) return null;
    if (!_submitted) return null;
    return isValidEmail(d.guardianEmail) ? null : 'Adresse e-mail invalide';
  }

  String? get _consentError =>
      _submitted && !d.guardianConsent ? 'Cochez la case pour envoyer la demande' : null;

  bool get _valid =>
      d.guardianName.trim().isNotEmpty &&
      d.guardianRelation != null &&
      d.guardianPhone.replaceAll(RegExp(r'\D'), '').length >= 8 &&
      (d.guardianEmail.trim().isEmpty || isValidEmail(d.guardianEmail)) &&
      d.guardianConsent;

  Future<void> _pickRelation() async {
    FocusScope.of(context).unfocus();
    final v = await showOnbOptionsSheet(context,
        title: 'Lien avec le joueur', options: kGuardianRelations, selected: d.guardianRelation);
    if (v == null || !mounted) return;
    setState(() => d.guardianRelation = v);
    widget.onChanged();
  }

  void _continue() {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    if (_valid) {
      widget.onSubmit();
    } else {
      showOnbSnack(context, 'Les informations du tuteur sont requises pour continuer.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnbScaffold(
      title: 'Consentement du tuteur',
      eyebrow: 'Étape 1 sur 3',
      progress: 1 / 3,
      onBack: widget.onBack,
      bottom: OnbPrimaryButton(label: 'Continuer', onPressed: _continue),
      children: [
        const OnbBanner(
          title: 'Protégeons les jeunes joueurs',
          message: 'Pour protéger les jeunes joueurs, vos coordonnées restent masquées '
              'jusqu’à validation de votre tuteur.',
        ),
        const SizedBox(height: 16),
        OnbField(
          label: 'Nom du représentant légal',
          hint: 'Nom et prénom',
          controller: _name,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.name],
          errorText: _nameError,
          onChanged: (v) {
            d.guardianName = v;
            widget.onChanged();
          },
        ),
        const SizedBox(height: 16),
        OnbSelectBox(
          label: 'Lien avec le joueur',
          hint: 'Parent ou représentant légal',
          value: d.guardianRelation,
          errorText: _relationError,
          onTap: _pickRelation,
        ),
        const SizedBox(height: 16),
        OnbField(
          label: 'Téléphone du tuteur',
          hint: 'Numéro de téléphone',
          prefixText: '${dialCodeFor(d.nationality)}   ',
          controller: _phone,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]'))],
          maxLength: 16,
          autofillHints: const [AutofillHints.telephoneNumberNational],
          errorText: _phoneError,
          onChanged: (v) {
            d.guardianPhone = v;
            widget.onChanged();
          },
        ),
        const SizedBox(height: 16),
        OnbField(
          label: 'Adresse e-mail du tuteur',
          hint: 'Adresse e-mail',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          errorText: _emailError,
          onChanged: (v) {
            d.guardianEmail = v.trim();
            widget.onChanged();
          },
        ),
        const SizedBox(height: 16),
        OnbCheckRow(
          value: d.guardianConsent,
          label: 'Je confirme être le représentant légal et autorise la demande de consentement.',
          errorText: _consentError,
          onChanged: (v) {
            setState(() => d.guardianConsent = v);
            widget.onChanged();
          },
        ),
        const SizedBox(height: 16),
        const OnbBanner(
          title: 'Profil non visible pour le moment',
          message: 'Le profil reste masqué jusqu’au consentement. Seuls les agents et clubs '
              'vérifiés pourront voir et contacter le joueur mineur.',
        ),
      ],
    );
  }
}

enum _PendingAction { edit, resend }

/// "Accord du tuteur" — request sent, waiting for the guardian.
class GuardianPendingStep extends StatelessWidget {
  const GuardianPendingStep({
    super.key,
    required this.draft,
    required this.onBack,
    required this.onEdit,
    required this.onResend,
    required this.onContinue,
  });

  final PlayerDraft draft;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onResend;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final sentAt = draft.guardianRequestedAt ?? DateTime.now();
    return OnbScaffold(
      title: 'Accord du tuteur',
      onBack: onBack,
      actions: [
        PopupMenuButton<_PendingAction>(
          tooltip: 'Plus d’options',
          icon: const Icon(LucideIcons.moreHorizontal, color: AppColors.textPrimary),
          color: AppColors.surface,
          onSelected: (a) => a == _PendingAction.edit ? onEdit() : onResend(),
          itemBuilder: (_) => [
            PopupMenuItem(
              value: _PendingAction.resend,
              child: Text('Renvoyer la demande',
                  style: AppTextStyles.body(color: AppColors.textPrimary)),
            ),
            PopupMenuItem(
              value: _PendingAction.edit,
              child: Text('Corriger les informations du tuteur',
                  style: AppTextStyles.body(color: AppColors.textPrimary)),
            ),
          ],
        ),
      ],
      bottom: OnbSecondaryButton(label: 'Revenir à mon profil', onPressed: onContinue),
      children: [
        const SizedBox(height: 8),
        const Icon(LucideIcons.shieldCheck, size: 72, color: AppColors.primary),
        const SizedBox(height: 12),
        Text('Profil masqué',
            style: AppTextStyles.bodyStrong(color: AppColors.textSecondary)),
        const SizedBox(height: 24),
        Semantics(
          header: true,
          child: Text('L’accord de votre tuteur est en attente.', style: AppTextStyles.display()),
        ),
        const SizedBox(height: 16),
        Text(
          'Votre profil ne figure pas dans la recherche tant que le consentement n’est pas enregistré.',
          style: AppTextStyles.bodyLarge(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        OnbCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Votre demande', style: AppTextStyles.h2()),
              const SizedBox(height: 16),
              Text('Demande envoyée le ${formatFrDateTime(sentAt)}',
                  style: AppTextStyles.bodyLarge(color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Text('Consentement v1.0 · En attente',
                  style: AppTextStyles.bodyLarge(color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Text('Les coordonnées du tuteur ne sont jamais affichées publiquement.',
                  style: AppTextStyles.body(color: AppColors.textMuted)),
              const SizedBox(height: 20),
              OnbPrimaryButton(label: 'Renvoyer la demande', onPressed: onResend),
              const SizedBox(height: 12),
              OnbSecondaryButton(label: 'Corriger les informations du tuteur', onPressed: onEdit),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const OnbBanner(
          icon: LucideIcons.info,
          title: 'Votre sécurité d’abord',
          message: 'Après accord, seuls les agents et clubs vérifiés pourront découvrir votre '
              'profil. Vos contacts et votre localisation exacte restent masqués.',
          boldMessage: false,
        ),
      ],
    );
  }
}
