import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/opportunity_model.dart';

/// Helpers + données fictives partagés par les écrans Opportunités.
class OppFmt {
  static const months = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
  ];

  static String date(DateTime d) => '${d.day} ${months[d.month - 1]} ${d.year}';

  static String range(DateTime? a, DateTime? b) {
    if (a == null) return '';
    if (b == null) return date(a);
    if (a.month == b.month && a.year == b.year) {
      return '${a.day}–${b.day} ${months[a.month - 1]} ${a.year}';
    }
    return '${date(a)} – ${date(b)}';
  }
}

/// Données fictives de la maquette (offre de démonstration).
class OpportunitiesMock {
  /// Profil joueur courant utilisé pour les suggestions "Pour vous".
  static const String myPosition = 'ATT';
  static const int myAge = 19;

  /// Recruteur fictif non vérifié → affiche la note "En validation".
  static const bool publisherVerified = true;

  /// Limite gratuite : 3 candidatures / mois.
  static const int freeMonthlyLimit = 3;
  static int applicationsThisMonth = 3;

  static final DateTime _deadline = DateTime(2026, 11, 8);

  static final List<Opportunity> opportunities = [
    Opportunity(
      id: 'opp1',
      type: OpportunityType.detection,
      title: 'Détection U21 · Douala',
      description:
          'Deux journées pour évaluer votre technique, votre lecture du jeu et votre engagement dans un cadre de formation structuré.',
      criteria: const [
        'Avoir entre 18 et 21 ans',
        'Jouer au poste d’attaquant ou de milieu',
        'Présenter un profil et une vidéo à jour',
      ],
      publisherName: 'Académie des Rives',
      publisherRole: 'Académie fictive · Offre d’exemple',
      publisherInitials: 'AR',
      publisherVerified: true,
      city: 'Douala',
      country: 'Cameroun',
      startDate: DateTime(2026, 11, 14),
      endDate: DateTime(2026, 11, 15),
      deadline: _deadline,
      places: 24,
      ageMin: 18,
      ageMax: 21,
      level: 'U21',
      positions: const ['ATT', 'MIL'],
      requiredCountry: 'Tous les pays',
      foot: 'Tous les pieds',
      imageUrl: 'https://images.unsplash.com/photo-1553778263-73a83bab9b0c?w=900&h=460&fit=crop&auto=format&q=80',
      featured: true,
      candidatesCount: 24,
      toReviewCount: 8,
    ),
    Opportunity(
      id: 'opp2',
      type: OpportunityType.recrutement,
      title: 'Recrutement attaquant · D2',
      description:
          'Le FC Littoral recherche un avant-centre pour compléter son groupe professionnel dès janvier.',
      criteria: const [
        'Expérience en senior compétitif',
        'Highlight récent obligatoire',
      ],
      publisherName: 'FC Littoral',
      publisherRole: 'Club · Division 2',
      publisherInitials: 'FL',
      publisherVerified: true,
      city: 'Marseille',
      country: 'France',
      startDate: DateTime(2027, 1, 5),
      deadline: DateTime(2026, 12, 15),
      places: 2,
      ageMin: 18,
      ageMax: 26,
      level: 'Senior',
      positions: const ['ATT', 'CF'],
      requiredCountry: 'Tous les pays',
      imageUrl: 'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=900&h=460&fit=crop&auto=format&q=80',
    ),
    Opportunity(
      id: 'opp3',
      type: OpportunityType.essais,
      title: 'Essais gardiens · U19',
      description:
          'Séance d’essais dédiée aux gardiens U19 devant notre staff technique.',
      criteria: const ['Né en 2007 ou après', 'Licence en cours de validité'],
      publisherName: 'Sporting Horizon',
      publisherRole: 'Club · National',
      publisherInitials: 'SH',
      publisherVerified: false,
      city: 'Abidjan',
      country: 'Côte d’Ivoire',
      startDate: DateTime(2026, 11, 22),
      endDate: DateTime(2026, 11, 22),
      deadline: DateTime(2026, 11, 18),
      places: 8,
      ageMin: 17,
      ageMax: 19,
      level: 'U19',
      positions: const ['GAR'],
      imageUrl: 'https://images.unsplash.com/photo-1606925797300-0b35e9d1794e?w=900&h=460&fit=crop&auto=format&q=80',
    ),
    Opportunity(
      id: 'opp4',
      type: OpportunityType.academie,
      title: 'Intégration académie 2027',
      description:
          'Recrutement de la promotion 2027 : formation scolaire et sportive sur trois ans.',
      criteria: const [
        'Entre 14 et 17 ans',
        'Accord parental obligatoire pour les mineurs',
      ],
      publisherName: 'Académie des Rives',
      publisherRole: 'Académie fictive · Offre d’exemple',
      publisherInitials: 'AR',
      publisherVerified: true,
      city: 'Douala',
      country: 'Cameroun',
      startDate: DateTime(2027, 9, 1),
      deadline: DateTime(2027, 3, 31),
      places: 30,
      ageMin: 14,
      ageMax: 17,
      level: 'U15–U18',
      positions: const ['GAR', 'DEF', 'MIL', 'ATT'],
      imageUrl: 'https://images.unsplash.com/photo-1521412644187-c49fa049e84d?w=900&h=460&fit=crop&auto=format&q=80',
    ),
    Opportunity(
      id: 'opp5',
      type: OpportunityType.tournoi,
      title: 'Tournoi détection · Paris',
      description:
          'Tournoi de détection sur un week-end avec recruteurs présents en tribunes.',
      criteria: const ['Tous postes', 'Inscription par équipe ou individuelle'],
      publisherName: 'Capitol Events',
      publisherRole: 'Organisateur · Offre d’exemple',
      publisherInitials: 'CE',
      publisherVerified: false,
      city: 'Paris',
      country: 'France',
      startDate: DateTime(2026, 12, 12),
      endDate: DateTime(2026, 12, 13),
      deadline: DateTime(2026, 12, 1),
      places: 96,
      ageMin: 16,
      ageMax: 23,
      level: 'Senior / U23',
      positions: const ['GAR', 'DEF', 'MIL', 'ATT'],
      fees: 'Frais éventuels',
      imageUrl: 'https://images.unsplash.com/photo-1459865264687-595d652de67e?w=900&h=460&fit=crop&auto=format&q=80',
      status: OpportunityStatus.closed,
    ),
    // États de la maquette pour la même offre
    Opportunity(
      id: 'opp1-applied',
      type: OpportunityType.detection,
      title: 'Détection U21 · Douala',
      description:
          'Deux journées pour évaluer votre technique, votre lecture du jeu et votre engagement dans un cadre de formation structuré.',
      criteria: const [
        'Avoir entre 18 et 21 ans',
        'Jouer au poste d’attaquant ou de milieu',
        'Présenter un profil et une vidéo à jour',
      ],
      publisherName: 'Académie des Rives',
      publisherRole: 'Académie fictive · Offre d’exemple',
      publisherInitials: 'AR',
      publisherVerified: true,
      city: 'Douala',
      country: 'Cameroun',
      startDate: DateTime(2026, 11, 14),
      endDate: DateTime(2026, 11, 15),
      deadline: _deadline,
      places: 24,
      ageMin: 18,
      ageMax: 21,
      level: 'U21',
      positions: const ['ATT', 'MIL'],
      imageUrl: 'https://images.unsplash.com/photo-1517466787929-bc90951d0974?w=900&h=460&fit=crop&auto=format&q=80',
      candidatesCount: 24,
      toReviewCount: 8,
    ),
    Opportunity(
      id: 'opp1-expired',
      type: OpportunityType.detection,
      title: 'Détection U21 · Douala',
      description:
          'Deux journées pour évaluer votre technique, votre lecture du jeu et votre engagement dans un cadre de formation structuré.',
      criteria: const [
        'Avoir entre 18 et 21 ans',
        'Jouer au poste d’attaquant ou de milieu',
        'Présenter un profil et une vidéo à jour',
      ],
      publisherName: 'Académie des Rives',
      publisherRole: 'Académie fictive · Offre d’exemple',
      publisherInitials: 'AR',
      publisherVerified: true,
      city: 'Douala',
      country: 'Cameroun',
      startDate: DateTime(2026, 10, 14),
      endDate: DateTime(2026, 10, 15),
      deadline: DateTime(2026, 10, 8),
      places: 24,
      ageMin: 18,
      ageMax: 21,
      level: 'U21',
      positions: const ['ATT', 'MIL'],
      status: OpportunityStatus.expired,
      imageUrl: 'https://images.unsplash.com/photo-1526232761682-d26e03ac148e?w=900&h=460&fit=crop&auto=format&q=80',
    ),
  ];

  /// Opportunités publiées par l'utilisateur (écran "Mes opportunités").
  static final List<Opportunity> mine = [
    Opportunity(
      id: 'mine1',
      type: OpportunityType.detection,
      title: 'Détection U21 · Douala',
      description:
          'Deux journées pour évaluer votre technique, votre lecture du jeu et votre engagement.',
      publisherName: 'Académie des Rives',
      publisherRole: 'Académie fictive · Offre d’exemple',
      publisherInitials: 'AR',
      publisherVerified: true,
      city: 'Douala',
      country: 'Cameroun',
      startDate: DateTime(2026, 11, 14),
      endDate: DateTime(2026, 11, 15),
      deadline: _deadline,
      places: 24,
      ageMin: 18,
      ageMax: 21,
      positions: const ['ATT', 'MIL'],
      isMine: true,
      candidatesCount: 24,
      toReviewCount: 8,
    ),
    Opportunity(
      id: 'mine2',
      type: OpportunityType.detection,
      title: 'Détection U21 · Douala',
      description: 'Session de rattrapage.',
      publisherName: 'Académie des Rives',
      publisherRole: 'Académie fictive · Offre d’exemple',
      publisherInitials: 'AR',
      publisherVerified: true,
      city: 'Douala',
      country: 'Cameroun',
      startDate: DateTime(2026, 10, 10),
      endDate: DateTime(2026, 10, 11),
      deadline: DateTime(2026, 10, 5),
      places: 24,
      ageMin: 18,
      ageMax: 21,
      positions: const ['ATT', 'MIL'],
      status: OpportunityStatus.closed,
      isMine: true,
      candidatesCount: 17,
    ),
    Opportunity(
      id: 'mine3',
      type: OpportunityType.detection,
      title: 'Détection U21 · Douala',
      description: 'Brouillon en cours de rédaction.',
      publisherName: 'Académie des Rives',
      publisherRole: 'Académie fictive · Offre d’exemple',
      publisherInitials: 'AR',
      publisherVerified: true,
      city: 'Douala',
      country: 'Cameroun',
      startDate: DateTime(2026, 12, 14),
      endDate: DateTime(2026, 12, 15),
      deadline: DateTime(2026, 12, 8),
      places: 24,
      ageMin: 18,
      ageMax: 21,
      positions: const ['ATT', 'MIL'],
      status: OpportunityStatus.draft,
      isMine: true,
    ),
    Opportunity(
      id: 'mine4',
      type: OpportunityType.recrutement,
      title: 'Recrutement milieu · Pré-saison',
      description: 'En attente de validation par l’équipe SPORA.',
      publisherName: 'Académie des Rives',
      publisherRole: 'Académie fictive · Offre d’exemple',
      publisherInitials: 'AR',
      publisherVerified: false,
      city: 'Douala',
      country: 'Cameroun',
      deadline: DateTime(2027, 1, 10),
      places: 4,
      positions: const ['MIL'],
      status: OpportunityStatus.pendingValidation,
      isMine: true,
    ),
  ];

  static final List<OpportunityApplication> applications = [
    OpportunityApplication(
      id: 'app1',
      opportunityId: 'opp1',
      playerName: 'Jordan Mbala',
      position: 'Attaquant',
      age: 19,
      city: 'Paris',
      country: 'France',
      level: 'U21',
      avatarUrl: 'https://i.pravatar.cc/150?u=jordan_mbala',
      verified: true,
      message:
          'Bonjour, je suis Jordan Mbala, attaquant au Paris FC U21. Je souhaite participer à votre détection et vous présenter mon jeu.',
      highlightTitle: 'Frappe depuis l’extérieur',
      highlightDuration: '00:42',
      highlightThumb: 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=640&h=360&fit=crop&auto=format&q=80',
      status: ApplicationStatus.sent,
      sentAt: DateTime(2026, 10, 16, 9, 30),
    ),
    OpportunityApplication(
      id: 'app2',
      opportunityId: 'opp1',
      playerName: 'Kevin Njoya',
      position: 'Milieu',
      age: 21,
      city: 'Douala',
      country: 'Cameroun',
      level: 'Senior',
      avatarUrl: 'https://i.pravatar.cc/150?u=kevin_njoya',
      verified: true,
      message:
          'Milieu box-to-box disponible les deux journées. Mon highlight résume ma saison 2025–2026.',
      highlightTitle: 'Compilation saison 2025',
      highlightDuration: '01:10',
      highlightThumb: 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=640&h=360&fit=crop&auto=format&q=80',
      status: ApplicationStatus.viewed,
      sentAt: DateTime(2026, 10, 16, 11, 5),
    ),
    OpportunityApplication(
      id: 'app3',
      opportunityId: 'opp1',
      playerName: 'Amadou Diallo',
      position: 'Attaquant',
      age: 20,
      city: 'Nantes',
      country: 'France',
      level: 'Senior',
      avatarUrl: 'https://i.pravatar.cc/150?u=amadou_d',
      verified: false,
      message:
          'Attaquant de surface, 28 buts en D1 cette saison. Disponible à Douala.',
      highlightTitle: 'Mes 10 meilleurs buts',
      highlightDuration: '00:58',
      highlightThumb: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=640&h=360&fit=crop&auto=format&q=80',
      status: ApplicationStatus.shortlisted,
      sentAt: DateTime(2026, 10, 15, 18, 42),
    ),
    OpportunityApplication(
      id: 'app4',
      opportunityId: 'opp1',
      playerName: 'Théo Bernard',
      position: 'Milieu',
      age: 19,
      city: 'Lyon',
      country: 'France',
      level: 'U21',
      avatarUrl: 'https://i.pravatar.cc/150?u=theo_b',
      verified: false,
      message: 'Milieu relayeur, ambidextre. Je joins ma compilation 2026.',
      highlightTitle: 'Compilation 2026',
      highlightDuration: '01:32',
      highlightThumb: 'https://images.unsplash.com/photo-1560272564-c83b66b1ad12?w=640&h=360&fit=crop&auto=format&q=80',
      status: ApplicationStatus.rejected,
      sentAt: DateTime(2026, 10, 14, 8, 12),
    ),
  ];

  /// Highlights du joueur courant (picker de la candidature).
  static const List<Map<String, String>> myHighlights = [
    {
      'title': 'Frappe depuis l’extérieur',
      'duration': '00:42',
      'thumb': 'https://images.unsplash.com/photo-1553778263-73a83bab9b0c?w=640&h=360&fit=crop&auto=format&q=80',
    },
    {
      'title': 'Compilation 2026',
      'duration': '01:12',
      'thumb': 'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=640&h=360&fit=crop&auto=format&q=80',
    },
    {
      'title': 'Face au gardien',
      'duration': '00:35',
      'thumb': 'https://images.unsplash.com/photo-1606925797300-0b35e9d1794e?w=640&h=360&fit=crop&auto=format&q=80',
    },
  ];

  static Opportunity? byId(String id) {
    for (final o in [...opportunities, ...mine]) {
      if (o.id == id) return o;
    }
    return null;
  }
}

/// Petite pastille (statut, type, critère).
class OppChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  final bool outlined;
  final IconData? icon;

  const OppChip({
    super.key,
    required this.label,
    this.color = AppColors.muted,
    this.textColor,
    this.outlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final fg = textColor ?? color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: outlined ? Colors.white : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: outlined
            ? Border.all(color: AppColors.border)
            : Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.caption(color: fg)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Bouton principal dégradé bleu → indigo.
class OppGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool enabled;

  const OppGradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.muted,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        ),
        child: Center(
          child: Text(label,
              style: AppTextStyles.button(color: AppColors.textMuted)),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.primaryGradient),
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: AppShadows.glowBrand,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(label, style: AppTextStyles.button()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Carte blanche standard (radius 16, ombre elev-1).
class OppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const OppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.lg),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.elev1,
      ),
      padding: padding,
      child: child,
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        child: card,
      ),
    );
  }
}
