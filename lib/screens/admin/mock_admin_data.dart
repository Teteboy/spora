/// Shared mock data for the SPORA administration console.
/// Static sample lists — no real operations are performed.

class AdminVideoItem {
  const AdminVideoItem({
    required this.id,
    required this.player,
    required this.tag,
    required this.duration,
    required this.submittedAt,
    required this.status,
  });
  final String id;
  final String player;
  final String tag;
  final String duration;
  final String submittedAt;
  final String status; // 'En attente' | 'Approuvée' | 'Refusée'
}

class AdminUserRow {
  const AdminUserRow({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
    required this.verified,
    required this.premium,
    required this.joined,
  });
  final String id;
  final String name;
  final String role; // Joueur · Agent · Club · Tuteur
  final String status; // Actif · Suspendu · En revue
  final bool verified;
  final bool premium;
  final String joined;
}

class AdminReport {
  const AdminReport({
    required this.id,
    required this.reporter,
    required this.target,
    required this.reason,
    required this.date,
    required this.status,
  });
  final String id;
  final String reporter;
  final String target;
  final String reason;
  final String date;
  final String status; // Ouvert · En cours · Résolu
}

class AdminVerification {
  const AdminVerification({
    required this.id,
    required this.name,
    required this.role,
    required this.document,
    required this.submittedAt,
    required this.status,
  });
  final String id;
  final String name;
  final String role;
  final String document;
  final String submittedAt;
  final String status; // En attente · Validée · Rejetée
}

class AdminTransaction {
  const AdminTransaction({
    required this.id,
    required this.user,
    required this.label,
    required this.amount,
    required this.date,
    required this.status,
  });
  final String id;
  final String user;
  final String label;
  final String amount;
  final String date;
  final String status; // Réussie · En attente · Échouée
}

class AdminAuditEntry {
  const AdminAuditEntry({
    required this.id,
    required this.actor,
    required this.action,
    required this.target,
    required this.date,
  });
  final String id;
  final String actor;
  final String action;
  final String target;
  final String date;
}

// ── Sample lists ────────────────────────────────────────────────────────────

const adminVideos = [
  AdminVideoItem(
      id: 'VID-0301',
      player: 'Jordan Mbala',
      tag: 'Frappe extérieure · BUT',
      duration: '00:42',
      submittedAt: '15 oct. · 08:20',
      status: 'En attente'),
  AdminVideoItem(
      id: 'VID-0302',
      player: 'Kevin Njoya',
      tag: 'Passes en profondeur · PASSES',
      duration: '00:38',
      submittedAt: '15 oct. · 09:05',
      status: 'En attente'),
  AdminVideoItem(
      id: 'VID-0303',
      player: 'Samuel Kouassi',
      tag: 'Placement défensif · SKILLS',
      duration: '00:51',
      submittedAt: '15 oct. · 10:12',
      status: 'En attente'),
  AdminVideoItem(
      id: 'VID-0297',
      player: 'Awa Traoré',
      tag: 'Contre-attaque · BUT',
      duration: '00:35',
      submittedAt: '14 oct. · 18:44',
      status: 'Approuvée'),
  AdminVideoItem(
      id: 'VID-0294',
      player: 'Yannick Etoundi',
      tag: 'Tacle récupérateur · SKILLS',
      duration: '00:29',
      submittedAt: '14 oct. · 16:02',
      status: 'Refusée'),
  AdminVideoItem(
      id: 'VID-0290',
      player: 'Inès Kamdem',
      tag: 'Coup franc · BUT',
      duration: '00:33',
      submittedAt: '14 oct. · 11:27',
      status: 'Approuvée'),
];

const adminUsers = [
  AdminUserRow(
      id: 'USR-1024',
      name: 'Amina Diallo',
      role: 'Joueuse',
      status: 'Actif',
      verified: true,
      premium: true,
      joined: '03 janv. 2025'),
  AdminUserRow(
      id: 'USR-1031',
      name: 'Kevin Njoya',
      role: 'Joueur',
      status: 'Actif',
      verified: true,
      premium: false,
      joined: '12 févr. 2025'),
  AdminUserRow(
      id: 'USR-1048',
      name: 'Horizon Talent',
      role: 'Agent',
      status: 'En revue',
      verified: false,
      premium: false,
      joined: '28 août 2025'),
  AdminUserRow(
      id: 'USR-1055',
      name: 'Académie des Rives',
      role: 'Club',
      status: 'Actif',
      verified: true,
      premium: true,
      joined: '15 sept. 2025'),
  AdminUserRow(
      id: 'USR-1062',
      name: 'Malik Sarr',
      role: 'Joueur',
      status: 'Suspendu',
      verified: false,
      premium: false,
      joined: '02 oct. 2025'),
  AdminUserRow(
      id: 'USR-1070',
      name: 'Clarisse Mbappé',
      role: 'Tutrice',
      status: 'Actif',
      verified: true,
      premium: false,
      joined: '09 oct. 2025'),
];

const adminReports = [
  AdminReport(
      id: 'RPT-211',
      reporter: 'Clarisse Mbappé',
      target: 'Vidéo VID-0288',
      reason: 'Contenu inapproprié',
      date: '16 oct. · 08:12',
      status: 'Ouvert'),
  AdminReport(
      id: 'RPT-208',
      reporter: 'Kevin Njoya',
      target: 'Profil USR-1099',
      reason: 'Usurpation d\'identité',
      date: '15 oct. · 21:40',
      status: 'En cours'),
  AdminReport(
      id: 'RPT-204',
      reporter: 'Académie des Rives',
      target: 'Message MSG-7712',
      reason: 'Sollicitation abusive',
      date: '15 oct. · 14:03',
      status: 'En cours'),
  AdminReport(
      id: 'RPT-199',
      reporter: 'Jordan Mbala',
      target: 'Commentaire CMT-332',
      reason: 'Harcèlement',
      date: '14 oct. · 19:55',
      status: 'Résolu'),
  AdminReport(
      id: 'RPT-196',
      reporter: 'Awa Traoré',
      target: 'Opportunité OPP-118',
      reason: 'Annonce trompeuse',
      date: '14 oct. · 09:30',
      status: 'Résolu'),
];

const adminVerifications = [
  AdminVerification(
      id: 'VER-081',
      name: 'Horizon Talent',
      role: 'Agent',
      document: 'Licence FIFA + Kbis',
      submittedAt: 'Il y a 2 jours',
      status: 'En attente'),
  AdminVerification(
      id: 'VER-080',
      name: 'Académie des Rives',
      role: 'Club',
      document: 'Agrément fédéral',
      submittedAt: 'Il y a 18 h',
      status: 'En attente'),
  AdminVerification(
      id: 'VER-079',
      name: 'Clarisse Mbappé',
      role: 'Tutrice',
      document: 'Lien de parenté',
      submittedAt: 'Il y a 1 jour',
      status: 'En attente'),
  AdminVerification(
      id: 'VER-072',
      name: 'Samuel Kouassi',
      role: 'Joueur',
      document: 'Pièce d\'identité',
      submittedAt: '13 oct.',
      status: 'Validée'),
  AdminVerification(
      id: 'VER-068',
      name: 'Elite Scouting',
      role: 'Agent',
      document: 'Licence expirée',
      submittedAt: '12 oct.',
      status: 'Rejetée'),
];

const adminTransactions = [
  AdminTransaction(
      id: 'TXN-9021',
      user: 'Amina Diallo',
      label: 'Premium · Mensuel',
      amount: '9,99 €',
      date: '16 oct.',
      status: 'Réussie'),
  AdminTransaction(
      id: 'TXN-9018',
      user: 'Académie des Rives',
      label: 'Premium Club · Annuel',
      amount: '499,00 €',
      date: '15 oct.',
      status: 'Réussie'),
  AdminTransaction(
      id: 'TXN-9015',
      user: 'Kevin Njoya',
      label: 'Mise en avant · Highlight',
      amount: '4,99 €',
      date: '15 oct.',
      status: 'En attente'),
  AdminTransaction(
      id: 'TXN-9010',
      user: 'Malik Sarr',
      label: 'Premium · Mensuel',
      amount: '9,99 €',
      date: '14 oct.',
      status: 'Échouée'),
  AdminTransaction(
      id: 'TXN-9004',
      user: 'Inès Kamdem',
      label: 'Premium · Mensuel',
      amount: '9,99 €',
      date: '13 oct.',
      status: 'Réussie'),
];

const adminAudit = [
  AdminAuditEntry(
      id: 'AUD-5520',
      actor: 'Malik Sarr',
      action: 'Vidéo approuvée',
      target: 'VID-0284',
      date: '16 oct. · 09:38'),
  AdminAuditEntry(
      id: 'AUD-5516',
      actor: 'Amina Diallo',
      action: 'Compte suspendu',
      target: 'USR-1062',
      date: '16 oct. · 08:55'),
  AdminAuditEntry(
      id: 'AUD-5512',
      actor: 'Amina Diallo',
      action: 'Vérification rejetée',
      target: 'VER-068',
      date: '15 oct. · 17:20'),
  AdminAuditEntry(
      id: 'AUD-5508',
      actor: 'Romain Fotso',
      action: 'Signalement résolu',
      target: 'RPT-199',
      date: '15 oct. · 11:02'),
  AdminAuditEntry(
      id: 'AUD-5501',
      actor: 'Malik Sarr',
      action: 'Vidéo refusée',
      target: 'VID-0294',
      date: '14 oct. · 16:30'),
];
