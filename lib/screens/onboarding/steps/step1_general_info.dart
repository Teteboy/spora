import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../onboarding_draft.dart';
import '../onboarding_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum _PhotoAction { gallery, camera, remove }

/// Étape 1 — Informations générales.
class Step1GeneralInfo extends StatefulWidget {
  const Step1GeneralInfo({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.onBack,
    required this.onContinue,
    this.emailLocked = false,
  });

  final PlayerDraft draft;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  /// E-mail comes from the account and is read-only (Figma muted field).
  final bool emailLocked;

  @override
  State<Step1GeneralInfo> createState() => _Step1GeneralInfoState();
}

class _Step1GeneralInfoState extends State<Step1GeneralInfo> {
  late final TextEditingController _first = TextEditingController(text: widget.draft.firstName);
  late final TextEditingController _last = TextEditingController(text: widget.draft.lastName);
  late final TextEditingController _city = TextEditingController(text: widget.draft.city);
  late final TextEditingController _email = TextEditingController(text: widget.draft.email);
  bool _submitted = false;
  bool _processingPhoto = false;

  PlayerDraft get d => widget.draft;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _city.dispose();
    _email.dispose();
    super.dispose();
  }

  String? _required(String v, String msg) => _submitted && v.trim().isEmpty ? msg : null;

  String? get _dobError {
    if (!_submitted && d.birthDate == null) return null;
    if (d.birthDate == null) return 'Indiquez votre date de naissance';
    final age = d.age ?? 0;
    if (age < 13) return 'Vous devez avoir au moins 13 ans pour créer un profil';
    return null;
  }

  String? get _emailError {
    if (!_submitted) return null;
    if (d.email.trim().isEmpty) return 'Indiquez votre adresse e-mail';
    if (!isValidEmail(d.email)) return 'Adresse e-mail invalide';
    return null;
  }

  bool get _valid => d.generalComplete && (d.age ?? 0) >= 13;

  Future<void> _pickPhoto() async {
    final action = await showOnbChoiceSheet<_PhotoAction>(
      context,
      title: 'Photo de profil',
      choices: [
        const OnbChoice(_PhotoAction.gallery, 'Choisir dans la galerie', icon: LucideIcons.galleryHorizontal),
        const OnbChoice(_PhotoAction.camera, 'Prendre une photo', icon: LucideIcons.camera),
        if (d.photo != null)
          const OnbChoice(_PhotoAction.remove, 'Supprimer la photo',
              icon: LucideIcons.trash2, destructive: true),
      ],
    );
    if (action == null || !mounted) return;
    if (action == _PhotoAction.remove) {
      setState(() => d.photo = null);
      widget.onChanged();
      return;
    }
    try {
      final file = await ImagePicker().pickImage(
        source: action == _PhotoAction.camera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.front,
      );
      if (file == null || !mounted) return;
      setState(() => _processingPhoto = true);
      final bytes = await file.readAsBytes();
      final square = await cropToSquare(bytes);
      if (!mounted) return;
      setState(() {
        d.photo = square;
        _processingPhoto = false;
      });
      widget.onChanged();
    } catch (_) {
      if (!mounted) return;
      setState(() => _processingPhoto = false);
      showOnbSnack(context, 'Impossible d’ajouter la photo. Réessayez.', error: true);
    }
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: d.birthDate ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(now.year - 60),
      lastDate: now,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: 'Date de naissance',
      cancelText: 'Annuler',
      confirmText: 'Valider',
    );
    if (picked == null || !mounted) return;
    setState(() => d.birthDate = picked);
    widget.onChanged();
  }

  Future<void> _pickNationality() async {
    FocusScope.of(context).unfocus();
    final v = await showOnbOptionsSheet(context,
        title: 'Nationalité', options: kCountries, selected: d.nationality);
    if (v == null || !mounted) return;
    setState(() => d.nationality = v);
    widget.onChanged();
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
      title: 'Informations générales',
      eyebrow: 'Étape 1 sur 3',
      progress: 1 / 3,
      onBack: widget.onBack,
      bottom: OnbPrimaryButton(label: 'Continuer', onPressed: _continue),
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            OnbMediaPicker(
              icon: LucideIcons.camera,
              label: 'Ajouter une photo',
              changeLabel: 'Modifier la photo',
              image: d.photo,
              onTap: _pickPhoto,
            ),
            if (_processingPhoto)
              const Positioned(
                top: 40,
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: OnbField(
                label: 'Prénom *',
                hint: 'Votre prénom',
                controller: _first,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.givenName],
                errorText: _required(d.firstName, 'Indiquez votre prénom'),
                onChanged: (v) {
                  d.firstName = v;
                  widget.onChanged();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OnbField(
                label: 'Nom *',
                hint: 'Votre nom',
                controller: _last,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.familyName],
                errorText: _required(d.lastName, 'Indiquez votre nom'),
                onChanged: (v) {
                  d.lastName = v;
                  widget.onChanged();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        OnbSelectBox(
          label: 'Date de naissance *',
          hint: 'JJ mois AAAA',
          value: d.birthDate == null ? null : formatFrDate(d.birthDate!),
          icon: LucideIcons.calendarDays,
          errorText: _dobError,
          onTap: _pickDate,
        ),
        if (d.isMinor && _dobError == null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(LucideIcons.shield, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Moins de 18 ans : l’accord d’un tuteur sera demandé à l’étape suivante.',
                  style: AppTextStyles.caption(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        OnbSelectBox(
          label: 'Nationalité *',
          hint: 'Choisir un pays',
          value: d.nationality,
          errorText: _submitted && d.nationality == null ? 'Choisissez votre nationalité' : null,
          onTap: _pickNationality,
        ),
        const SizedBox(height: 16),
        OnbField(
          label: 'Ville *',
          hint: 'Votre ville',
          controller: _city,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.addressCity],
          errorText: _required(d.city, 'Indiquez votre ville'),
          onChanged: (v) {
            d.city = v;
            widget.onChanged();
          },
        ),
        const SizedBox(height: 16),
        OnbField(
          label: widget.emailLocked ? 'Adresse e-mail' : 'Adresse e-mail *',
          hint: 'nom@email.com',
          controller: _email,
          enabled: !widget.emailLocked,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          errorText: widget.emailLocked ? null : _emailError,
          onChanged: (v) {
            d.email = v.trim();
            widget.onChanged();
          },
        ),
      ],
    );
  }
}
