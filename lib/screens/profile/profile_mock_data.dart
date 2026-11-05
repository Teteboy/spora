import '../../models/player_model.dart';
import '../../models/user_model.dart';

/// Feature-local mock data for the Profile screens (fictitious demo content
/// matching the Figma frames).
class ProfileMockData {
  /// Jordan Mbala — the player featured in the design frames.
  static final PlayerModel jordan = PlayerModel(
    id: 'jordan_mbala',
    firstName: 'Jordan',
    lastName: 'Mbala',
    avatarUrl: 'https://i.pravatar.cc/200?u=jordan_mbala',
    age: 19,
    nationality: 'France',
    city: 'Paris',
    primaryPosition: 'Attaquant (ATT)',
    height: 1.82,
    weight: 74,
    dominantFoot: 'Droit',
    currentClub: 'Paris FC U21',
    leagueDivision: 'U21',
    yearsOfExperience: 6,
    subscription: SubscriptionType.premium,
    profileViews: 248,
    followers: 96,
    rating: 8.4,
    isVerified: true,
    stats: const PlayerStats(matchesPlayed: 34, goals: 21, assists: 7),
    highlights: [
      VideoModel(
        id: 'hj1',
        title: 'Frappe du droit',
        description: '',
        thumbnailUrl: 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=400&h=225&fit=crop&auto=format&q=80',
        views: 2400,
        likes: 246,
        uploadDate: DateTime(2026, 10, 2),
        playerId: 'jordan_mbala',
        playerName: 'Jordan Mbala',
      ),
      VideoModel(
        id: 'hj2',
        title: 'Appel en profondeur',
        description: '',
        thumbnailUrl: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=400&h=225&fit=crop&auto=format&q=80',
        views: 2400,
        likes: 246,
        uploadDate: DateTime(2026, 9, 20),
        playerId: 'jordan_mbala',
        playerName: 'Jordan Mbala',
      ),
      VideoModel(
        id: 'hj3',
        title: 'Finition en une touche',
        description: '',
        thumbnailUrl: 'https://images.unsplash.com/photo-1560272564-c83b66b1ad12?w=400&h=225&fit=crop&auto=format&q=80',
        views: 2400,
        likes: 246,
        uploadDate: DateTime(2026, 9, 12),
        playerId: 'jordan_mbala',
        playerName: 'Jordan Mbala',
      ),
      VideoModel(
        id: 'hj4',
        title: 'Jeu dos au but',
        description: '',
        thumbnailUrl: 'https://images.unsplash.com/photo-1553778263-73a83bab9b0c?w=400&h=225&fit=crop&auto=format&q=80',
        views: 2400,
        likes: 246,
        uploadDate: DateTime(2026, 8, 30),
        playerId: 'jordan_mbala',
        playerName: 'Jordan Mbala',
      ),
    ],
  );

  /// Under-18 demo player (Profil protégé).
  static final PlayerModel minor = PlayerModel(
    id: 'u17_demo',
    firstName: 'Joueur',
    lastName: 'U17',
    age: 16,
    nationality: 'France',
    city: '',
    primaryPosition: 'Attaquant (ATT)',
    height: 1.76,
    weight: 66,
    dominantFoot: 'Droit',
    currentClub: '',
    leagueDivision: 'U17',
    yearsOfExperience: 3,
    stats: const PlayerStats(),
  );

  static const String jordanHeadline = 'Un attaquant décisif';
  static const String jordanBio =
      'Appels en profondeur, finition et jeu dos au but.';
  static const String jordanObjective =
      'Rejoindre un projet ambitieux et franchir un cap au niveau professionnel.';

  /// Club history, newest first.
  static const List<ClubCareerEntry> jordanCareer = [
    ClubCareerEntry(
      title: 'Paris FC U21',
      period: '2025 — Aujourd’hui',
      detail: 'U21 · France',
      isCurrent: true,
    ),
    ClubCareerEntry(
      title: 'Formation régionale',
      period: '2023 — 2025',
      detail: 'U19 · France',
    ),
    ClubCareerEntry(
      title: 'Débuts en club',
      period: '2021 — 2023',
      detail: 'U17 · France',
    ),
  ];

  /// Agent demo (Nadia Mensah).
  static const AgentProfileData agent = AgentProfileData(
    initials: 'NM',
    name: 'Nadia Mensah',
    agency: 'Horizon Talent',
    activity: 'Représentation sportive',
    country: 'Côte d’Ivoire',
    yearsExperience: 8,
    license: 'Licence de démonstration · HT-2026-014',
    about:
        'J’accompagne les joueurs dans leur développement et leur projet de carrière. Horizon Talent privilégie un suivi transparent, de la formation aux premières opportunités professionnelles.',
    players: [
      RepresentedPlayer(
        name: 'Jordan Mbala',
        line1: 'Attaquant · 19 ans · France',
        line2: 'Paris · U21',
        avatarUrl: 'https://i.pravatar.cc/100?u=jordan_mbala',
      ),
      RepresentedPlayer(
        name: 'Kevin Njoya',
        line1: 'Milieu · 21 ans · Cameroun',
        line2: 'Douala · Senior',
        avatarUrl: 'https://i.pravatar.cc/100?u=kevin_njoya',
      ),
    ],
    playersCount: 12,
    opportunity: OpportunitySummary(
      category: 'Détection',
      title: 'Détection U21 · Douala',
      dates: '14–15 novembre 2026 · Académie des Rives',
      meta: 'Clôture le 8 novembre · Sans frais · Exemple fictif',
    ),
  );

  /// Club demo (Académie des Rives).
  static const ClubProfileData club = ClubProfileData(
    initials: 'AR',
    name: 'Académie des Rives',
    type: 'Académie de formation',
    city: 'Douala',
    country: 'Cameroun',
    levels: 'U21 · Senior',
    about:
        'Nous accompagnons les jeunes talents dans leur progression sportive et scolaire. Notre académie fictive propose un cadre de formation structuré à Douala.',
    sought: ['ATT', 'MIL', '18–21 ans'],
    soughtDetail:
        'Niveau U21 · 24 places · Joueurs disponibles pour une détection.',
    opportunity: OpportunitySummary(
      category: 'Détection',
      title: 'Détection U21 · Douala',
      dates: '14–15 novembre 2026 · Académie des Rives',
      meta: 'Clôture le 8 novembre · Sans frais · Exemple fictif',
    ),
  );

  /// Private shortlist demo (Ma liste).
  static List<ShortlistEntry> shortlist() => [
        const ShortlistEntry(
          name: 'Jordan Mbala',
          line1: 'Attaquant · 19 ans · France',
          line2: 'Paris · U21',
          avatarUrl: 'https://i.pravatar.cc/100?u=jordan_mbala',
          note: 'Finition précise, à revoir sur un match complet.',
        ),
        const ShortlistEntry(
          name: 'Kevin Njoya',
          line1: 'Milieu · 21 ans · Cameroun',
          line2: 'Douala · Senior',
          avatarUrl: 'https://i.pravatar.cc/100?u=kevin_njoya',
          note: 'Bon pied gauche, contacter après visionnage.',
        ),
        const ShortlistEntry(
          name: 'Samuel Kouassi',
          line1: 'Défenseur · 20 ans · Abidjan · Senior',
        ),
      ];
}

class ClubCareerEntry {
  final String title;
  final String period;
  final String detail;
  final bool isCurrent;
  const ClubCareerEntry({
    required this.title,
    required this.period,
    required this.detail,
    this.isCurrent = false,
  });
}

class RepresentedPlayer {
  final String name;
  final String line1;
  final String line2;
  final String? avatarUrl;
  const RepresentedPlayer({
    required this.name,
    required this.line1,
    required this.line2,
    this.avatarUrl,
  });
}

class OpportunitySummary {
  final String category;
  final String title;
  final String dates;
  final String meta;
  const OpportunitySummary({
    required this.category,
    required this.title,
    required this.dates,
    required this.meta,
  });
}

class AgentProfileData {
  final String initials;
  final String name;
  final String agency;
  final String activity;
  final String country;
  final int yearsExperience;
  final String license;
  final String about;
  final List<RepresentedPlayer> players;
  final int playersCount;
  final OpportunitySummary opportunity;
  const AgentProfileData({
    required this.initials,
    required this.name,
    required this.agency,
    required this.activity,
    required this.country,
    required this.yearsExperience,
    required this.license,
    required this.about,
    required this.players,
    required this.playersCount,
    required this.opportunity,
  });
}

class ClubProfileData {
  final String initials;
  final String name;
  final String type;
  final String city;
  final String country;
  final String levels;
  final String about;
  final List<String> sought;
  final String soughtDetail;
  final OpportunitySummary opportunity;
  const ClubProfileData({
    required this.initials,
    required this.name,
    required this.type,
    required this.city,
    required this.country,
    required this.levels,
    required this.about,
    required this.sought,
    required this.soughtDetail,
    required this.opportunity,
  });
}

class ShortlistEntry {
  final String name;
  final String line1;
  final String? line2;
  final String? avatarUrl;
  final String? note;
  const ShortlistEntry({
    required this.name,
    required this.line1,
    this.line2,
    this.avatarUrl,
    this.note,
  });

  ShortlistEntry copyWith({String? note}) => ShortlistEntry(
        name: name,
        line1: line1,
        line2: line2,
        avatarUrl: avatarUrl,
        note: note ?? this.note,
      );
}
