import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'admin_moderation_support.dart';
import 'admin_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _records = [
  (id: 'M-104', age: 16, consent: 'Version 1.0 · 10 oct. 2026', visibility: 'Recruteurs vérifiés uniquement', request: 'Revue urgente', guardian: 'Tuteur vérifié · identité protégée'),
  (id: 'M-103', age: 17, consent: 'En attente · non enregistré', visibility: 'Masqué', request: 'Relance du consentement', guardian: 'Tuteur en attente de vérification'),
  (id: 'M-102', age: 15, consent: 'Retiré le 15 oct. 2026', visibility: 'Masqué', request: 'Suppression par tuteur', guardian: 'Tuteur vérifié · identité protégée'),
];

class MinorsScreen extends StatefulWidget {
  const MinorsScreen({super.key});
  @override
  State<MinorsScreen> createState() => _MinorsScreenState();
}
class _MinorsScreenState extends State<MinorsScreen> {
  int _selected = 0;
  String _query = '';
  final _hidden = <String>{};
  final _reason = TextEditingController(text: 'Vérification du consentement après signalement.');
  @override
  void dispose() { _reason.dispose(); super.dispose(); }
  Future<void> _hide() async {
    final id = _records[_selected].id;
    final ok = await confirmModeration(context, title: 'Masquer immédiatement le profil ?', body: 'Le profil $id ne sera plus visible pendant la revue de sécurité. Les coordonnées du mineur restent protégées.', confirmLabel: 'Confirmer le masquage', initialReason: _reason.text);
    if (!mounted || !ok) return;
    setState(() => _hidden.add(id));
    moderationNotice(context, 'Profil $id masqué');
  }
  @override
  Widget build(BuildContext context) {
    final r = _records[_selected];
    final visible = _records.where((r) => '${r.id} ${r.request}'.toLowerCase().contains(_query.toLowerCase())).toList();
    return ModerationPage(title: 'Protection des mineurs', subtitle: '4 dossiers prioritaires · Consentement, visibilité et demandes des tuteurs.', children: [
      Wrap(spacing: 10, runSpacing: 10, children: [ModerationSearch(onChanged: (v) => setState(() => _query = v)), const AdminFilter('Consentement'), const AdminFilter('Visibilité'), const AdminFilter('Urgence')]),
      const AdminBanner(title: 'M-104 · Revue urgente de sécurité', body: 'Profil mineur signalé. Le masquage immédiat est disponible sans attendre la fin de l’enquête.', color: AppColors.danger, icon: LucideIcons.shield),
      AdminTable(columns: const [AdminCol('Dossier protégé'), AdminCol('Consentement'), AdminCol('Tuteur'), AdminCol('Visibilité'), AdminCol('Demande'), AdminCol('Action')], rows: [for (final record in visible) [
        ModerationText('${record.id} · Joueur ${record.age} ans', strong: true), ModerationText(record.consent), ModerationText(record.guardian), ModerationText(_hidden.contains(record.id) ? 'Masqué' : record.visibility), ModerationText(record.request),
        AdminLink('Examiner', onTap: () => setState(() => _selected = _records.indexOf(record))),
      ]]),
      AdminPagination(summary: '1–${visible.length} sur 4 résultats · 20 par page'),
      const AdminSection(title: 'Tentatives de contact signalées', child: Column(children: [
        AdminBanner(title: 'M-104 · Demande de coordonnées personnelles', body: '15 oct. 16:17 · Tentative de contact hors plateforme signalée. Téléphone, e-mail et localisation exacte ne sont jamais exposés.', color: AppColors.warning, icon: LucideIcons.alertTriangle),
        SizedBox(height: 12), AdminBanner(title: 'M-103 · Contact non autorisé bloqué', body: '16 oct. 07:10 · Compte non vérifié. Accès restreint et revue de sécurité en attente.', color: AppColors.warning, icon: LucideIcons.alertTriangle),
      ])),
      ModerationColumns(leftFlex: 1, left: AdminSection(title: '${r.id} · Visibilité et consentement', child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Align(alignment: Alignment.centerLeft, child: AdminPill('Mineur · Coordonnées protégées', color: AppColors.primary)), const SizedBox(height: 16),
        ModerationText('Consentement : ${r.consent}\n\n${r.guardian}\n\nProfil réservé aux agents et clubs vérifiés.\n\nTéléphone, e-mail et localisation exacte exclus des vues ordinaires.'), const SizedBox(height: 20),
        TextField(controller: _reason, maxLines: 4, decoration: const InputDecoration(labelText: 'Motif du masquage immédiat', border: OutlineInputBorder())), const SizedBox(height: 16),
        if (_hidden.contains(r.id) || r.visibility == 'Masqué') const AdminPill('Profil masqué', color: AppColors.danger)
        else AdminPrimaryButton('Masquer immédiatement le profil', icon: LucideIcons.eyeOff, color: AppColors.errorText, onPressed: _hide),
      ])), right: AdminSection(title: 'Demandes des tuteurs', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const ModerationText('M-102 · Suppression demandée', strong: true), const SizedBox(height: 16),
        const ModerationText('Reçue le 15 octobre à 18:10 · Identité du demandeur à vérifier par accès protégé.\n\nVidéos : retrait sous 24 h après validation. Données personnelles : sous 30 jours.'), const SizedBox(height: 16),
        AdminPrimaryButton('Examiner la demande protégée', icon: LucideIcons.lock, onPressed: () => setState(() => _selected = 2)), const SizedBox(height: 16),
        const AdminField(label: 'Note de suivi', value: 'Contrôle juridique et preuve du lien à valider.', maxLines: 4), const SizedBox(height: 16),
        const ModerationText('Processus du tuteur et politique mineurs en attente de validation juridique. Chaque consultation est tracée.'),
      ]))),
    ]);
  }
}
