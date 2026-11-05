import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/opportunity_model.dart';
import 'opportunities_shared.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Publier une opportunité (/opportunities/publish)
/// 4 étapes : Type → Détails → Critères → Aperçu, puis « Publication réussie ».
class PublishOpportunityScreen extends StatefulWidget {
  const PublishOpportunityScreen({super.key});

  @override
  State<PublishOpportunityScreen> createState() =>
      _PublishOpportunityScreenState();
}

class _PublishOpportunityScreenState extends State<PublishOpportunityScreen> {
  int _step = 0; // 0..3, 4 = succès
  bool _published = false;

  // Étape 1
  OpportunityType _type = OpportunityType.detection;

  // Étape 2
  final _titleCtrl =
      TextEditingController(text: 'Détection U21 · Douala');
  final _descCtrl = TextEditingController(
      text:
          'Deux jours pour montrer votre jeu à notre équipe de recrutement. Les profils retenus seront contactés sur SPORA.');
  final _locationCtrl = TextEditingController(text: 'Douala, Cameroun');
  final _placesCtrl = TextEditingController(text: '24');
  final _feesCtrl = TextEditingController(text: 'Sans frais');
  DateTime? _startDate = DateTime(2026, 11, 14);
  DateTime? _endDate = DateTime(2026, 11, 15);
  DateTime? _deadline = DateTime(2026, 11, 8);
  String? _deadlineError;

  // Étape 3
  final Set<String> _positions = {'ATT', 'MIL'};
  final _ageCtrl = TextEditingController(text: '18–21 ans au 14 novembre 2026');
  final _levelCtrl = TextEditingController(text: 'U21');
  final _countryCtrl = TextEditingController(text: 'Tous les pays');
  String _foot = 'Tous les pieds';
  static const _positionOptions = ['ATT', 'MIL', 'DEF', 'GAR'];
  static const _footOptions = ['Tous les pieds', 'Droit', 'Gauche', 'Ambidextre'];

  // Étape 4
  bool _confirmed = true;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _placesCtrl.dispose();
    _feesCtrl.dispose();
    _ageCtrl.dispose();
    _levelCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 1) {
      // La date limite ne peut pas être dans le passé.
      if (_deadline == null ||
          _deadline!.isBefore(DateTime(2026, 10, 20))) {
        setState(() =>
            _deadlineError = 'La date limite ne peut pas être passée.');
        return;
      }
      setState(() => _deadlineError = null);
    }
    if (_step < 3) {
      setState(() => _step++);
    } else {
      setState(() {
        _published = true;
        _step = 4;
      });
    }
  }

  void _back() {
    if (_step > 0 && _step < 4) {
      setState(() => _step--);
    } else {
      context.pop();
    }
  }

  Future<void> _pickDate(bool isDeadline) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isDeadline ? _deadline : _startDate) ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      helpText: isDeadline ? 'DATE LIMITE' : 'DATE DE DÉBUT',
    );
    if (picked == null) return;
    setState(() {
      if (isDeadline) {
        _deadline = picked;
        _deadlineError = null;
      } else {
        _startDate = picked;
        if (_endDate == null || _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_published) return _SuccessScreen(type: _type);
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.screenMargin),
                children: [
                  const SizedBox(height: AppDimens.sm),
                  _buildStep(),
                  const SizedBox(height: AppDimens.lg),
                  _draftButton(),
                  const SizedBox(height: AppDimens.lg),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(AppDimens.screenMargin,
                  12, AppDimens.screenMargin, 24),
              color: AppColors.surface,
              child: OppGradientButton(
                label: _step == 3 ? 'Publier' : 'Continuer',
                onPressed: _step == 3 && !_confirmed ? null : _next,
                enabled: _step != 3 || _confirmed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final pct = ((_step + 1) / 4);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppDimens.screenMargin, 8, AppDimens.screenMargin, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _back,
                child: Container(
                  width: AppDimens.minTouch,
                  height: AppDimens.minTouch,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusInput),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(LucideIcons.arrowLeft,
                      size: 22, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Text('Publier une opportunité',
                    style: AppTextStyles.h1(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Text('Étape ${_step + 1} sur 4',
              style: AppTextStyles.bodyStrong(color: AppColors.primary)),
          const SizedBox(height: AppDimens.sm),
          Text('${(pct * 100).round()} %',
              style: AppTextStyles.bodyStrong(color: AppColors.primary)),
          const SizedBox(height: AppDimens.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: AppColors.muted,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: AppDimens.lg),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _stepType();
      case 1:
        return _stepDetails();
      case 2:
        return _stepCriteria();
      default:
        return _stepPreview();
    }
  }

  // — Étape 1 : Type —
  Widget _stepType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quel type d’opportunité ?', style: AppTextStyles.display()),
        const SizedBox(height: AppDimens.xl),
        ...OpportunityType.values.map((t) {
          final selected = _type == t;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.md),
            child: OppCard(
              onTap: () => setState(() => _type = t),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? LucideIcons.circleDot
                        : LucideIcons.circle,
                    color: selected ? AppColors.primary : AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.chipLabel,
                            style: AppTextStyles.bodyStrong()),
                        const SizedBox(height: 2),
                        Text(
                          selected
                              ? '✓ Sélectionné · ${t.publishHint}'
                              : 'Choisir cette catégorie',
                          style: AppTextStyles.body(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // — Étape 2 : Détails —
  Widget _stepDetails() {
    return Column(
      children: [
        _field('Titre *', _titleCtrl),
        const SizedBox(height: AppDimens.md),
        _field('Description *', _descCtrl, maxLines: 4),
        const SizedBox(height: AppDimens.md),
        _field('Lieu *', _locationCtrl),
        const SizedBox(height: AppDimens.md),
        _dateField(
          'Dates *',
          OppFmt.range(_startDate, _endDate).isEmpty
              ? 'Sélectionner'
              : OppFmt.range(_startDate, _endDate),
          () => _pickDate(false),
        ),
        const SizedBox(height: AppDimens.md),
        _dateField(
          'Date limite de candidature *',
          _deadline == null ? 'Sélectionner' : OppFmt.date(_deadline!),
          () => _pickDate(true),
          error: _deadlineError,
        ),
        const SizedBox(height: AppDimens.md),
        Row(
          children: [
            Expanded(child: _field('Places *', _placesCtrl)),
            const SizedBox(width: AppDimens.md),
            Expanded(child: _field('Frais éventuels', _feesCtrl)),
          ],
        ),
        const SizedBox(height: AppDimens.md),
        if (!OpportunitiesMock.publisherVerified)
          _infoBox(
            'En validation',
            'Votre profil recruteur n’est pas encore vérifié : '
                'cette opportunité sera soumise à validation avant publication.',
          )
        else
          _infoBox(
            'Offre de démonstration',
            'Académie fictive. Ne jamais présenter ces informations '
                'comme un recrutement réel.',
          ),
      ],
    );
  }

  // — Étape 3 : Critères —
  Widget _stepCriteria() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Les profils recherchés', style: AppTextStyles.display()),
        const SizedBox(height: AppDimens.lg),
        Text('Postes', style: AppTextStyles.h3()),
        const SizedBox(height: AppDimens.sm),
        Wrap(
          spacing: AppDimens.sm,
          children: _positionOptions.map((p) {
            final sel = _positions.contains(p);
            return GestureDetector(
              onTap: () => setState(
                  () => sel ? _positions.remove(p) : _positions.add(p)),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: sel
                      ? AppColors.primaryTint.withValues(alpha: 0.5)
                      : AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusPill),
                  border: Border.all(
                      color: sel ? AppColors.primary : AppColors.border),
                ),
                child: Text(
                  sel ? '$p ✓' : p,
                  style: AppTextStyles.bodyStrong(
                      color: sel
                          ? AppColors.primary
                          : AppColors.textSecondary),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppDimens.lg),
        _field('Âge requis', _ageCtrl),
        const SizedBox(height: AppDimens.md),
        _field('Niveau', _levelCtrl),
        const SizedBox(height: AppDimens.md),
        _field('Pays', _countryCtrl),
        const SizedBox(height: AppDimens.lg),
        Wrap(
          spacing: AppDimens.sm,
          children: _footOptions.map((f) {
            final sel = _foot == f;
            return GestureDetector(
              onTap: () => setState(() => _foot = f),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: sel
                      ? AppColors.primaryTint.withValues(alpha: 0.5)
                      : AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusPill),
                  border: Border.all(
                      color: sel ? AppColors.primary : AppColors.border),
                ),
                child: Text(f,
                    style: AppTextStyles.bodyStrong(
                        color: sel
                            ? AppColors.primary
                            : AppColors.textSecondary)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppDimens.lg),
        _infoBox(
          'Pièces de candidature',
          'Profil complété, un highlight récent et disponibilité '
              'à ${_locationCtrl.text.split(',').first} les deux journées.',
        ),
      ],
    );
  }

  // — Étape 4 : Aperçu —
  Widget _stepPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Aperçu côté joueur', style: AppTextStyles.display()),
        const SizedBox(height: AppDimens.lg),
        OppCard(
          padding: const EdgeInsets.all(AppDimens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppDimens.radiusInput),
                child: Image.network(
                  'https://images.unsplash.com/photo-1521412644187-c49fa049e84d?w=900&h=460&fit=crop&auto=format&q=80',
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      height: 140, color: AppColors.muted),
                ),
              ),
              const SizedBox(height: AppDimens.md),
              const OppChip(
                  label: 'Ouverte',
                  color: AppColors.green,
                  textColor: AppColors.clubGreen),
              const SizedBox(height: AppDimens.sm),
              Text(_titleCtrl.text, style: AppTextStyles.h2()),
              const SizedBox(height: AppDimens.sm),
              _pvLine('Académie des Rives'),
              _pvLine(_locationCtrl.text),
              _pvLine(OppFmt.range(_startDate, _endDate)),
              _pvLine(
                  '${_ageCtrl.text.split(' au ').first} · ${_positions.join(' · ')} · ${_placesCtrl.text} places'),
              _pvLine(_deadline == null
                  ? ''
                  : 'Clôture le ${OppFmt.date(_deadline!)}'),
              _pvLine(
                  'Offre d’exemple · Académie fictive · ${_feesCtrl.text}'),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.lg),
        _infoBox(
          'Avant de publier',
          'Vérifiez les dates, les critères et votre identité de recruteur. '
              'Votre e-mail doit être vérifié.',
        ),
        const SizedBox(height: AppDimens.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _confirmed,
                activeColor: AppColors.textSecondary,
                onChanged: (v) => setState(() => _confirmed = v ?? false),
              ),
            ),
            const SizedBox(width: AppDimens.sm),
            Expanded(
              child: Text(
                'Je confirme l’exactitude des informations de démonstration.',
                style: AppTextStyles.body(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _pvLine(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(text, style: AppTextStyles.body()),
      );

  Widget _field(String label, TextEditingController ctrl,
      {int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppDimens.lg, AppDimens.md, AppDimens.lg, AppDimens.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusInput),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: AppTextStyles.body(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.body(color: AppColors.textSecondary),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _dateField(String label, String value, VoidCallback onTap,
      {String? error}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimens.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.circular(AppDimens.radiusInput),
              border: Border.all(
                  color:
                      error != null ? AppColors.danger : AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.body(
                        color: AppColors.textSecondary)),
                const SizedBox(height: AppDimens.xs),
                Text(value,
                    style: AppTextStyles.body(
                        color: AppColors.textPrimary)),
              ],
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(error,
                style: AppTextStyles.caption(color: AppColors.errorText)),
          ),
      ],
    );
  }

  Widget _infoBox(String title, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTextStyles.bodyStrong(color: AppColors.primary)),
          const SizedBox(height: AppDimens.xs),
          Text(text,
              style: AppTextStyles.bodyStrong(color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _draftButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => context.pop(),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDimens.radiusCard),
          ),
        ),
        child: Text('Enregistrer le brouillon',
            style:
                AppTextStyles.button(color: AppColors.textPrimary)),
      ),
    );
  }
}

/// Écran « Publication réussie ».
class _SuccessScreen extends StatelessWidget {
  final OpportunityType type;
  const _SuccessScreen({required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppDimens.screenMargin,
                  AppDimens.sm, AppDimens.screenMargin, AppDimens.md),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/opportunities'),
                    child: Container(
                      width: AppDimens.minTouch,
                      height: AppDimens.minTouch,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(
                            AppDimens.radiusInput),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(LucideIcons.arrowLeft,
                          size: 22, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: Text('Publication réussie',
                        style: AppTextStyles.h1(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppDimens.screenMargin),
                children: [
          const SizedBox(height: AppDimens.lg),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(color: AppColors.clubGreen, width: 2),
            ),
            child: const Icon(LucideIcons.check,
                color: AppColors.clubGreen, size: 36),
          ),
          const SizedBox(height: AppDimens.xl),
          Text('Votre opportunité est\npubliée',
              style: AppTextStyles.display()),
          const SizedBox(height: AppDimens.md),
          Text(
            'Les joueurs peuvent consulter la ${type.label.toLowerCase()} et envoyer leur dossier.',
            style: AppTextStyles.bodyLarge(
                color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimens.xl),
          OppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const OppChip(
                    label: 'Ouverte',
                    color: AppColors.green,
                    textColor: AppColors.clubGreen),
                const SizedBox(height: AppDimens.sm),
                Text('Détection U21 · Douala', style: AppTextStyles.h2()),
                const SizedBox(height: AppDimens.sm),
                _line('Académie des Rives'),
                _line('Douala, Cameroun'),
                _line('14–15 novembre 2026'),
                _line('18–21 ans · ATT · MIL · 24 places'),
                _line('Clôture le 8 novembre 2026'),
                _line(
                    'Offre d’exemple · Académie fictive · Sans frais'),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimens.lg),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(AppDimens.radiusCard),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Exemple fictif',
                    style: AppTextStyles.bodyStrong(
                        color: AppColors.clubGreen)),
                const SizedBox(height: AppDimens.xs),
                Text(
                  'Aucun recrutement ni envoi réel n’est effectué dans cette maquette.',
                  style: AppTextStyles.bodyStrong(
                      color: AppColors.clubGreen),
                ),
              ],
            ),
          ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(
            AppDimens.screenMargin, 12, AppDimens.screenMargin, 24),
        color: AppColors.surface,
        child: OppGradientButton(
          label: 'Voir mon opportunité',
          onPressed: () => context.push('/opportunities/mine'),
        ),
      ),
    );
  }

  Widget _line(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(text, style: AppTextStyles.body()),
      );
}
