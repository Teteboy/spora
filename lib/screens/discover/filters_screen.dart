import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock_data.dart';
import '../../models/player_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Combinable AND filters for Discover (frame 08 · Explorer — Filtres).
class DiscoverFilters {
  final String? position; // ATT / MIL / DEF / GAR
  final RangeValues ageRange; // 14–35
  final String? country;
  final String? level;
  final String? foot; // Droit / Gauche / Ambidextre
  final RangeValues heightRange; // meters
  final bool availableOnly;
  final bool premiumOnly;

  const DiscoverFilters({
    this.position,
    this.ageRange = const RangeValues(14, 35),
    this.country,
    this.level,
    this.foot,
    this.heightRange = const RangeValues(1.50, 2.10),
    this.availableOnly = false,
    this.premiumOnly = false,
  });

  /// Demo availability rule shared with Discover.
  static bool isAvailable(PlayerModel p) =>
      MockData.trendingPlayers.indexOf(p) % 2 == 0;

  static String _positionKeyword(String code) => switch (code) {
        'ATT' => 'attaq',
        'MIL' => 'milieu',
        'DEF' => 'défenseur',
        'GAR' => 'gardien',
        _ => code,
      };

  String _positionShort(String position) {
    final m = RegExp(r'\(([^)]+)\)').firstMatch(position);
    return m != null ? m.group(1)! : position.split(' ').first;
  }

  bool matches(PlayerModel p) {
    if (position != null &&
        !p.primaryPosition
            .toLowerCase()
            .contains(_positionKeyword(position!)) &&
        _positionShort(p.primaryPosition) != position) {
      return false;
    }
    if (p.age < ageRange.start || p.age > ageRange.end) return false;
    if (country != null &&
        !p.nationality.toLowerCase().contains(country!.toLowerCase())) {
      return false;
    }
    if (level != null &&
        !p.leagueDivision.toLowerCase().contains(level!.toLowerCase())) {
      return false;
    }
    if (foot != null &&
        !p.dominantFoot
            .toLowerCase()
            .startsWith(foot!.substring(0, 4).toLowerCase())) {
      return false;
    }
    if (p.height < heightRange.start || p.height > heightRange.end) {
      return false;
    }
    if (availableOnly && !isAvailable(p)) return false;
    if (premiumOnly && !p.isPremium) return false;
    return true;
  }

  /// Applied-filter chips: (label, key).
  List<(String, String)> activeLabels({bool isAvailableLabel = false}) {
    final out = <(String, String)>[];
    if (position != null) out.add((position!, 'position'));
    if (country != null) out.add((country!, 'country'));
    if (level != null) out.add((level!, 'level'));
    if (foot != null) out.add((foot!, 'foot'));
    if (availableOnly) out.add(('Disponible', 'available'));
    if (premiumOnly) out.add(('Premium', 'premium'));
    if (ageRange != const RangeValues(14, 35) ||
        heightRange != const RangeValues(1.50, 2.10)) {
      out.add(('Âge/Taille', 'ranges'));
    }
    return out;
  }

  DiscoverFilters without(String key) => switch (key) {
        'position' => copyWith(position: () => null),
        'country' => copyWith(country: () => null),
        'level' => copyWith(level: () => null),
        'foot' => copyWith(foot: () => null),
        'available' => copyWith(availableOnly: false),
        'premium' => copyWith(premiumOnly: false),
        'ranges' => copyWith(
            ageRange: const RangeValues(14, 35),
            heightRange: const RangeValues(1.50, 2.10)),
        _ => this,
      };

  DiscoverFilters copyWith({
    String? Function()? position,
    RangeValues? ageRange,
    String? Function()? country,
    String? Function()? level,
    String? Function()? foot,
    RangeValues? heightRange,
    bool? availableOnly,
    bool? premiumOnly,
  }) {
    return DiscoverFilters(
      position: position != null ? position() : this.position,
      ageRange: ageRange ?? this.ageRange,
      country: country != null ? country() : this.country,
      level: level != null ? level() : this.level,
      foot: foot != null ? foot() : this.foot,
      heightRange: heightRange ?? this.heightRange,
      availableOnly: availableOnly ?? this.availableOnly,
      premiumOnly: premiumOnly ?? this.premiumOnly,
    );
  }
}

class FiltersScreen extends StatefulWidget {
  final DiscoverFilters? initial;
  const FiltersScreen({super.key, this.initial});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  late DiscoverFilters _f;

  static const _positions = ['ATT', 'MIL', 'DEF', 'GAR'];
  static const _countries = [
    'France',
    'Cameroun',
    'Sénégal',
    'Côte d’Ivoire',
    'Guinée'
  ];
  static const _levels = ['Division 1', 'Division 2', 'Senior', 'U21'];
  static const _feet = ['Droit', 'Gauche', 'Ambidextre'];
  static const _heights = [
    'Toutes les tailles',
    '- 1,70 m',
    '1,70 – 1,80 m',
    '1,80 – 1,90 m',
    '+ 1,90 m'
  ];

  String? _heightBand = 'Toutes les tailles';

  @override
  void initState() {
    super.initState();
    _f = widget.initial ?? const DiscoverFilters(availableOnly: true);
  }

  int get _resultCount =>
      MockData.trendingPlayers.where(_f.matches).length * 25; // demo scale

  void _setHeightBand(String? band) {
    setState(() {
      _heightBand = band;
      final range = switch (band) {
        '- 1,70 m' => const RangeValues(1.50, 1.70),
        '1,70 – 1,80 m' => const RangeValues(1.70, 1.80),
        '1,80 – 1,90 m' => const RangeValues(1.80, 1.90),
        '+ 1,90 m' => const RangeValues(1.90, 2.10),
        _ => const RangeValues(1.50, 2.10),
      };
      _f = _f.copyWith(heightRange: range);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy900.withValues(alpha: 0.6),
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 780),
          decoration: const BoxDecoration(
            color: AppColors.appBg,
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppDimens.radiusSheet)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: AppDimens.md),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusPill),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppDimens.screenMargin,
                      AppDimens.md,
                      AppDimens.screenMargin,
                      0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Affiner la recherche',
                          style: AppTextStyles.h1()),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: AppDimens.minTouch,
                          height: AppDimens.minTouch,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                                AppDimens.radiusInput),
                            border:
                                Border.all(color: AppColors.border),
                          ),
                          child: const Icon(LucideIcons.x,
                              size: 20, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppDimens.screenMargin),
                    children: [
                      _label('Poste'),
                      Wrap(
                        spacing: AppDimens.sm,
                        children: _positions
                            .map((p) => _chip(
                                  p,
                                  _f.position == p,
                                  () => setState(() => _f =
                                      _f.copyWith(
                                          position: () =>
                                              _f.position == p
                                                  ? null
                                                  : p)),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: AppDimens.section),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          _label('Âge'),
                          Text(
                            '${_f.ageRange.start.toInt()}–${_f.ageRange.end.toInt()} ans',
                            style: AppTextStyles.bodyStrong(
                                color: AppColors.primary),
                          ),
                        ],
                      ),
                      RangeSlider(
                        values: _f.ageRange,
                        min: 14,
                        max: 35,
                        divisions: 21,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.border,
                        onChanged: (v) =>
                            setState(() => _f = _f.copyWith(ageRange: v)),
                      ),
                      Row(children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _label('Pays'),
                              _dropdown(
                                value: _f.country,
                                hint: 'Tous les pays',
                                items: _countries,
                                onChanged: (v) => setState(() => _f =
                                    _f.copyWith(country: () => v)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppDimens.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _label('Niveau'),
                              _dropdown(
                                value: _f.level,
                                hint: 'Tous niveaux',
                                items: _levels,
                                onChanged: (v) => setState(() => _f =
                                    _f.copyWith(level: () => v)),
                              ),
                            ],
                          ),
                        ),
                      ]),
                      const SizedBox(height: AppDimens.section),
                      _label('Pied fort'),
                      Wrap(
                        spacing: AppDimens.sm,
                        children: _feet
                            .map((e) => _chip(
                                  e,
                                  _f.foot == e,
                                  () => setState(() => _f =
                                      _f.copyWith(
                                          foot: () =>
                                              _f.foot == e ? null : e)),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: AppDimens.section),
                      _label('Taille'),
                      _dropdown(
                        value: _heightBand,
                        hint: 'Toutes les tailles',
                        items: _heights,
                        onChanged: _setHeightBand,
                      ),
                      const SizedBox(height: AppDimens.section),
                      _switch(
                        'Disponible uniquement',
                        _f.availableOnly,
                        (v) => setState(() =>
                            _f = _f.copyWith(availableOnly: v)),
                      ),
                      _switch(
                        'Premium uniquement',
                        _f.premiumOnly,
                        (v) => setState(
                            () => _f = _f.copyWith(premiumOnly: v)),
                      ),
                      const SizedBox(height: AppDimens.md),
                      Text(
                        'Mineurs : consentement du représentant légal '
                        'requis pour apparaître dans la recherche. '
                        'Contact réservé aux agents et clubs vérifiés.',
                        style: AppTextStyles.caption(),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppDimens.screenMargin),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border:
                        Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(children: [
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        onPressed: () => setState(() {
                          _f = const DiscoverFilters();
                          _heightBand = 'Toutes les tailles';
                        }),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side:
                              const BorderSide(color: AppColors.border),
                          textStyle: AppTextStyles.button(
                              color: AppColors.textPrimary),
                          padding: const EdgeInsets.symmetric(
                              vertical: AppDimens.md),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimens.radiusPill)),
                        ),
                        child: const Text('Réinitialiser'),
                      ),
                    ),
                    const SizedBox(width: AppDimens.md),
                    Expanded(
                      flex: 3,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: AppColors.primaryGradient),
                          borderRadius: BorderRadius.circular(
                              AppDimens.radiusPill),
                        ),
                        child: ElevatedButton(
                          onPressed: () => context.pop(_f),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            textStyle: AppTextStyles.button(),
                            padding: const EdgeInsets.symmetric(
                                vertical: AppDimens.md),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppDimens.radiusPill)),
                          ),
                          child: Text(
                              'Afficher $_resultCount résultats'),
                        ),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: AppDimens.sm),
        child: Text(t, style: AppTextStyles.bodyStrong()),
      );

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.lg, vertical: AppDimens.sm),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryTint : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          border: Border.all(
              color: active ? AppColors.primary : AppColors.border),
        ),
        child: Text(label,
            style: AppTextStyles.bodyStrong(
                color:
                    active ? AppColors.primary : AppColors.textSecondary)),
      ),
    );
  }

  Widget _dropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppDimens.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusInput),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint,
              style:
                  AppTextStyles.body(color: AppColors.textSecondary)),
          isExpanded: true,
          icon: const Icon(LucideIcons.chevronDown,
              color: AppColors.textSecondary),
          style: AppTextStyles.body(color: AppColors.textPrimary),
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _switch(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyLarge()),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: AppColors.primary,
        ),
      ],
    );
  }
}
