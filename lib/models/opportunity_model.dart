import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Type d'opportunité — couleurs de catégorie issues des tokens Figma.
enum OpportunityType { recrutement, detection, essais, academie, tournoi }

extension OpportunityTypeX on OpportunityType {
  String get label {
    switch (this) {
      case OpportunityType.recrutement:
        return 'Recrutement';
      case OpportunityType.detection:
        return 'Détection';
      case OpportunityType.essais:
        return 'Essais';
      case OpportunityType.academie:
        return 'Académie';
      case OpportunityType.tournoi:
        return 'Tournoi';
    }
  }

  /// Libellé utilisé dans les chips de filtre ("Toutes", …).
  String get chipLabel {
    switch (this) {
      case OpportunityType.academie:
        return 'Académies';
      case OpportunityType.tournoi:
        return 'Tournois';
      default:
        return label;
    }
  }

  Color get color {
    switch (this) {
      case OpportunityType.recrutement:
        return AppColors.catRecrutement;
      case OpportunityType.detection:
        return AppColors.catDetection;
      case OpportunityType.essais:
        return AppColors.catEssais;
      case OpportunityType.academie:
        return AppColors.catAcademies;
      case OpportunityType.tournoi:
        return AppColors.catTournois;
    }
  }

  IconData get icon {
    switch (this) {
      case OpportunityType.recrutement:
        return LucideIcons.briefcase;
      case OpportunityType.detection:
        return LucideIcons.radar;
      case OpportunityType.essais:
        return LucideIcons.dumbbell;
      case OpportunityType.academie:
        return LucideIcons.graduationCap;
      case OpportunityType.tournoi:
        return LucideIcons.trophy;
    }
  }

  String get publishHint {
    switch (this) {
      case OpportunityType.detection:
        return 'Journées de découverte';
      default:
        return 'Choisir cette catégorie';
    }
  }
}

/// Cycle de vie d'une opportunité.
enum OpportunityStatus { open, closed, expired, pendingValidation, draft }

extension OpportunityStatusX on OpportunityStatus {
  String get label {
    switch (this) {
      case OpportunityStatus.open:
        return 'Ouverte';
      case OpportunityStatus.closed:
        return 'Fermée';
      case OpportunityStatus.expired:
        return 'Expirée';
      case OpportunityStatus.pendingValidation:
        return 'En validation';
      case OpportunityStatus.draft:
        return 'Brouillon';
    }
  }
}

/// Statut d'une candidature (frise de suivi).
enum ApplicationStatus { sent, viewed, shortlisted, rejected }

extension ApplicationStatusX on ApplicationStatus {
  String get label {
    switch (this) {
      case ApplicationStatus.sent:
        return 'Envoyée';
      case ApplicationStatus.viewed:
        return 'Vue';
      case ApplicationStatus.shortlisted:
        return 'Présélectionné';
      case ApplicationStatus.rejected:
        return 'Refusée';
    }
  }
}

class Opportunity {
  final String id;
  final OpportunityType type;
  final OpportunityStatus status;
  final String title;
  final String description;
  final List<String> criteria;

  // Éditeur (agent / club)
  final String publisherName;
  final String publisherRole;
  final String publisherInitials;
  final bool publisherVerified;
  final String? publisherAvatarUrl;

  // Détails
  final String city;
  final String country;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime deadline;
  final int places;
  final String fees;

  // Critères
  final int? ageMin;
  final int? ageMax;
  final String? level;
  final List<String> positions;
  final String? requiredCountry;
  final String? foot;

  final String? imageUrl;
  final bool featured;
  final bool isMine;
  final int candidatesCount;
  final int toReviewCount;

  const Opportunity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.publisherName,
    required this.publisherRole,
    required this.publisherInitials,
    required this.city,
    required this.country,
    required this.deadline,
    required this.places,
    this.status = OpportunityStatus.open,
    this.criteria = const [],
    this.publisherVerified = false,
    this.publisherAvatarUrl,
    this.startDate,
    this.endDate,
    this.fees = 'Sans frais',
    this.ageMin,
    this.ageMax,
    this.level,
    this.positions = const [],
    this.requiredCountry,
    this.foot,
    this.imageUrl,
    this.featured = false,
    this.isMine = false,
    this.candidatesCount = 0,
    this.toReviewCount = 0,
  });

  String get location =>
      country.isEmpty ? city : '$city, $country';

  String get ageRange =>
      (ageMin != null && ageMax != null) ? '$ageMin–$ageMax ans' : '';

  String get positionsLabel => positions.join(' · ');
}

/// Candidature reçue côté recruteur (écran "Candidats")
/// ou envoyée côté joueur (écran "Mes candidatures").
class OpportunityApplication {
  final String id;
  final String opportunityId;
  final String playerName;
  final String position;
  final int age;
  final String city;
  final String country;
  final String level;
  final String? avatarUrl;
  final bool verified;
  final String message;
  final String? highlightTitle;
  final String? highlightDuration;
  final String? highlightThumb;
  final ApplicationStatus status;
  final DateTime sentAt;
  final bool archived;

  const OpportunityApplication({
    required this.id,
    required this.opportunityId,
    required this.playerName,
    required this.position,
    required this.age,
    required this.city,
    required this.country,
    required this.level,
    required this.message,
    required this.status,
    required this.sentAt,
    this.avatarUrl,
    this.verified = false,
    this.highlightTitle,
    this.highlightDuration,
    this.highlightThumb,
    this.archived = false,
  });
}
