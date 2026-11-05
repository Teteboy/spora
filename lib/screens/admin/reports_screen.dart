import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import 'admin_moderation_support.dart';
import 'admin_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _reports = [
  (id: 'SIG-018', target: 'VID-0284', type: 'Vidéo', priority: 'Normale', reporter: 'Kevin Njoya', status: 'Ouvert', date: '16 oct. 08:05', detail: 'Contenu potentiellement non autorisé. Les droits de diffusion sont à vérifier.'),
  (id: 'SIG-017', target: 'PRF-0632', type: 'Profil', priority: 'Urgente', reporter: 'Utilisateur protégé', status: 'En revue', date: '16 oct. 07:10', detail: 'Identité du profil contestée. Vérifier les justificatifs par accès protégé.'),
  (id: 'SIG-016', target: 'COM-0821', type: 'Commentaire', priority: 'Normale', reporter: 'Samuel Kouassi', status: 'Ouvert', date: '15 oct. 17:20', detail: 'Commentaire signalé comme inapproprié. Aucun autre échange chargé.'),
  (id: 'SIG-015', target: 'CON-0392', type: 'Conversation signalée', priority: 'Élevée', reporter: 'Le destinataire', status: 'En revue', date: '15 oct. 16:18', detail: '« Envoyez votre numéro personnel pour poursuivre la discussion hors de la plateforme. »'),
];

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});
  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}
class _AdminReportsScreenState extends State<AdminReportsScreen> {
  int _selected = 3;
  bool _expanded = true;
  String _query = '', _status = 'Statut : Tous';
  final _resolved = <String>{};
  final _note = TextEditingController();
  final _form = GlobalKey<FormState>();
  @override
  void dispose() { _note.dispose(); super.dispose(); }
  Future<void> _resolve() async {
    if (!_form.currentState!.validate()) return;
    final id = _reports[_selected].id;
    final ok = await confirmModeration(context, title: 'Résoudre le dossier $id ?', body: 'La note et la décision seront conservées dans le journal d’audit.', confirmLabel: 'Marquer résolu', destructive: false, initialReason: _note.text);
    if (!mounted || !ok) return;
    setState(() => _resolved.add(id));
    moderationNotice(context, 'Dossier $id résolu');
  }
  @override
  Widget build(BuildContext context) {
    final r = _reports[_selected];
    final visible = _reports.where((r) => '${r.id} ${r.target} ${r.type} ${r.reporter}'.toLowerCase().contains(_query.toLowerCase()) && (_status == 'Statut : Tous' || (_resolved.contains(r.id) ? 'Résolu' : r.status) == _status)).toList();
    return ModerationPage(title: 'Signalements', subtitle: '18 dossiers ouverts · Examiner le contexte nécessaire, jamais toute une messagerie.', children: [
      Wrap(spacing: 10, runSpacing: 10, children: [ModerationSearch(onChanged: (v) => setState(() => _query = v)), ModerationFilter(value: _status, options: const ['Statut : Tous', 'Ouvert', 'En revue', 'Résolu'], onChanged: (v) => setState(() => _status = v))]),
      AdminTable(columns: const [AdminCol('Dossier / cible'), AdminCol('Type'), AdminCol('Signalé par'), AdminCol('Priorité'), AdminCol('Date / statut'), AdminCol('Action')], rows: [for (final report in visible) [
        ModerationText('${report.id} · ${report.target}', strong: true), ModerationText(report.type), ModerationText(report.reporter),
        Align(alignment: Alignment.centerLeft, child: AdminPill(report.priority, color: report.priority == 'Normale' ? AppColors.textSecondary : AppColors.danger)),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ModerationText(report.date), AdminPill(_resolved.contains(report.id) ? 'Résolu' : report.status, color: _resolved.contains(report.id) ? AppColors.success : AppColors.primary)]),
        AdminLink('Examiner', onTap: () => setState(() { _selected = _reports.indexOf(report); _expanded = true; _note.clear(); })),
      ]]),
      AdminPagination(summary: '1–${visible.length} sur 18 résultats · 20 par page'),
      AdminOutlineButton(_expanded ? 'Réduire le détail' : 'Développer le détail', icon: _expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown, onPressed: () => setState(() => _expanded = !_expanded)),
      if (_expanded) ModerationColumns(left: AdminSection(title: '${r.id} · ${r.type}', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AdminPill(r.type == 'Conversation signalée' ? 'Sollicitation de coordonnées' : 'Contenu signalé', color: AppColors.danger), const SizedBox(height: 16),
        const AdminBanner(title: 'Accès limité au contexte signalé', body: 'Seul le message signalé et son contexte immédiat sont présentés. Aucun accès libre aux conversations privées.'), const SizedBox(height: 20),
        ModerationText('${r.date} · Signalé par ${r.reporter}'), const SizedBox(height: 16),
        AdminCard(color: AppColors.appBg, child: ModerationText(r.detail)), const SizedBox(height: 16),
        AdminLink('Ouvrir le profil concerné', onTap: () => context.push('/admin/users/USR-1028')),
      ])), right: AdminSection(title: 'Résoudre le dossier', child: Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        TextFormField(controller: _note, maxLines: 5, decoration: const InputDecoration(labelText: 'Note de résolution · obligatoire', border: OutlineInputBorder()), validator: (v) => v == null || v.trim().isEmpty ? 'Une note de résolution est requise.' : null), const SizedBox(height: 16),
        if (_resolved.contains(r.id)) const AdminPill('Résolu', color: AppColors.success)
        else AdminPrimaryButton('Marquer résolu', icon: LucideIcons.check, onPressed: _resolve),
        const SizedBox(height: 16), const ModerationText('Cible, motif, acteur et date restent dans l’audit.'),
      ])))),
    ]);
  }
}
