import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'admin_moderation_support.dart';
import 'admin_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _users = [
  (id: 'USR-1028', name: 'Jordan Mbala', role: 'Joueur', country: 'France', status: 'Actif', verified: 'Vérifié', premium: 'Actif · Annuel', date: '12 sept. 2026'),
  (id: 'USR-1029', name: 'Kevin Njoya', role: 'Joueur', country: 'Cameroun', status: 'Actif', verified: 'Non vérifié', premium: 'Gratuit', date: '13 sept. 2026'),
  (id: 'USR-1030', name: 'Samuel Kouassi', role: 'Joueur', country: 'Côte d’Ivoire', status: 'Actif', verified: 'Non vérifié', premium: 'Manuel', date: '14 sept. 2026'),
  (id: 'USR-1031', name: 'David Tchoupo', role: 'Joueur', country: 'Cameroun', status: 'Suspendu', verified: 'Non vérifié', premium: 'Expiré', date: '15 sept. 2026'),
  (id: 'USR-1032', name: 'Horizon Talent', role: 'Agent', country: 'Côte d’Ivoire', status: 'Actif', verified: 'En attente', premium: 'Gratuit', date: '16 sept. 2026'),
  (id: 'USR-1033', name: 'Académie des Rives', role: 'Club', country: 'Cameroun', status: 'Actif', verified: 'Vérifié', premium: 'Sans objet', date: '18 sept. 2026'),
];

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});
  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}
class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _query = '', _role = 'Rôle : Tous', _status = 'Statut : Tous';
  @override
  Widget build(BuildContext context) {
    final users = _users.where((u) => '${u.name} ${u.country} ${u.id}'.toLowerCase().contains(_query.toLowerCase()) && (_role == 'Rôle : Tous' || u.role == _role) && (_status == 'Statut : Tous' || u.status == _status)).toList();
    return ModerationPage(title: 'Utilisateurs', subtitle: '12 460 comptes · Rechercher et examiner sans modifier le rôle d’inscription.', children: [
      Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
        ModerationSearch(hint: 'Nom, organisation ou référence…', onChanged: (v) => setState(() => _query = v)),
        ModerationFilter(value: _role, options: const ['Rôle : Tous', 'Joueur', 'Agent', 'Club'], onChanged: (v) => setState(() => _role = v)),
        ModerationFilter(value: _status, options: const ['Statut : Tous', 'Actif', 'Suspendu'], onChanged: (v) => setState(() => _status = v)),
      ]),
      AdminTable(columns: const [AdminCol('Nom / pays', flex: 2), AdminCol('Rôle'), AdminCol('Statut'), AdminCol('Vérifié'), AdminCol('Premium'), AdminCol('Inscription'), AdminCol('Action')],
        onRowTap: (i) => context.push('/admin/users/${users[i].id}'), rows: [for (final u in users) [
          ModerationText('${u.name}\n${u.country}', strong: true), ModerationText(u.role),
          Align(alignment: Alignment.centerLeft, child: AdminPill(u.status, color: u.status == 'Actif' ? AppColors.clubGreen : AppColors.danger)),
          ModerationText(u.verified), ModerationText(u.premium), ModerationText(u.date), AdminLink('Voir', onTap: () => context.push('/admin/users/${u.id}')),
        ]]),
      if (users.isEmpty) const ModerationText('Aucun compte ne correspond à cette recherche.'),
      AdminPagination(summary: '1–${users.length} sur 12 460 résultats · 20 par page'),
      const AdminBanner(title: 'Le rôle d’inscription est immuable', body: 'Les actions de compte, le badge Vérifié et les droits Premium sont trois contrôles distincts.'),
    ]);
  }
}

class AdminUserDetailScreen extends StatelessWidget {
  const AdminUserDetailScreen({super.key, required this.userId});
  final String userId;
  @override
  Widget build(BuildContext context) {
    final matches = _users.where((u) => u.id == userId);
    if (matches.isEmpty) return ModerationPage(title: 'Utilisateur introuvable', subtitle: userId, children: [AdminLink('Retour aux utilisateurs', onTap: () => context.go('/admin/users'))]);
    final u = matches.first;
    return ModerationPage(title: u.name, subtitle: '$userId · ${u.role} depuis le ${u.date} · Dernière activité aujourd’hui à 09:18', children: [
      ModerationColumns(leftFlex: 1, left: AdminCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [CircleAvatar(radius: 36, backgroundColor: AppColors.primaryTint, child: Text(u.name.substring(0, 1), style: AppTextStyles.h1(color: AppColors.primary))), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(u.name, style: AppTextStyles.h1()), const SizedBox(height: 8), ModerationText('${u.role} · ${u.country}'), const ModerationText('E-mail confirmé')]))]),
        const SizedBox(height: 20), AdminPill('Rôle : ${u.role} · non modifiable'), const SizedBox(height: 16),
        const ModerationText('Identité de démonstration · Coordonnées protégées'),
      ])), right: _AccountActions(userId: userId, name: u.name, initialStatus: u.status)),
      const AdminStatGrid(cards: [AdminStatCard(label: 'Highlights', value: '12'), AdminStatCard(label: 'Vues du profil', value: '1 240'), AdminStatCard(label: 'Appareils connectés', value: '2'), AdminStatCard(label: 'Signalements', value: '2', hint: 'À examiner', hintColor: AppColors.warning)]),
      ModerationColumns(leftFlex: 1, left: AdminSection(title: 'Vérification d’identité', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AdminPill(u.verified, color: AppColors.primary), const SizedBox(height: 16), const ProtectedDocument('Justificatif d’identité'), const SizedBox(height: 16),
        AdminLink('Voir les demandes de vérification', onTap: () => context.push('/admin/verifications')),
      ])), right: AdminSection(title: 'Premium · Statut distinct', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AdminPill(u.premium, color: AppColors.goldDark), const SizedBox(height: 16), const ModerationText('Le Premium n’accorde jamais le badge Vérifié. Le rôle d’inscription ne change pas.'),
      ]))),
      AdminSection(title: 'Vidéos et historique du compte', child: AdminTable(columns: const [AdminCol('Élément'), AdminCol('Date'), AdminCol('Statut'), AdminCol('Motif / événement')], rows: [
        [const ModerationText('Frappe extérieure'), const ModerationText('15 oct. 08:20'), const AdminPill('En validation', color: AppColors.primary), AdminLink('Examen en attente', onTap: () => context.push('/admin/moderation/VID-0284'))],
        const [ModerationText('Finition en une touche'), ModerationText('12 oct. 15:02'), AdminPill('En ligne', color: AppColors.success), ModerationText('Approuvée par Malik Sarr')],
        const [ModerationText('Mise à jour du profil'), ModerationText('10 oct. 09:18'), AdminPill('Enregistrée'), ModerationText('Disponibilité : Disponible')],
      ])),
    ]);
  }
}

class _AccountActions extends StatefulWidget {
  const _AccountActions({required this.userId, required this.name, required this.initialStatus});
  final String userId, name, initialStatus;
  @override
  State<_AccountActions> createState() => _AccountActionsState();
}
class _AccountActionsState extends State<_AccountActions> {
  late String _status = widget.initialStatus;
  Future<void> _action(String action) async {
    final deleting = action == 'Supprimer';
    final suspending = action == 'Suspendre';
    final ok = await confirmModeration(context, title: '$action ${widget.name} ?',
      body: deleting ? 'Cette action lance une suppression du compte et de ses données. Elle ne peut pas être annulée après la purge.' : suspending ? 'La suspension déconnecte immédiatement tous les appareils et empêche toute nouvelle connexion. Le profil n’est plus visible.' : 'Le compte pourra se reconnecter. Le rôle, la vérification et le Premium ne changent pas.',
      confirmLabel: deleting ? 'Confirmer la suppression' : suspending ? 'Confirmer la suspension' : 'Confirmer la réactivation', destructive: action != 'Réactiver', deletion: deleting);
    if (!mounted || !ok) return;
    setState(() => _status = deleting ? 'Suppression planifiée' : suspending ? 'Suspendu' : 'Actif');
    moderationNotice(context, 'Compte ${widget.userId} : $_status');
  }
  @override
  Widget build(BuildContext context) => AdminSection(title: 'État du compte', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    AdminPill(_status, color: _status == 'Actif' ? AppColors.clubGreen : AppColors.danger), const SizedBox(height: 16),
    const ModerationText('Les actions sensibles exigent un motif et une confirmation.'), const SizedBox(height: 20),
    Wrap(spacing: 10, runSpacing: 10, children: [
      if (_status == 'Actif') AdminPrimaryButton('Suspendre le compte', icon: LucideIcons.userX, color: AppColors.errorText, onPressed: () => _action('Suspendre')),
      if (_status == 'Suspendu') AdminPrimaryButton('Réactiver', icon: LucideIcons.userPlus, onPressed: () => _action('Réactiver')),
      if (_status != 'Suppression planifiée') AdminOutlineButton('Supprimer', icon: LucideIcons.trash2, color: AppColors.errorText, onPressed: () => _action('Supprimer')),
    ]),
  ]));
}
