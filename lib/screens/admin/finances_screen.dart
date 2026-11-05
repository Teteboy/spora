import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'admin_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A16 — Finances et transactions.
class FinancesScreen extends StatelessWidget {
  const FinancesScreen({super.key});

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
              title: 'Finances et transactions',
              subtitle:
                  'Revenus de démonstration en XAF · Aucun tarif commercial officiel.',
              trailing: Text('17 sept. – 16 oct. 2026'),
            ),
            const SizedBox(height: AppDimens.section),
            Row(
              children: [
                const Expanded(
                  child: Wrap(
                    spacing: AppDimens.md,
                    runSpacing: AppDimens.md,
                    children: [
                      AdminSearchField(),
                      AdminFilter('Mensuel / Annuel'),
                      AdminFilter('Orange Money'),
                      AdminFilter('MTN'),
                      AdminFilter('Stripe'),
                      AdminFilter('Statut'),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimens.md),
                AdminPrimaryButton('Exporter CSV',
                    icon: LucideIcons.download),
              ],
            ),
            const SizedBox(height: AppDimens.section),
            const AdminStatGrid(cards: [
              AdminStatCard(
                  label: 'Revenus encaissés · démo',
                  value: '2 480 000',
                  hint: 'XAF · +12,8 %'),
              AdminStatCard(
                  label: 'Mensuel / Annuel',
                  value: '1,36 M / 1,12 M',
                  hint: 'XAF · données fictives'),
              AdminStatCard(
                  label: 'Paiements réussis',
                  value: '386',
                  hint: '3 à rapprocher · 8 en attente'),
            ]),
            const SizedBox(height: AppDimens.section),
            LayoutBuilder(builder: (context, c) {
              final wide = c.maxWidth > 1000;
              const chart = AdminSection(
                title: 'Revenus par période',
                child: _RevenueChart(),
              );
              const split = _ByMethodCard();
              if (!wide) {
                return const Column(children: [
                  chart,
                  SizedBox(height: AppDimens.lg),
                  split,
                ]);
              }
              return const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: chart),
                  SizedBox(width: AppDimens.lg),
                  Expanded(flex: 2, child: split),
                ],
              );
            }),
            const SizedBox(height: AppDimens.section),
            AdminTable(
              columns: const [
                AdminCol('Référence'),
                AdminCol('Compte / plan'),
                AdminCol('Prestataire'),
                AdminCol('Montant XAF'),
                AdminCol('Statut / rapprochement', flex: 2),
                AdminCol('Action'),
              ],
              rows: [
                _tx('DEMO-OM-0284', 'Jordan · Annuel', 'Orange Money',
                    '12 000', 'Réussi · Rapproché', AppColors.success),
                _tx('DEMO-MTN-0283', 'Kevin · Mensuel', 'MTN', '4 000',
                    'Réussi · À rapprocher', AppColors.warning),
                _tx('DEMO-ST-0282', 'Samuel · Mensuel', 'Stripe', '6 000',
                    'En attente · En cours', AppColors.warning),
                _tx('DEMO-OM-0281', 'David · Mensuel', 'Orange Money',
                    '5 000', 'Échoué · Sans encaissement', AppColors.danger),
              ],
            ),
            const AdminPagination(
                summary: '1–4 sur 402 résultats · 20 par page'),
            const SizedBox(height: AppDimens.section),
            const AdminBanner(
              title: 'Une référence prestataire = un paiement',
              body:
                  'Un webhook répété ne crée ni second paiement ni seconde activation. Ces montants sont fictifs et ne représentent pas les prix des formules. Aucun numéro de carte brut ni capacité de remboursement n’est exposé.',
            ),
          ],
        ),
      ),
    );
  }

  static List<Widget> _tx(String ref, String account, String method,
      String amount, String status, Color statusColor) {
    return [
      Text(ref, style: AppTextStyles.bodyStrong()),
      Text(account, style: AppTextStyles.body()),
      Text(method, style: AppTextStyles.body()),
      Text(amount, style: AppTextStyles.bodyStrong()),
      Text(status, style: AppTextStyles.body(color: statusColor)),
      const AdminLink('Détail'),
    ];
  }
}

/// Bar chart "Revenus encaissés · XAF" over 12 points.
class _RevenueChart extends StatelessWidget {
  const _RevenueChart();

  static const List<double> _values = [
    0.55, 0.72, 0.62, 0.85, 0.75, 0.92, 0.82, 1.0, 0.90, 0.97, 0.88, 1.0,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text('Revenus encaissés · XAF',
              style: AppTextStyles.body(color: AppColors.primary)),
          const Spacer(),
          Text('Période précédente +12,8 %',
              style: AppTextStyles.caption()),
        ]),
        const SizedBox(height: AppDimens.lg),
        SizedBox(
          height: 160,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < _values.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.xs),
                    child: FractionallySizedBox(
                      heightFactor: _values[i],
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6)),
                          color: i == _values.length - 1
                              ? null
                              : AppColors.primaryTint,
                          gradient: i == _values.length - 1
                              ? const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: AppColors.primaryGradient)
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
                    Text('$i', style: AppTextStyles.micro()),
              ),
            ),
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
    );
  }
}

class _ByMethodCard extends StatelessWidget {
  const _ByMethodCard();

  @override
  Widget build(BuildContext context) {
    return AdminSection(
      title: 'Par prestataire · XAF',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final e in const [
            ('1 240 000', 'Orange Money · 50 %'),
            ('868 000', 'MTN Mobile Money · 35 %'),
            ('372 000', 'Stripe · 15 %'),
          ]) ...[
            Text(e.$1,
                style:
                    AppTextStyles.display().copyWith(fontSize: 22)),
            const SizedBox(height: AppDimens.xs),
            Text(e.$2, style: AppTextStyles.body()),
            const SizedBox(height: AppDimens.lg),
          ],
          const Divider(color: AppColors.divider),
          const SizedBox(height: AppDimens.md),
          Text('Par formule : Annuel 55 % · Mensuel 45 %',
              style: AppTextStyles.caption()),
        ],
      ),
    );
  }
}
