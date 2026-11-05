import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence for onboarding drafts (progress saved & resumable).
class OnboardingStore {
  static const String playerKey = 'spora.onboarding.player';
  static const String agentKey = 'spora.onboarding.agent';
  static const String clubKey = 'spora.onboarding.club';

  /// Search criteria captured during agent/club onboarding, used to pre-fill
  /// the discover / filters screens.
  static const String filtersKey = 'spora.search_filters';

  static Future<Map<String, dynamic>?> load(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null) return null;
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(data));
    } catch (_) {
      // Persistence is best effort.
    }
  }

  static Future<void> clear(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (_) {}
  }

  /// Images are only persisted when small enough for local storage.
  static String? encodeImage(Uint8List? bytes) {
    if (bytes == null || bytes.lengthInBytes > 800 * 1024) return null;
    return base64Encode(bytes);
  }

  static Uint8List? decodeImage(Object? value) {
    if (value is! String || value.isEmpty) return null;
    try {
      return base64Decode(value);
    } catch (_) {
      return null;
    }
  }
}

// ---------------------------------------------------------------------------
// Reference data
// ---------------------------------------------------------------------------

class SubPosition {
  final String code;
  final String label;
  const SubPosition(this.code, this.label);
}

class PositionGroup {
  final String code;
  final String label;
  final List<SubPosition> subs;
  const PositionGroup(this.code, this.label, this.subs);
}

/// Display order follows the Figma pitch selector: ATT · MIL · DEF · GAR.
const List<PositionGroup> kPositionGroups = [
  PositionGroup('ATT', 'Attaquant', [
    SubPosition('BU', 'Avant-centre'),
    SubPosition('AD', 'Ailier droit'),
    SubPosition('AG', 'Ailier gauche'),
    SubPosition('SA', 'Second attaquant'),
  ]),
  PositionGroup('MIL', 'Milieu', [
    SubPosition('MDC', 'Milieu défensif'),
    SubPosition('MC', 'Milieu central'),
    SubPosition('MOC', 'Milieu offensif'),
    SubPosition('MD', 'Milieu droit'),
    SubPosition('MG', 'Milieu gauche'),
  ]),
  PositionGroup('DEF', 'Défenseur', [
    SubPosition('DC', 'Défenseur central'),
    SubPosition('DD', 'Latéral droit'),
    SubPosition('DG', 'Latéral gauche'),
    SubPosition('PIS', 'Piston'),
  ]),
  PositionGroup('GAR', 'Gardien', [
    SubPosition('GB', 'Gardien de but'),
  ]),
];

PositionGroup? positionGroup(String? code) {
  for (final g in kPositionGroups) {
    if (g.code == code) return g;
  }
  return null;
}

List<SubPosition> get kAllSubPositions =>
    [for (final g in kPositionGroups) ...g.subs];

const List<String> kCountries = [
  'Cameroun',
  'Côte d’Ivoire',
  'Sénégal',
  'France',
  'Nigeria',
  'Ghana',
  'Mali',
  'Maroc',
  'Gabon',
  'RD Congo',
  'Guinée',
  'Burkina Faso',
  'Togo',
  'Bénin',
  'Algérie',
  'Tunisie',
  'Belgique',
  'Suisse',
  'Canada',
  'Autre',
];

const Map<String, String> _dialCodes = {
  'Cameroun': '+237',
  'Côte d’Ivoire': '+225',
  'Sénégal': '+221',
  'France': '+33',
  'Nigeria': '+234',
  'Ghana': '+233',
  'Mali': '+223',
  'Maroc': '+212',
  'Gabon': '+241',
  'RD Congo': '+243',
  'Guinée': '+224',
  'Burkina Faso': '+226',
  'Togo': '+228',
  'Bénin': '+229',
  'Algérie': '+213',
  'Tunisie': '+216',
  'Belgique': '+32',
  'Suisse': '+41',
  'Canada': '+1',
};

String dialCodeFor(String? country) => _dialCodes[country] ?? '+237';

const List<String> kPlayerLevels = [
  'Amateur',
  'Régional',
  'National',
  'U17',
  'U19',
  'U21',
  'Semi-professionnel',
  'Professionnel',
];

const List<String> kClubDivisions = [
  'Académie U17',
  'Académie U19',
  'Académie U21',
  'Amateur',
  'Régional',
  'National',
  'Deuxième division',
  'Première division',
];

const List<String> kRecruiterRoles = [
  'Responsable recrutement',
  'Directeur sportif',
  'Entraîneur',
  'Recruteur / scout',
  'Président',
  'Autre',
];

const List<String> kGuardianRelations = [
  'Mère',
  'Père',
  'Tuteur légal',
  'Autre représentant légal',
];

const List<String> kFeet = ['Droit', 'Gauche', 'Ambidextre'];

const List<String> kRegions = [
  'Cameroun',
  'France',
  'Côte d’Ivoire',
  'Sénégal',
  'Nigeria',
  'Ghana',
  'Mali',
  'Maroc',
];

// ---------------------------------------------------------------------------
// Formatting / validation helpers
// ---------------------------------------------------------------------------

const List<String> _frMonths = [
  'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
  'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
];

String formatFrDate(DateTime d) => '${d.day} ${_frMonths[d.month - 1]} ${d.year}';

String formatFrDateTime(DateTime d) {
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '${formatFrDate(d)} · $hh:$mm';
}

/// "38 Mo", "23,6 Mo".
String formatMo(num bytes) {
  final mo = bytes / (1024 * 1024);
  final fixed = mo >= 100 ? mo.toStringAsFixed(0) : mo.toStringAsFixed(1);
  return '${fixed.replaceAll('.', ',').replaceAll(RegExp(r',0$'), '')} Mo';
}

final RegExp _emailRe = RegExp(r'^[\w.+\-]+@[\w\-]+(\.[\w\-]+)+$');
final RegExp _urlRe = RegExp(r'^(https?:\/\/)?[\w\-]+(\.[\w\-]+)+(\/\S*)?$');

bool isValidEmail(String v) => _emailRe.hasMatch(v.trim());
bool isValidUrl(String v) => _urlRe.hasMatch(v.trim());

int? ageFrom(DateTime? birth) {
  if (birth == null) return null;
  final now = DateTime.now();
  var age = now.year - birth.year;
  if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) {
    age--;
  }
  return age;
}

// ---------------------------------------------------------------------------
// Player draft
// ---------------------------------------------------------------------------

enum PlayerStage { general, guardian, guardianPending, football, highlights, ready }

class PlayerDraft {
  PlayerStage stage = PlayerStage.general;

  // Step 1
  String firstName = '';
  String lastName = '';
  DateTime? birthDate;
  String? nationality;
  String city = '';
  String email = '';
  Uint8List? photo;

  // Guardian
  String guardianName = '';
  String? guardianRelation;
  String guardianPhone = '';
  String guardianEmail = '';
  bool guardianConsent = false;
  DateTime? guardianRequestedAt;

  // Step 2
  String? mainPosition;
  String? subPosition;
  Set<String> secondaryPositions = {};
  String height = '';
  String weight = '';
  String? foot;
  String club = '';
  String? level;
  int experience = 0;
  bool available = true;

  // Step 3
  bool videoAdded = false;
  bool videoSkipped = false;
  String? videoName;
  int videoBytes = 0;
  int thumbnail = 0;
  bool wifiOnly = true;

  int? get age => ageFrom(birthDate);
  bool get isMinor => age != null && age! < 18;
  String get fullName => '$firstName $lastName'.trim();

  bool get generalComplete =>
      firstName.trim().isNotEmpty &&
      lastName.trim().isNotEmpty &&
      birthDate != null &&
      nationality != null &&
      city.trim().isNotEmpty &&
      isValidEmail(email);

  bool get footballComplete =>
      mainPosition != null && height.isNotEmpty && foot != null && level != null;

  /// Profile completion — the career history ("parcours") is added after
  /// onboarding, so a fully onboarded profile sits at 70 % (Figma).
  int get completion {
    var pct = 0;
    if (generalComplete) pct += 20;
    if (photo != null) pct += 10;
    if (footballComplete) pct += 30;
    if (videoAdded) pct += 10;
    return pct;
  }

  Map<String, dynamic> toJson() => {
        'stage': stage.name,
        'firstName': firstName,
        'lastName': lastName,
        'birthDate': birthDate?.toIso8601String(),
        'nationality': nationality,
        'city': city,
        'email': email,
        'photo': OnboardingStore.encodeImage(photo),
        'guardianName': guardianName,
        'guardianRelation': guardianRelation,
        'guardianPhone': guardianPhone,
        'guardianEmail': guardianEmail,
        'guardianConsent': guardianConsent,
        'guardianRequestedAt': guardianRequestedAt?.toIso8601String(),
        'mainPosition': mainPosition,
        'subPosition': subPosition,
        'secondaryPositions': secondaryPositions.toList(),
        'height': height,
        'weight': weight,
        'foot': foot,
        'club': club,
        'level': level,
        'experience': experience,
        'available': available,
        'videoAdded': videoAdded,
        'videoSkipped': videoSkipped,
        'videoName': videoName,
        'videoBytes': videoBytes,
        'thumbnail': thumbnail,
        'wifiOnly': wifiOnly,
      };

  static PlayerDraft fromJson(Map<String, dynamic> j) {
    String s(String k) => j[k] is String ? j[k] as String : '';
    String? ns(String k) => j[k] is String ? j[k] as String : null;
    bool b(String k, bool def) => j[k] is bool ? j[k] as bool : def;
    int i(String k) => j[k] is int ? j[k] as int : 0;
    DateTime? d(String k) => j[k] is String ? DateTime.tryParse(j[k] as String) : null;

    final draft = PlayerDraft()
      ..stage = PlayerStage.values.firstWhere(
        (e) => e.name == j['stage'],
        orElse: () => PlayerStage.general,
      )
      ..firstName = s('firstName')
      ..lastName = s('lastName')
      ..birthDate = d('birthDate')
      ..nationality = ns('nationality')
      ..city = s('city')
      ..email = s('email')
      ..photo = OnboardingStore.decodeImage(j['photo'])
      ..guardianName = s('guardianName')
      ..guardianRelation = ns('guardianRelation')
      ..guardianPhone = s('guardianPhone')
      ..guardianEmail = s('guardianEmail')
      ..guardianConsent = b('guardianConsent', false)
      ..guardianRequestedAt = d('guardianRequestedAt')
      ..mainPosition = ns('mainPosition')
      ..subPosition = ns('subPosition')
      ..secondaryPositions = {
        if (j['secondaryPositions'] is List)
          for (final e in j['secondaryPositions'] as List)
            if (e is String) e,
      }
      ..height = s('height')
      ..weight = s('weight')
      ..foot = ns('foot')
      ..club = s('club')
      ..level = ns('level')
      ..experience = i('experience')
      ..available = b('available', true)
      ..videoAdded = b('videoAdded', false)
      ..videoSkipped = b('videoSkipped', false)
      ..videoName = ns('videoName')
      ..videoBytes = i('videoBytes')
      ..thumbnail = i('thumbnail')
      ..wifiOnly = b('wifiOnly', true);
    return draft;
  }
}

// ---------------------------------------------------------------------------
// Search criteria (agent & club)
// ---------------------------------------------------------------------------

class SearchCriteria {
  Set<String> positions = {'ATT'};
  RangeValues ages = const RangeValues(18, 21);
  Set<String> levels = {'U21'};
  Set<String> regions = {'Cameroun'};
  bool alerts = true;

  static const double minAge = 15;
  static const double maxAge = 40;

  String get ageLabel => '${ages.start.round()}–${ages.end.round()} ans';

  String get levelsLabel => levels.isEmpty
      ? 'Tous niveaux'
      : kPlayerLevels.where(levels.contains).join(', ');

  Map<String, dynamic> toJson() => {
        'positions': positions.toList(),
        'ageMin': ages.start.round(),
        'ageMax': ages.end.round(),
        'levels': levels.toList(),
        'regions': regions.toList(),
        'alerts': alerts,
      };

  static SearchCriteria fromJson(Object? raw) {
    final c = SearchCriteria();
    if (raw is! Map) return c;
    Set<String> set(String k, Set<String> def) => raw[k] is List
        ? {for (final e in raw[k] as List) if (e is String) e}
        : def;
    c.positions = set('positions', c.positions);
    c.levels = set('levels', c.levels);
    c.regions = set('regions', c.regions);
    final min = raw['ageMin'];
    final max = raw['ageMax'];
    if (min is int && max is int && min <= max) {
      c.ages = RangeValues(
        min.toDouble().clamp(minAge, maxAge).toDouble(),
        max.toDouble().clamp(minAge, maxAge).toDouble(),
      );
    }
    if (raw['alerts'] is bool) c.alerts = raw['alerts'] as bool;
    return c;
  }

  /// Saves the criteria as default discover filters.
  Future<void> saveAsFilters(String role) =>
      OnboardingStore.save(OnboardingStore.filtersKey, {'role': role, ...toJson()});
}
