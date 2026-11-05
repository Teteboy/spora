import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'admin_moderation_support.dart';
import 'admin_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _opportunities = [
  (id: 'OPP-036', title: 'Détection U21 · Douala', editor: 'Académie des Rives · Vérifié', deadline: '8 nov. · 24 places', status: 'Ouverte', featured: true),
  (id: 'OPP-035', title: 'Essais Senior · Abidjan', editor: 'Horizon Talent · Non vérifié', deadline: '12 nov. · 12 places', status: 'En validation', featured: false),
  (id: 'OPP-034', title: 'Recrutement gardien', editor: 'Étoile du Littoral · Vérifié', deadline: '20 oct. · 1 place', status: 'Brouillon', featured: false),
  (id: 'OPP-033', title: 'Détection U17', editor: 'Académie des Rives', deadline: '10 oct. · Complet', status: 'Fermée', featured: false),
];

class AdminOpportunitiesScreen extends StatefulWidget {
  const AdminOpportunitiesScreen({super.key});
  @override
  State<AdminOpportunitiesScreen> createState() => _AdminOpportunitiesScreenState();
}
class _AdminOpportunitiesScreenState extends State<AdminOpportunitiesScreen> {
  int _selected = 1;
  String _query = '', _filter = 'Tous les statuts';
  final _statuses = <String, String>{};
  final _featured = <String, bool>{};
  final _reason = TextEditingController();
  @override
  void dispose() { _reason.dispose(); super.dispose(); }
  Future<void> _decide(bool approve) async {
    final item = _opportunities[_selected];
    final ok = await confirmModeration(context, title: approve ? 'Approuver cette opportunité ?' : 'Refuser cette opportunité ?', body: 'L’éditeur sera notifié de la décision. Les éléments à corriger sont transmis avec le motif.', confirmLabel: approve ? 'Approuver et notifier' : 'Refuser avec ce motif', destructive: !approve, initialReason: approve ? 'Publication conforme après revue.' : _reason.text);
    if (!mounted || !ok) return;
    setState(() => _statuses[item.id] = approve ? 'Ouverte' : 'Refusée');
    moderationNotice(context, 'Décision enregistrée pour ${item.id}');
  }
  @override
  Widget build(BuildContext context) {
    final item = _opportunities[_selected];
    final status = _statuses[item.id] ?? item.status;
    final featured = _featured[item.id] ?? item.featured;
    final visible = _opportunities.where((o) => '${o.title} ${o.editor}'.toLowerCase().contains(_query.toLowerCase()) && (_filter == 'Tous les statuts' || (_statuses[o.id] ?? o.status) == _filter)).toList();
    return ModerationPage(title: 'Opportunités', subtitle: 'Revue des publications et sélection des offres à la une.', children: [
      Wrap(spacing: 10, runSpacing: 10, children: [ModerationSearch(onChanged: (v) => setState(() => _query = v)), ModerationFilter(value: _filter, options: const ['Tous les statuts', 'Brouillon', 'En validation', 'Ouverte', 'Fermée', 'Refusée'], onChanged: (v) => setState(() => _filter = v))]),
      AdminTable(columns: const [AdminCol('Opportunité', flex: 2), AdminCol('Éditeur', flex: 2), AdminCol('Échéance / places'), AdminCol('Statut'), AdminCol('À la une'), AdminCol('Action')], rows: [for (final o in visible) [
        ModerationText(o.title, strong: true), ModerationText(o.editor), ModerationText(o.deadline),
        Align(alignment: Alignment.centerLeft, child: AdminPill(_statuses[o.id] ?? o.status, color: (_statuses[o.id] ?? o.status) == 'Ouverte' ? AppColors.clubGreen : AppColors.primary)),
        ModerationText((_featured[o.id] ?? o.featured) ? 'Oui' : 'Non'),
        AdminLink('Examiner', onTap: () => setState(() { _selected = _opportunities.indexOf(o); _reason.clear(); })),
      ]]),
      if (visible.isEmpty) const ModerationText('Aucune opportunité pour ces critères.'),
      AdminPagination(summary: '1–${visible.length} sur 36 résultats · 20 par page'),
      ModerationColumns(leftFlex: 1, left: AdminSection(title: item.title, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: 190, width: double.infinity, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: const LinearGradient(colors: [AppColors.clubGreen, AppColors.navy700])), child: const Icon(LucideIcons.goal, size: 64, color: Colors.white)),
        const SizedBox(height: 16), AdminPill(item.editor, color: AppColors.primary), const SizedBox(height: 20),
        ModerationText('${item.title}\n\nÉditeur : ${item.editor}\n\nÉchéance : ${item.deadline}\n\nStatut : $status'), const SizedBox(height: 16),
        const ModerationText('Candidature avec message et highlight. Les informations de l’offre et les droits de publication sont contrôlés avant mise en ligne.'),
      ])), right: AdminSection(title: 'Décision de publication', child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        TextField(controller: _reason, maxLines: 4, decoration: const InputDecoration(labelText: 'Motif de refus · obligatoire', hintText: 'Préciser les éléments à corriger avant publication.', border: OutlineInputBorder())), const SizedBox(height: 16),
        if (status == 'En validation') ...[
          AdminPrimaryButton('Approuver et notifier', icon: LucideIcons.check, onPressed: () => _decide(true)), const SizedBox(height: 16),
          AdminPrimaryButton('Refuser avec ce motif', icon: LucideIcons.x, color: AppColors.errorText, onPressed: () => _decide(false)),
        ] else Align(alignment: Alignment.centerLeft, child: AdminPill(status, color: AppColors.primary)),
        const SizedBox(height: 16),
        if (status == 'Ouverte') AdminOutlineButton(featured ? 'Retirer de la une' : 'Sélectionner à la une', icon: LucideIcons.star, onPressed: () {
          setState(() => _featured[item.id] = !featured);
          moderationNotice(context, featured ? 'Retirée de la une' : 'Sélectionnée à la une');
        }),
        const SizedBox(height: 16), const ModerationText('La mise à la une et son retrait sont journalisés. Fermeture automatique à l’échéance ou lorsque les places sont remplies.'),
      ]))),
    ]);
  }
}
