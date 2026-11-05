import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../onboarding_draft.dart';
import '../onboarding_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Étape 2 — Informations football (Figma "04 · Entrée — Informations football").
class Step2FootballInfo extends StatefulWidget {
  const Step2FootballInfo({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.onBack,
    required this.onContinue,
  });

  final PlayerDraft draft;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  State<Step2FootballInfo> createState() => _Step2FootballInfoState();
}

class _Step2FootballInfoState extends State<Step2FootballInfo> {
  late final TextEditingController _height = TextEditingController(text: widget.draft.height);
  late final TextEditingController _weight = TextEditingController(text: widget.draft.weight);
  late final TextEditingController _club = TextEditingController(text: widget.draft.club);
  bool _submitted = false;

  PlayerDraft get d => widget.draft;

  @override
  void dispose() {
    _height.dispose();
    _weight.dispose();
    _club.dispose();
    super.dispose();
  }

  void _update(VoidCallback fn) {
    setState(fn);
    widget.onChanged();
  }

  void _selectMain(String code) {
    _update(() {
      d.mainPosition = code;
      final group = positionGroup(code)!;
      if (!group.subs.any((s) => s.code == d.subPosition)) {
        d.subPosition = group.subs.length == 1 ? group.subs.first.code : null;
      }
      d.secondaryPositions.remove(d.subPosition);
    });
  }

  String? get _heightError {
    final v = int.tryParse(d.height);
    final show = _submitted || d.height.length >= 3;
    if (!show) return null;
    if (v == null) return _submitted ? 'Indiquez votre taille' : null;
    if (v < 120 || v > 230) return 'Entre 120 et 230 cm';
    return null;
  }

  String? get _weightError {
    if (d.weight.isEmpty) return null;
    final v = int.tryParse(d.weight);
    final show = _submitted || d.weight.length >= 3;
    if (!show) return null;
    if (v == null || v < 30 || v > 150) return 'Entre 30 et 150 kg';
    return null;
  }

  bool get _valid {
    final h = int.tryParse(d.height);
    final w = int.tryParse(d.weight);
    return d.mainPosition != null &&
        h != null &&
        h >= 120 &&
        h <= 230 &&
        (d.weight.isEmpty || (w != null && w >= 30 && w <= 150)) &&
        d.foot != null &&
        d.level != null;
  }

  Future<void> _pickLevel() async {
    FocusScope.of(context).unfocus();
    final v = await showOnbOptionsSheet(context,
        title: 'Niveau', options: kPlayerLevels, selected: d.level);
    if (v == null || !mounted) return;
    _update(() => d.level = v);
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

  Widget _error(String text) => Padding(
        padding: const EdgeInsets.only(top: 6, left: 4),
        child: Text(text, style: AppTextStyles.caption(color: AppColors.errorText)),
      );

  @override
  Widget build(BuildContext context) {
    final group = positionGroup(d.mainPosition);
    final allSubs = kAllSubPositions.where((s) => s.code != d.subPosition).toList();

    return OnbScaffold(
      title: 'Informations football',
      boxedBack: true,
      onBack: widget.onBack,
      eyebrow: 'Étape 2 sur 3',
      trailingEyebrow: 'Votre jeu, en détail',
      segmentCount: 3,
      segmentFilled: 2,
      progress: 2 / 3,
      bottom: Row(
        children: [
          Expanded(flex: 2, child: OnbSecondaryButton(label: 'Retour', onPressed: widget.onBack)),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: OnbPrimaryButton(
              label: 'Continuer',
              icon: LucideIcons.arrowRight,
              onPressed: _continue,
            ),
          ),
        ],
      ),
      children: [
        Text('Aidez les recruteurs à comprendre votre profil.',
            style: AppTextStyles.bodyLarge(color: AppColors.textSecondary)),
        const SizedBox(height: 20),
        const OnbSectionLabel('Poste principal *'),
        _PositionPitch(selected: d.mainPosition, onSelect: _selectMain),
        const SizedBox(height: 12),
        OnbPillWrap(
          children: [
            for (final g in kPositionGroups)
              OnbPill(
                label: g.code,
                semanticLabel: g.label,
                selected: d.mainPosition == g.code,
                onTap: () => _selectMain(g.code),
              ),
          ],
        ),
        if (_submitted && d.mainPosition == null) _error('Choisissez votre poste principal'),
        if (group != null && group.subs.length > 1) ...[
          const SizedBox(height: 20),
          OnbSectionLabel('Poste précis', helper: group.label),
          OnbPillWrap(
            children: [
              for (final s in group.subs)
                OnbPill(
                  label: s.label,
                  selected: d.subPosition == s.code,
                  onTap: () => _update(() {
                    d.subPosition = d.subPosition == s.code ? null : s.code;
                    d.secondaryPositions.remove(d.subPosition);
                  }),
                ),
            ],
          ),
        ],
        const SizedBox(height: 20),
        const OnbSectionLabel('Postes secondaires', helper: 'Facultatif · plusieurs choix possibles'),
        OnbPillWrap(
          children: [
            for (final s in allSubs)
              OnbPill(
                label: s.label,
                selected: d.secondaryPositions.contains(s.code),
                onTap: () => _update(() {
                  if (!d.secondaryPositions.remove(s.code)) d.secondaryPositions.add(s.code);
                }),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: OnbField(
                label: 'Taille (cm) *',
                labelOutside: true,
                hint: '182',
                controller: _height,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 3,
                errorText: _heightError,
                onChanged: (v) => _update(() => d.height = v),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OnbField(
                label: 'Poids (kg)',
                labelOutside: true,
                hint: '74',
                controller: _weight,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 3,
                errorText: _weightError,
                onChanged: (v) => _update(() => d.weight = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const OnbSectionLabel('Pied fort *'),
        OnbPillWrap(
          children: [
            for (final f in kFeet)
              OnbPill(label: f, selected: d.foot == f, onTap: () => _update(() => d.foot = f)),
          ],
        ),
        if (_submitted && d.foot == null) _error('Choisissez votre pied fort'),
        const SizedBox(height: 20),
        OnbField(
          label: 'Club actuel',
          labelOutside: true,
          hint: 'Nom de votre club',
          controller: _club,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onChanged: (v) => _update(() => d.club = v),
        ),
        const SizedBox(height: 20),
        OnbSelectBox(
          label: 'Niveau *',
          labelOutside: true,
          hint: 'Choisir un niveau',
          value: d.level,
          errorText: _submitted && d.level == null ? 'Choisissez votre niveau' : null,
          onTap: _pickLevel,
        ),
        const SizedBox(height: 20),
        const OnbSectionLabel('Années d’expérience'),
        _Stepper(
          value: d.experience,
          max: 25,
          onChanged: (v) => _update(() => d.experience = v),
        ),
        const SizedBox(height: 20),
        const OnbSectionLabel('Disponibilité',
            helper: 'Les recruteurs voient si vous êtes ouvert aux opportunités.'),
        OnbPillWrap(
          children: [
            OnbPill(
              label: 'Disponible',
              selected: d.available,
              leading: const _Dot(color: AppColors.success),
              onTap: () => _update(() => d.available = true),
            ),
            OnbPill(
              label: 'Indisponible',
              selected: !d.available,
              leading: const _Dot(color: AppColors.textHint),
              onTap: () => _update(() => d.available = false),
            ),
          ],
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.value, required this.max, required this.onChanged});
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = value == 0
        ? 'Moins d’un an'
        : value >= max
            ? '$max ans et plus'
            : '$value ${value == 1 ? 'an' : 'ans'}';
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusInput),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Text(label, style: AppTextStyles.bodyLarge(color: AppColors.textPrimary)),
            ),
          ),
          IconButton(
            tooltip: 'Moins',
            onPressed: value > 0 ? () => onChanged(value - 1) : null,
            icon: const Icon(LucideIcons.minusCircle),
            color: AppColors.primary,
            disabledColor: AppColors.textHint,
          ),
          IconButton(
            tooltip: 'Plus',
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(LucideIcons.plusCircle),
            color: AppColors.primary,
            disabledColor: AppColors.textHint,
          ),
        ],
      ),
    );
  }
}

/// Green pitch with the selected main position badge; tap a zone to select.
class _PositionPitch extends StatelessWidget {
  const _PositionPitch({required this.selected, required this.onSelect});
  final String? selected;
  final ValueChanged<String> onSelect;

  static const Map<String, double> _y = {'ATT': -0.62, 'MIL': 0.0, 'DEF': 0.52, 'GAR': 0.88};

  String _codeAt(double fraction) {
    if (fraction < 0.32) return 'ATT';
    if (fraction < 0.62) return 'MIL';
    if (fraction < 0.86) return 'DEF';
    return 'GAR';
  }

  @override
  Widget build(BuildContext context) {
    final group = positionGroup(selected);
    return Semantics(
      label: group == null
          ? 'Terrain : aucun poste sélectionné'
          : 'Terrain : ${group.label} sélectionné',
      excludeSemantics: true,
      child: AspectRatio(
        aspectRatio: 2.4,
        child: LayoutBuilder(
          builder: (context, c) => GestureDetector(
            onTapDown: (details) => onSelect(_codeAt(details.localPosition.dy / c.maxHeight)),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.clubGreen,
                borderRadius: BorderRadius.circular(AppDimens.radiusCard),
              ),
              padding: const EdgeInsets.all(12),
              child: Stack(
                children: [
                  const Positioned.fill(child: CustomPaint(painter: _PitchPainter())),
                  if (selected != null)
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 280),
                      curve: const Cubic(0.2, 0, 0, 1),
                      alignment: Alignment(0, _y[selected] ?? 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                        ),
                        child: Text(
                          selected!,
                          style: AppTextStyles.bodyStrong(color: AppColors.clubGreen)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PitchPainter extends CustomPainter {
  const _PitchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(Offset.zero & size, p);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), p);
    final r = size.height * 0.14;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), r, p);
  }

  @override
  bool shouldRepaint(covariant _PitchPainter oldDelegate) => false;
}
