import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'admin_widgets.dart';

/// A17 — Journal d'audit (append-only, lecture seule).
class AuditLogScreen extends StatelessWidget {
  const AuditLogScreen({super.key});

  static const List<(String, String, String, String, String)> _events = [
    ('16 oct. 09:35', 'Amina Diallo', 'Ouvrir une revue', 'VID-0284',
        'Modération en attente'),
    ('16 oct. 09:32', 'Amina Diallo', 'Consulter des pièces', 'VER-012',
        'Revue de vérification'),
    ('16 oct. 09:20', 'Malik Sarr', 'Masquer un profil', 'M-102',
        'Retrait du consentement'),
    ('15 oct. 17:10', 'Malik Sarr', 'Attribuer Premium', 'USR-1126',
        'Pilote autorisé'),
    ('15 oct. 11:10', 'Malik Sarr', 'Réviser une décision', 'VID-0270',
        'Autorisation reçue'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdminPageHeader(
              title: 'Journal d’audit',
              subtitle:
                  'Journal en lecture seule · Ajout uniquement · Conservation proposée : 24 mois.',
              trailing: Text('17 sept. – 16 oct. 2026'),
            ),
            const SizedBox(height: AppDimens.section),
            const Wrap(
              spacing: AppDimens.md,
              runSpacing: AppDimens.md,
              children: [
                AdminSearchField(hint: 'Acteur, référence, motif…'),
                AdminFilter('Acteur'),
                AdminFilter('Action'),
                AdminFilter('Type de cible'),
                AdminFilter('Période'),
              ],
            ),
            const SizedBox(height: AppDimens.lg),
            const AdminBanner(
              title: 'Lecture seule · journal append-only',
              body:
                  'Les décisions corrigées créent un nouvel événement. Aucun événement antérieur n’est modifié ou supprimé.',
            ),
            const SizedBox(height: AppDimens.lg),
            AdminTable(
              columns: const [
                AdminCol('Date / heure'),
                AdminCol('Acteur'),
                AdminCol('Action'),
                AdminCol('Cible'),
                AdminCol('Motif'),
                AdminCol('Détail'),
              ],
              rows: [
                for (final e in _events)
                  [
                    Text(e.$1, style: AppTextStyles.body()),
                    Text(e.$2, style: AppTextStyles.bodyStrong()),
                    Text(e.$3, style: AppTextStyles.body()),
                    Text(e.$4, style: AppTextStyles.body()),
                    Text(e.$5, style: AppTextStyles.body()),
                    const AdminLink('Consulter'),
                  ],
              ],
            ),
            const AdminPagination(
                summary: '1–5 sur 1 284 résultats · 20 par page'),
            const SizedBox(height: AppDimens.section),
            AdminSection(
              title: 'Événement AUD-1282 · Attribution Premium',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                            'Acteur : Malik Sarr\nDate : 15 octobre 2026, 17:10\nCible : USR-1126 · Samuel Kouassi',
                            style: AppTextStyles.body(
                                color: AppColors.textPrimary)),
                      ),
                      const SizedBox(width: AppDimens.xl),
                      Expanded(
                        child: Text(
                            'Action : attribution manuelle\nMotif : pilote autorisé\nEffet : Premium actif jusqu’au 30 nov.',
                            style: AppTextStyles.body(
                                color: AppColors.textPrimary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.lg),
                  Text(
                      'Entrée non modifiable · Référence de décision : PRM-0061 · Conservation 24 mois proposée, validation juridique en attente.',
                      style: AppTextStyles.caption()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
