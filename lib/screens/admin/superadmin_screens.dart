import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'admin_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Superadmin / Gouvernance screens S01–S06 (proposition de gouvernance).
///
/// Classes:
/// - [SuperOverviewScreen]   /admin/super              (S01 vue globale)
/// - [SuperTeamScreen]       /admin/super/team         (S02 équipe et accès)
/// - [SuperRolesScreen]      /admin/super/roles        (S03 rôles et permissions)
/// - [SuperConfigScreen]     /admin/super/config       (S04 configuration et limites)
/// - [SuperIntegrationsScreen] /admin/super/integrations (S05 intégrations)
/// - [SuperSecurityScreen]   /admin/super/security     (S06 sécurité et conformité)

// ── Shared ──────────────────────────────────────────────────────────────────

class _ProposalBanner extends StatelessWidget {
  const _ProposalBanner();

  @override
  Widget build(BuildContext context) {
    return const AdminBanner(
      title: 'Proposition de permissions — à valider',
      body:
          'Le SRS définit le rôle administrateur. La séparation superadmin présentée ici est une proposition de gouvernance.',
    );
  }
}

Widget _page({required String title, required String subtitle,
    required List<Widget> children, bool banner = true}) {
  return Scaffold(
    backgroundColor: AppColors.appBg,
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (banner) ...[
            const _ProposalBanner(),
            const SizedBox(height: AppDimens.section),
          ],
          AdminPageHeader(
            title: title,
            subtitle: subtitle,
            trailing: const Text('17 sept. – 16 oct. 2026'),
          ),
          const SizedBox(height: AppDimens.section),
          ...children,
        ],
      ),
    ),
  );
}

Widget _twoCol(Widget left, Widget right, {int leftFlex = 1, int rightFlex = 1}) {
  return LayoutBuilder(builder: (context, c) {
    if (c.maxWidth <= 1000) {
      return Column(children: [
        left,
        const SizedBox(height: AppDimens.lg),
        right,
      ]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: leftFlex, child: left),
        const SizedBox(width: AppDimens.lg),
        Expanded(flex: rightFlex, child: right),
      ],
    );
  });
}

Widget _alertTile(IconData icon, Color color, String title, String body) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppDimens.lg),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(AppDimens.radiusCard),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: AppDimens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyStrong(color: color)),
              const SizedBox(height: AppDimens.xs),
              Text(body, style: AppTextStyles.body()),
            ],
          ),
        ),
      ],
    ),
  );
}

// ── S01 · Vue globale ───────────────────────────────────────────────────────

class SuperOverviewScreen extends StatelessWidget {
  const SuperOverviewScreen({super.key});

  static const List<double> _chart = [
    0.55, 0.72, 0.62, 0.85, 0.75, 0.92, 0.82, 1.0, 0.90, 0.97, 0.88, 1.0,
  ];

  @override
  Widget build(BuildContext context) {
    return _page(
      title: 'Vue globale superadmin',
      subtitle: 'Pilotage transversal : santé, revenus, risques et gouvernance.',
      children: [
        const AdminStatGrid(cards: [
          AdminStatCard(
              label: 'Disponibilité API · démo',
              value: '99,72 %',
              hint: 'Objectif proposé · 99,5 %'),
          AdminStatCard(
              label: 'Actifs / inscrits',
              value: '8 420 / 12 460',
              hint: 'Engagement · 67,6 %'),
          AdminStatCard(
              label: 'Revenus encaissés',
              value: '2,48 M XAF',
              hint: '386 paiements réussis'),
          AdminStatCard(
              label: 'Dossiers sensibles',
              value: '2 urgents',
              hint: '4 membres habilités · 2FA active',
              hintColor: AppColors.warning),
        ]),
        const SizedBox(height: AppDimens.section),
        _twoCol(
          AdminSection(
            title: 'Engagement et revenus · 30 jours',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('Revenus encaissés · XAF',
                      style:
                          AppTextStyles.body(color: AppColors.primary)),
                  const Spacer(),
                  Text('Période précédente +12,8 %',
                      style: AppTextStyles.caption()),
                ]),
                const SizedBox(height: AppDimens.lg),
                SizedBox(
                  height: 150,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < _chart.length; i++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppDimens.xs),
                            child: FractionallySizedBox(
                              heightFactor: _chart[i],
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(6)),
                                  color: i == _chart.length - 1
                                      ? null
                                      : AppColors.primaryTint,
                                  gradient: i == _chart.length - 1
                                      ? const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors:
                                              AppColors.primaryGradient)
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.sm),
                Row(children: [
                  for (var i = 1; i <= 12; i++)
                    Expanded(
                        child: Center(
                            child:
                                Text('$i', style: AppTextStyles.micro()))),
                ]),
                const SizedBox(height: AppDimens.sm),
                Row(children: [
                  Text('17 sept.', style: AppTextStyles.caption()),
                  const Spacer(),
                  Text('1 oct.', style: AppTextStyles.caption()),
                  const Spacer(),
                  Text('16 oct. 2026', style: AppTextStyles.caption()),
                ]),
              ],
            ),
          ),
          Column(children: [
            AdminSection(
              title: 'Points d’attention',
              child: Column(children: [
                _alertTile(LucideIcons.shield, AppColors.danger,
                    'Paiements MTN · 3 à rapprocher',
                    'Vérifier les références prestataire, sans rejouer de débit.'),
                const SizedBox(height: AppDimens.md),
                _alertTile(LucideIcons.info, AppColors.primary,
                    'Traitement vidéo ralenti',
                    '16 éléments en file · 3 reprises · plus ancien : 12 min'),
                const SizedBox(height: AppDimens.md),
                _alertTile(LucideIcons.shield, AppColors.danger,
                    'Accès inhabituel détecté',
                    'Nouvel appareil personnel · session à examiner.'),
                const SizedBox(height: AppDimens.lg),
                const SizedBox(
                  width: double.infinity,
                  child: AdminPrimaryButton('Ouvrir les opérations',
                      icon: LucideIcons.arrowRight),
                ),
              ]),
            ),
            const SizedBox(height: AppDimens.lg),
            AdminSection(
              title: 'Capacité et gouvernance',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('428 Go / 1 To',
                      style:
                          AppTextStyles.display().copyWith(fontSize: 22)),
                  const SizedBox(height: AppDimens.sm),
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusPill),
                    child: const LinearProgressIndicator(
                        value: 0.428,
                        minHeight: 8,
                        backgroundColor: AppColors.muted,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: AppDimens.md),
                  Text('Sauvegarde du 16 oct. · 02:00 · Réussie',
                      style: AppTextStyles.body()),
                  const SizedBox(height: AppDimens.lg),
                  const SizedBox(
                      width: double.infinity,
                      child: AdminOutlineButton('Équipe et permissions',
                          icon: LucideIcons.arrowRight)),
                  const SizedBox(height: AppDimens.md),
                  const SizedBox(
                      width: double.infinity,
                      child: AdminOutlineButton('Configuration et limites',
                          icon: LucideIcons.arrowRight)),
                ],
              ),
            ),
          ]),
          leftFlex: 3,
          rightFlex: 2,
        ),
        const SizedBox(height: AppDimens.section),
        AdminTable(
          columns: const [
            AdminCol('Membre'),
            AdminCol('Décisions · période'),
            AdminCol('Dernière action', flex: 2),
            AdminCol('Sécurité'),
          ],
          rows: [
            for (final r in const [
              ('Amina Diallo', '186', 'Ouverture VID-0284 · 09:35'),
              ('Malik Sarr', '214', 'Masquage M-102 · 09:20'),
              ('Claire Ndiaye', '172', 'Vérification VER-010 · 08:50'),
            ])
              [
                Text(r.$1, style: AppTextStyles.bodyStrong()),
                Text(r.$2, style: AppTextStyles.body()),
                Text(r.$3, style: AppTextStyles.body()),
                Text('2FA active',
                    style: AppTextStyles.body(color: AppColors.primary)),
              ],
          ],
        ),
        const AdminPagination(summary: '1–3 sur 4 résultats · 20 par page'),
      ],
    );
  }
}

// ── S02 · Équipe et accès ───────────────────────────────────────────────────

class SuperTeamScreen extends StatelessWidget {
  const SuperTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _page(
      title: 'Équipe et accès',
      subtitle:
          'Périmètre de gouvernance proposé · Accès selon le principe du moindre privilège.',
      children: [
        Row(children: [
          const Expanded(
            child: Wrap(
              spacing: AppDimens.md,
              runSpacing: AppDimens.md,
              children: [
                AdminSearchField(),
                AdminFilter('Statut'),
                AdminFilter('Périmètre'),
                AdminFilter('2FA'),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.md),
          const AdminPrimaryButton('Inviter un administrateur',
              icon: LucideIcons.plus),
        ]),
        const SizedBox(height: AppDimens.section),
        AdminTable(
          columns: const [
            AdminCol('Membre'),
            AdminCol('Rôle proposé'),
            AdminCol('Périmètre', flex: 2),
            AdminCol('2FA'),
            AdminCol('Statut / session'),
            AdminCol('Action'),
          ],
          rows: [
            _member('Amina Diallo', 'Superadmin',
                'Gouvernance et opérations', 'Obligatoire · Active',
                'Active · 09:41', 'Voir'),
            _member('Malik Sarr', 'Admin', 'Modération, utilisateurs',
                'Obligatoire · Active', 'Actif · 09:20', 'Voir'),
            _member('Claire Ndiaye', 'Admin', 'Vérification, signalements',
                'Obligatoire · Active', 'Active · 08:50', 'Voir'),
            _member('Nora Sow', 'Admin', 'Finance en lecture',
                'À activer avant accès', 'Invitation envoyée', 'Renvoyer'),
          ],
        ),
        const AdminPagination(summary: '1–4 sur 4 résultats · 20 par page'),
        const SizedBox(height: AppDimens.section),
        _twoCol(
          AdminSection(
            title: 'Inviter un administrateur',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AdminField(
                    label: 'E-mail professionnel',
                    value: 'nora.sow@spora.example'),
                const SizedBox(height: AppDimens.lg),
                const AdminField(
                    label: 'Périmètre proposé',
                    value: 'Finance · lecture et export uniquement'),
                const SizedBox(height: AppDimens.lg),
                const AdminBanner(
                  title: '2FA obligatoire avant tout accès',
                  body:
                      'L’invitation n’accorde pas de session tant que la double authentification n’est pas activée.',
                ),
                const SizedBox(height: AppDimens.lg),
                const AdminPrimaryButton('Vérifier puis envoyer l’invitation',
                    icon: LucideIcons.send),
              ],
            ),
          ),
          AdminSection(
            title: 'Révoquer l’accès de Malik Sarr ?',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'L’accès administratif est retiré immédiatement et toutes ses sessions d’administration sont déconnectées.',
                    style: AppTextStyles.body()),
                const SizedBox(height: AppDimens.lg),
                const AdminField(
                    label: 'Motif obligatoire',
                    value: 'Fin d’habilitation à la modération.',
                    maxLines: 3),
                const SizedBox(height: AppDimens.lg),
                Wrap(spacing: AppDimens.md, children: [
                  const AdminOutlineButton('Annuler'),
                  AdminPrimaryButton('Révoquer accès et sessions',
                      icon: LucideIcons.ban, color: AppColors.danger),
                ]),
                const SizedBox(height: AppDimens.md),
                Text(
                    'Confirmation sensible · Vérification 2FA requise · Entrée d’audit créée.',
                    style: AppTextStyles.caption()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static List<Widget> _member(String name, String role, String scope,
      String mfa, String status, String action) {
    return [
      Text(name, style: AppTextStyles.bodyStrong()),
      Text(role, style: AppTextStyles.body()),
      Text(scope, style: AppTextStyles.body()),
      Text(mfa, style: AppTextStyles.body()),
      Text(status, style: AppTextStyles.body()),
      AdminLink(action),
    ];
  }
}

// ── S03 · Rôles et permissions ──────────────────────────────────────────────

class SuperRolesScreen extends StatelessWidget {
  const SuperRolesScreen({super.key});

  static const List<(String, String, String, String)> _perms = [
    ('Modération vidéos', 'Examiner / décider', 'Examiner / réviser',
        'Motif + audit'),
    ('Utilisateurs / Premium', 'Gérer / suspendre / attribuer',
        'Gérer / contrôler', 'Rôle utilisateur immuable'),
    ('Vérification / signalements', 'Examiner / résoudre',
        'Examiner / escalader', 'Pièces protégées'),
    ('Finance', 'Lire / exporter si autorisé', 'Lire / exporter',
        'Aucun remboursement inventé'),
    ('Audit', 'Lire son périmètre', 'Lire tous les événements',
        'Lecture seule'),
    ('Équipe / permissions', 'Aucun accès', 'Inviter / révoquer / habiliter',
        'Confirmation + 2FA'),
    ('Configuration / limites', 'Lecture si autorisée',
        'Proposer / confirmer', 'Audit + contrôle serveur'),
    ('Intégrations / opérations', 'État en lecture',
        'Proposer une modification', 'Secrets jamais exposés'),
  ];

  @override
  Widget build(BuildContext context) {
    return _page(
      title: 'Rôles et permissions',
      subtitle:
          'Périmètre de gouvernance proposé · Accès selon le principe du moindre privilège.',
      children: [
        const AdminBanner(
          title: 'Répartition proposée, pas une définition du SRS',
          body:
              'Admin conserve les capacités FR-ADM selon son périmètre. Superadmin gère les habilitations, la configuration et les intégrations.',
        ),
        const SizedBox(height: AppDimens.lg),
        AdminTable(
          columns: const [
            AdminCol('Capacité', flex: 2),
            AdminCol('Admin · selon périmètre', flex: 2),
            AdminCol('Superadmin · proposé', flex: 2),
            AdminCol('Condition', flex: 2),
          ],
          rows: [
            for (final p in _perms)
              [
                Text(p.$1, style: AppTextStyles.bodyStrong()),
                Text(p.$2, style: AppTextStyles.body()),
                Text(p.$3, style: AppTextStyles.body()),
                Text(p.$4,
                    style: AppTextStyles.body(color: AppColors.primary)),
              ],
          ],
        ),
        const AdminPagination(summary: '1–8 sur 8 résultats · 20 par page'),
        const SizedBox(height: AppDimens.section),
        _twoCol(
          AdminSection(
            title: 'Protection du dernier superadmin',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _alertTile(
                    LucideIcons.shield,
                    AppColors.danger,
                    'Retrait bloqué',
                    'Vous ne pouvez pas retirer le dernier compte superadmin actif. Désignez un autre responsable habilité avant de poursuivre.'),
                const SizedBox(height: AppDimens.lg),
                const AdminOutlineButton('Retirer ce dernier accès'),
              ],
            ),
          ),
          AdminSection(
            title: 'Confirmer un changement sensible',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AdminField(
                    label: 'Permission modifiée',
                    value: 'Nora Sow · Autoriser l’export financier'),
                const SizedBox(height: AppDimens.lg),
                const AdminField(
                    label: 'Motif requis',
                    value: 'Mission de rapprochement mensuel validée.'),
                const SizedBox(height: AppDimens.lg),
                const AdminField(label: 'Code 2FA', value: '–  –  –  –  –  –'),
                const SizedBox(height: AppDimens.lg),
                const AdminPrimaryButton('Confirmer les permissions',
                    icon: LucideIcons.check),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── S04 · Configuration et limites ──────────────────────────────────────────

class SuperConfigScreen extends StatelessWidget {
  const SuperConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _page(
      title: 'Configuration et limites',
      subtitle:
          'Périmètre de gouvernance proposé · Accès selon le principe du moindre privilège.',
      children: [
        _twoCol(
          AdminSection(
            title: 'Limites du compte gratuit',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AdminField(label: 'Highlights publiés', value: '1'),
                const SizedBox(height: AppDimens.lg),
                const AdminField(
                    label: 'Candidatures / mois · proposition',
                    value: '3 · À valider par le client'),
                const SizedBox(height: AppDimens.lg),
                const AdminField(
                    label: 'Taille d’upload max · proposition',
                    value: '250 Mo · À valider'),
                const SizedBox(height: AppDimens.lg),
                const AdminField(
                    label: 'Longueur vidéo max · proposition',
                    value: '90 s · À valider'),
                const SizedBox(height: AppDimens.lg),
                const AdminField(
                    label:
                        'Nouvelles conversations / jour · agent gratuit',
                    value: 'À définir'),
                const SizedBox(height: AppDimens.lg),
                Text('Premium : highlights et candidatures illimités.',
                    style: AppTextStyles.body()),
                const SizedBox(height: AppDimens.md),
                const AdminBanner(
                  title: 'Application des règles côté serveur',
                  body:
                      'Les clients Flutter et React ne peuvent pas contourner les quotas. Les changements sont centralisés dans l’API.',
                ),
              ],
            ),
          ),
          AdminSection(
            title: 'Formules et modération',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AdminField(
                    label: 'Prix mensuel', value: 'X FCFA / mois'),
                const SizedBox(height: AppDimens.lg),
                const AdminField(
                    label: 'Prix annuel', value: 'X FCFA / an'),
                const SizedBox(height: AppDimens.lg),
                const AdminField(
                    label: 'Politique vidéo MVP',
                    value: 'Toutes les vidéos passent en revue · Activé'),
                const SizedBox(height: AppDimens.lg),
                const _ToggleRow(
                    label:
                        'Publication automatique des joueurs vérifiés',
                    value: false),
                const _ToggleRow(
                    label: 'Mode maintenance', value: false),
                const SizedBox(height: AppDimens.lg),
                const AdminBanner(
                  title: 'MVP : revue de toutes les vidéos',
                  body:
                      'La publication automatique des joueurs vérifiés n’est pas activée par défaut.',
                ),
                const SizedBox(height: AppDimens.md),
                Text(
                    'Tarifs, taxes et conditions de renouvellement à valider. Aucun prix officiel inventé.',
                    style: AppTextStyles.caption()),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimens.section),
        AdminSection(
          title: 'Fonctionnalités par version',
          child: AdminTable(
            columns: const [
              AdminCol('Fonctionnalité', flex: 2),
              AdminCol('Version cible'),
              AdminCol('État proposé'),
              AdminCol('Effet', flex: 2),
            ],
            rows: [
              for (final f in const [
                ('Profils / recherche / modération', 'MVP', 'Activé',
                    'Socle de lancement'),
                ('Premium manuel', 'MVP', 'Activé', 'FR-PRM-003'),
                ('Paiements / notifications / analytics', 'V1',
                    'Désactivé hors démo', 'Validation avant activation'),
                ('Opportunités / commentaires / anglais complet', 'V2',
                    'Désactivé hors démo', 'Validation avant activation'),
              ])
                [
                  Text(f.$1, style: AppTextStyles.bodyStrong()),
                  Text(f.$2, style: AppTextStyles.body()),
                  Text(f.$3, style: AppTextStyles.body()),
                  Text(f.$4,
                      style:
                          AppTextStyles.body(color: AppColors.primary)),
                ],
            ],
          ),
        ),
        const AdminPagination(summary: '1–4 sur 4 résultats · 20 par page'),
        const SizedBox(height: AppDimens.section),
        AdminSection(
          title: 'Aperçu avant confirmation',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Changement proposé : candidatures gratuites 3 / mois → 3 / mois. Aucun changement appliqué.',
                  style:
                      AppTextStyles.body(color: AppColors.textPrimary)),
              const SizedBox(height: AppDimens.lg),
              const AdminField(
                  label: 'Motif obligatoire',
                  value:
                      'Validation de la politique des limites pour le pilote.'),
              const SizedBox(height: AppDimens.lg),
              const Wrap(spacing: AppDimens.md, children: [
                AdminOutlineButton('Prévisualiser les impacts'),
                AdminPrimaryButton('Confirmer avec 2FA',
                    icon: LucideIcons.check),
              ]),
              const SizedBox(height: AppDimens.md),
              Text(
                  'Maquette de configuration uniquement · Modification proposée, audit et contrôle serveur à implémenter.',
                  style: AppTextStyles.caption()),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatefulWidget {
  const _ToggleRow({required this.label, required this.value});
  final String label;
  final bool value;

  @override
  State<_ToggleRow> createState() => _ToggleRowState();
}

class _ToggleRowState extends State<_ToggleRow> {
  late bool _v = widget.value;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Text(widget.label, style: AppTextStyles.body())),
      Switch(
          value: _v,
          activeTrackColor: AppColors.primary,
          onChanged: (v) => setState(() => _v = v)),
    ]);
  }
}

// ── S05 · Intégrations et opérations ────────────────────────────────────────

class SuperIntegrationsScreen extends StatelessWidget {
  const SuperIntegrationsScreen({super.key});

  static const List<(String, String, Color, String, String)> _services = [
    ('API REST', 'Opérationnel', AppColors.success, '16 oct. 09:40',
        'P95 · 284 ms'),
    ('PostgreSQL', 'Opérationnel', AppColors.success, '16 oct. 09:40',
        'Connexions · 24 / 100'),
    ('Stockage privé S3/R2', 'Opérationnel', AppColors.success,
        '16 oct. 09:39', '428 Go · 42,8 %'),
    ('Traitement vidéo', 'Retard observé', AppColors.warning,
        '16 oct. 09:38', '16 en file · 3 reprises'),
    ('FCM / APNS', 'Opérationnel', AppColors.success, '16 oct. 09:40',
        'Dernière remise · 09:40'),
    ('E-mail transactionnel', 'Opérationnel', AppColors.success,
        '16 oct. 09:36', 'Dernier envoi · 09:36'),
    ('Orange Money', 'Opérationnel', AppColors.success, '16 oct. 09:35',
        'Webhook rapproché'),
    ('MTN Mobile Money', 'À surveiller', AppColors.warning,
        '16 oct. 09:32', '3 rapprochements en attente'),
    ('Stripe', 'Opérationnel', AppColors.success, '16 oct. 09:38',
        'Webhook confirmé'),
  ];

  @override
  Widget build(BuildContext context) {
    return _page(
      title: 'Intégrations et opérations',
      subtitle:
          'Périmètre de gouvernance proposé · Accès selon le principe du moindre privilège.',
      children: [
        const Wrap(
          spacing: AppDimens.md,
          runSpacing: AppDimens.md,
          children: [
            AdminSearchField(),
            AdminFilter('Tous les services'),
            AdminFilter('Dernières 24 heures'),
            AdminFilter('Incidents ouverts'),
          ],
        ),
        const SizedBox(height: AppDimens.section),
        AdminTable(
          columns: const [
            AdminCol('Service', flex: 2),
            AdminCol('Santé de démonstration'),
            AdminCol('Dernier événement'),
            AdminCol('Capacité / file', flex: 2),
          ],
          rows: [
            for (final s in _services)
              [
                Text(s.$1, style: AppTextStyles.bodyStrong()),
                Align(
                    alignment: Alignment.centerLeft,
                    child: AdminPill(s.$2, color: s.$3)),
                Text(s.$4, style: AppTextStyles.body()),
                Text(s.$5,
                    style: AppTextStyles.body(color: AppColors.primary)),
              ],
          ],
        ),
        const AdminPagination(summary: '1–9 sur 9 résultats · 20 par page'),
        const SizedBox(height: AppDimens.section),
        _twoCol(
          AdminSection(
            title: 'Sauvegardes et restauration',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                    alignment: Alignment.centerLeft,
                    child: AdminPill('Sauvegarde quotidienne · Réussie',
                        color: AppColors.success)),
                const SizedBox(height: AppDimens.lg),
                for (final l in const [
                  'Dernière : 16 octobre 2026 à 02:00',
                  'Rétention : 14 jours · Chiffrée, hors serveur',
                  'Objectifs proposés : RPO 24 h · RTO 4 h',
                  'Exercice de restauration trimestriel à planifier.',
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.sm),
                    child: Text(l, style: AppTextStyles.body()),
                  ),
                const SizedBox(height: AppDimens.sm),
                const AdminField(
                    label: 'Identifiants d’intégration',
                    value: '••••••••••• · Gérés côté serveur'),
              ],
            ),
          ),
          AdminSection(
            title: 'Incidents et maintenance',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                    alignment: Alignment.centerLeft,
                    child: AdminPill('INC-012 · Traitement ralenti',
                        color: AppColors.danger)),
                const SizedBox(height: AppDimens.lg),
                Text(
                    '16 vidéos en file · 3 en reprise · aucun arrêt de navigation.',
                    style: AppTextStyles.body()),
                const SizedBox(height: AppDimens.lg),
                const AdminField(
                    label: 'Proposition de maintenance',
                    value:
                        'Analyser la capacité du worker et planifier une intervention.',
                    maxLines: 3),
                const SizedBox(height: AppDimens.lg),
                const AdminOutlineButton('Préparer une proposition'),
                const SizedBox(height: AppDimens.md),
                Text(
                    'Aucun redémarrage ni changement réel en un clic. Toute modification demande une revue et un audit.',
                    style: AppTextStyles.caption()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── S06 · Sécurité et conformité ────────────────────────────────────────────

class SuperSecurityScreen extends StatelessWidget {
  const SuperSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _page(
      title: 'Sécurité et conformité',
      subtitle:
          'Périmètre de gouvernance proposé · Accès selon le principe du moindre privilège.',
      children: [
        const AdminStatGrid(cards: [
          AdminStatCard(
              label: 'Personnel protégé par 2FA',
              value: '3 / 3',
              hint: 'Une invitation sans accès'),
          AdminStatCard(
              label: 'Sessions à examiner',
              value: '1',
              hint: 'Nouvel appareil détecté',
              hintColor: AppColors.warning),
          AdminStatCard(
              label: 'Demandes de confidentialité',
              value: '7',
              hint: '2 exports · 5 suppressions'),
        ]),
        const SizedBox(height: AppDimens.section),
        _twoCol(
          AdminSection(
            title: 'Sessions et accès suspects',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Amina Diallo · Navigateur actuel',
                    style: AppTextStyles.bodyStrong()),
                const SizedBox(height: AppDimens.xs),
                Text('Chrome · 16 oct. 09:00 · Session 2FA validée',
                    style: AppTextStyles.body()),
                const SizedBox(height: AppDimens.lg),
                _alertTile(
                    LucideIcons.shield,
                    AppColors.danger,
                    'Nouvel appareil · Malik Sarr',
                    '15 oct. 22:18 · Accès inhabituel à examiner. Aucun secret ni jeton visible.'),
                const SizedBox(height: AppDimens.lg),
                const _ToggleRow(
                    label: 'Exiger la 2FA pour tout le personnel',
                    value: true),
                const _ToggleRow(
                    label: 'Restreindre aux IP autorisées (allowlist)',
                    value: false),
                const SizedBox(height: AppDimens.md),
                const AdminOutlineButton('Examiner / révoquer la session'),
                const SizedBox(height: AppDimens.md),
                const AdminLink('Consulter l’audit en lecture seule'),
              ],
            ),
          ),
          AdminSection(
            title: 'Versions légales',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Conditions d’utilisation · v1.0 · En revue',
                    style: AppTextStyles.body()),
                const SizedBox(height: AppDimens.sm),
                Text('Politique de confidentialité · v1.0 · En revue',
                    style: AppTextStyles.body()),
                const SizedBox(height: AppDimens.lg),
                const AdminBanner(
                  title: 'Politique mineurs : approbation en attente',
                  body:
                      'Base légale, preuve et retrait du consentement à valider avec le conseil juridique.',
                ),
                const SizedBox(height: AppDimens.lg),
                Text(
                    'Aucune publication juridique validée dans cette maquette.',
                    style: AppTextStyles.body()),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimens.section),
        AdminTable(
          columns: const [
            AdminCol('Demande', flex: 2),
            AdminCol('Type'),
            AdminCol('Reçue le'),
            AdminCol('Échéance'),
            AdminCol('État'),
            AdminCol('Action'),
          ],
          rows: [
            _dcp('DCP-007 · Compte adulte', 'Export', '15 oct. 10:00',
                '14 nov. 2026', 'En préparation', 'Examiner'),
            _dcp('DCP-006 · Titulaire confirmé', 'Suppression',
                '15 oct. 14:00', '14 nov. · Données 30 j',
                'Vidéos : avant 16 oct. 14 h', 'Examiner'),
            _dcp('DCP-005 · Tuteur', 'Suppression mineur', '15 oct. 18:10',
                'Après contrôle de la demande', 'Preuve à vérifier',
                'Accès protégé'),
          ],
        ),
        const AdminPagination(summary: '1–3 sur 7 résultats · 20 par page'),
        const SizedBox(height: AppDimens.section),
        const AdminBanner(
          title: 'Délais de confidentialité',
          body:
              'Suppression des vidéos sous 24 h et des données personnelles sous 30 jours après validation. Conservation comptable et rétentions légales à valider. Audit consultable, jamais modifiable.',
        ),
      ],
    );
  }

  static List<Widget> _dcp(String demande, String type, String recue,
      String echeance, String etat, String action) {
    return [
      Text(demande, style: AppTextStyles.bodyStrong()),
      Text(type, style: AppTextStyles.body()),
      Text(recue, style: AppTextStyles.body()),
      Text(echeance, style: AppTextStyles.body()),
      Text(etat, style: AppTextStyles.body()),
      AdminLink(action),
    ];
  }
}
