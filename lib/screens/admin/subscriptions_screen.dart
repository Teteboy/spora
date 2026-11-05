import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'admin_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A15 — Abonnements et Premium.
class AdminSubscriptionsScreen extends StatelessWidget {
  const AdminSubscriptionsScreen({super.key});

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
              title: 'Abonnements et Premium',
              subtitle:
                  'Droits payants et attributions manuelles, distincts de la vérification.',
              trailing: Text('17 sept. – 16 oct. 2026'),
            ),
            const SizedBox(height: AppDimens.section),
            const AdminStatGrid(cards: [
              AdminStatCard(
                  label: 'Actifs',
                  value: '412',
                  hint: 'Dont 18 attributions manuelles'),
              AdminStatCard(
                  label: 'Annulés · encore actifs',
                  value: '26',
                  hint: 'Jusqu’à la fin de période'),
              AdminStatCard(
                  label: 'Expirés',
                  value: '84',
                  hint: 'Vidéos supplémentaires masquées'),
            ]),
            const SizedBox(height: AppDimens.section),
            const Wrap(
              spacing: AppDimens.md,
              runSpacing: AppDimens.md,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AdminSearchField(),
                AdminFilter('Actif'),
                AdminFilter('Annulé'),
                AdminFilter('Expiré'),
                AdminFilter('Attribution manuelle'),
                AdminFilter('Fin de période'),
              ],
            ),
            const SizedBox(height: AppDimens.section),
            AdminTable(
              columns: const [
                AdminCol('Compte'),
                AdminCol('Origine / formule'),
                AdminCol('Statut'),
                AdminCol('Fin de période'),
                AdminCol('Vidéos'),
                AdminCol('Action'),
              ],
              rows: [
                _row('Jordan Mbala', 'Paiement · Annuel', 'Actif',
                    AppColors.success, '12 sept. 2027', '12 visibles'),
                _row('Kevin Njoya', 'Paiement · Mensuel', 'Annulé',
                    AppColors.warning, '31 oct. 2026',
                    '4 visibles jusqu’au terme'),
                _row('Samuel Kouassi', 'Attribution manuelle', 'Actif',
                    AppColors.success, '30 nov. 2026', '3 visibles'),
                _row('David Tchoupo', 'Paiement · Mensuel', 'Expiré',
                    AppColors.textMuted, '12 oct. 2026',
                    '1 visible · 3 masquées'),
              ],
            ),
            const AdminPagination(
                summary: '1–4 sur 522 résultats · 20 par page'),
            const SizedBox(height: AppDimens.section),
            LayoutBuilder(builder: (context, c) {
              final wide = c.maxWidth > 1000;
              const grant = _GrantRevokeCard();
              final expiry = const _ExpiringCard();
              if (!wide) {
                return Column(children: [
                  grant,
                  const SizedBox(height: AppDimens.lg),
                  expiry,
                ]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: grant),
                  const SizedBox(width: AppDimens.lg),
                  Expanded(child: expiry),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  static List<Widget> _row(String name, String origin, String status,
      Color statusColor, String end, String videos) {
    return [
      Text(name, style: AppTextStyles.bodyStrong()),
      Text(origin, style: AppTextStyles.body()),
      Align(
          alignment: Alignment.centerLeft,
          child: AdminPill(status, color: statusColor)),
      Text(end, style: AppTextStyles.body()),
      Text(videos, style: AppTextStyles.body()),
      const AdminLink('Voir'),
    ];
  }
}

class _GrantRevokeCard extends StatelessWidget {
  const _GrantRevokeCard();

  @override
  Widget build(BuildContext context) {
    return AdminSection(
      title: 'Attribuer / révoquer Premium',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminField(
              label: 'Compte cible', value: 'Samuel Kouassi · USR-1126'),
          const SizedBox(height: AppDimens.lg),
          const AdminField(
              label: 'Motif obligatoire',
              value: 'Accès de démonstration autorisé pour le pilote.'),
          const SizedBox(height: AppDimens.lg),
          const AdminField(
              label: 'Fin de l’attribution', value: '30 novembre 2026'),
          const SizedBox(height: AppDimens.xl),
          Wrap(
            spacing: AppDimens.md,
            runSpacing: AppDimens.md,
            children: [
              AdminPrimaryButton(
                'Confirmer l’attribution',
                icon: LucideIcons.check,
                onPressed: () => _confirm(
                    context, 'Confirmer l’attribution Premium ?'),
              ),
              AdminOutlineButton(
                'Révoquer avec motif',
                icon: LucideIcons.minusCircle,
                onPressed: () =>
                    _confirm(context, 'Révoquer Premium pour ce compte ?'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void _confirm(BuildContext context, String title) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: const Text(
            'Une entrée d’audit sera créée et le titulaire notifié. Continuer ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Confirmer')),
        ],
      ),
    );
  }
}

class _ExpiringCard extends StatelessWidget {
  const _ExpiringCard();

  @override
  Widget build(BuildContext context) {
    return AdminSection(
      title: 'À l’expiration',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminBanner(
            title: 'Masquer, ne pas supprimer',
            body:
                'Les highlights au-delà du quota gratuit deviennent masqués. Ils réapparaissent au renouvellement. Aucune perte de données.',
          ),
          const SizedBox(height: AppDimens.lg),
          Text(
              'FR-PRM-003 · L’attribution et la révocation manuelles prennent effet au prochain appel API.',
              style: AppTextStyles.bodyStrong()),
          const SizedBox(height: AppDimens.sm),
          Text('Premium n’accorde pas de vérification d’identité.',
              style: AppTextStyles.body()),
          const SizedBox(height: AppDimens.sm),
          Text(
              'Notification au titulaire et entrée d’audit pour chaque changement.',
              style: AppTextStyles.caption()),
          const SizedBox(height: AppDimens.lg),
          Text('Expire bientôt', style: AppTextStyles.bodyStrong()),
          const SizedBox(height: AppDimens.sm),
          for (final e in const [
            ('Kevin Njoya', '31 oct. 2026 · Annulé'),
            ('David Tchoupo', 'Expiré le 12 oct. 2026'),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.sm),
              child: Row(children: [
                const Icon(LucideIcons.clock,
                    size: 16, color: AppColors.warning),
                const SizedBox(width: AppDimens.sm),
                Text('${e.$1} — ${e.$2}', style: AppTextStyles.body()),
              ]),
            ),
        ],
      ),
    );
  }
}
