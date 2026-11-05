import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'admin_moderation_support.dart';
import 'admin_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _requests = [
  (id: 'VER-012', name: 'Horizon Talent · Nadia Mensah', role: 'Agent · Côte d’Ivoire', date: '14 oct. 09:05 · 2 j'),
  (id: 'VER-013', name: 'Académie des Rives', role: 'Club · Cameroun', date: '15 oct. 15:20 · 18 h'),
  (id: 'VER-014', name: 'Étoile du Littoral', role: 'Club · Côte d’Ivoire', date: '16 oct. 07:10 · 2 h'),
];

class VerificationsScreen extends StatefulWidget {
  const VerificationsScreen({super.key});
  @override
  State<VerificationsScreen> createState() => _VerificationsScreenState();
}
class _VerificationsScreenState extends State<VerificationsScreen> {
  int _selected = 0;
  String _query = '';
  final _statuses = <String, String>{};
  final _reason = TextEditingController(text: 'La preuve de rôle n’est pas suffisamment lisible.');
  @override
  void dispose() { _reason.dispose(); super.dispose(); }
  Future<void> _decide(bool approve) async {
    final request = _requests[_selected];
    final ok = await confirmModeration(context, title: approve ? 'Approuver cette demande ?' : 'Refuser cette demande ?',
      body: 'Le demandeur sera notifié. La décision concerne uniquement le badge Vérifié, pas le Premium.',
      confirmLabel: approve ? 'Approuver et notifier' : 'Refuser avec ce motif', destructive: !approve,
      initialReason: approve ? 'Identité et rôle confirmés.' : _reason.text);
    if (!mounted || !ok) return;
    setState(() => _statuses[request.id] = approve ? 'Approuvée' : 'Refusée');
    moderationNotice(context, 'Décision enregistrée : ${request.id}');
  }
  @override
  Widget build(BuildContext context) {
    final request = _requests[_selected];
    final visible = _requests.where((r) => '${r.name} ${r.id}'.toLowerCase().contains(_query.toLowerCase())).toList();
    return ModerationPage(title: 'Vérifications', subtitle: '12 demandes en attente · Pièces réservées aux personnes habilitées.', children: [
      Wrap(spacing: 10, runSpacing: 10, children: [ModerationSearch(onChanged: (v) => setState(() => _query = v)), const AdminFilter('En attente'), const AdminFilter('Agent / Club'), const AdminFilter('Ancienneté')]),
      AdminTable(columns: const [AdminCol('Demande', flex: 2), AdminCol('Rôle / pays'), AdminCol('Soumission'), AdminCol('Statut'), AdminCol('Action')], rows: [for (final r in visible) [
        ModerationText(r.name, strong: true), ModerationText(r.role), ModerationText(r.date),
        Align(alignment: Alignment.centerLeft, child: AdminPill(_statuses[r.id] ?? 'En attente', color: AppColors.primary)),
        AdminLink('Examiner', onTap: () => setState(() => _selected = _requests.indexOf(r))),
      ]]),
      AdminPagination(summary: '1–${visible.length} sur 12 résultats · 20 par page'),
      ModerationColumns(left: AdminSection(title: '${request.name} · ${request.id}', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AdminPill('${request.role} · Compte actif', color: AppColors.primary), const SizedBox(height: 20),
        const Row(children: [Expanded(child: ProtectedDocument('Pièce d’identité')), SizedBox(width: 16), Expanded(child: ProtectedDocument('Preuve de rôle'))]),
        const SizedBox(height: 16), const ModerationText('Accès aux documents journalisé. Aucun document d’identité réel dans cette maquette.'),
      ])), right: AdminSection(title: 'Contrôles du dossier', child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const ModerationText('✓ Identité cohérente avec le compte\n\n✓ Pièce lisible et valide\n\n□ Preuve du rôle à confirmer'), const SizedBox(height: 20),
        TextField(controller: _reason, maxLines: 4, decoration: const InputDecoration(labelText: 'Motif de refus · obligatoire', border: OutlineInputBorder())), const SizedBox(height: 16),
        if (_statuses.containsKey(request.id)) AdminPill(_statuses[request.id]!, color: AppColors.primary)
        else ...[AdminPrimaryButton('Approuver et notifier', icon: LucideIcons.check, onPressed: () => _decide(true)), const SizedBox(height: 12), AdminPrimaryButton('Refuser avec ce motif', icon: LucideIcons.x, color: AppColors.errorText, onPressed: () => _decide(false))],
        const SizedBox(height: 16), const ModerationText('Chaque décision est auditée. Le motif de refus est transmis au demandeur.'),
      ]))),
      AdminBanner(title: 'Historique du dossier', body: '${request.date} : soumission · 16 oct. 09:32 : ouverture par Amina Diallo. ${_statuses[request.id] ?? 'Aucune décision enregistrée.'}'),
    ]);
  }
}
