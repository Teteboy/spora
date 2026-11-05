import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/opportunity_model.dart';
import 'opportunities_shared.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Mes candidatures (/applications) — suivi joueur.
class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() =>
      _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  bool _archived = false;

  List<OpportunityApplication> get _items =>
      OpportunitiesMock.applications
          .where((a) => a.archived == _archived)
          .toList();

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.screenMargin),
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/opportunities');
                    }
                  },
                  child: Container(
                    width: AppDimens.minTouch,
                    height: AppDimens.minTouch,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusInput),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(LucideIcons.arrowLeft,
                        size: 22, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: Text('Mes candidatures',
                      style: AppTextStyles.h1(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.sm),
            GestureDetector(
              onTap: () => showApplicationLimitSheet(context,
                  opportunity:
                      OpportunitiesMock.opportunities.first),
              child: Row(
                children: [
                  const Icon(LucideIcons.info,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: AppDimens.xs),
                  Text(
                    '${OpportunitiesMock.applicationsThisMonth} / ${OpportunitiesMock.freeMonthlyLimit} candidatures ce mois-ci',
                    style: AppTextStyles.caption(
                        color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.lg),
            Row(
              children: [
                _tab('En cours', !_archived,
                    () => setState(() => _archived = false)),
                const SizedBox(width: AppDimens.sm),
                _tab('Archivées', _archived,
                    () => setState(() => _archived = true)),
              ],
            ),
            const SizedBox(height: AppDimens.xl),
            if (items.isEmpty)
              Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppDimens.xxl),
                  child: Text('Aucune candidature',
                      style: AppTextStyles.body()),
                ),
              )
            else
              ...items.map((a) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppDimens.xl),
                    child: _applicationBlock(a),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.circular(AppDimens.radiusPill),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(label,
            style: AppTextStyles.bodyStrong(
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary)),
      ),
    );
  }

  Widget _applicationBlock(OpportunityApplication a) {
    final o = OpportunitiesMock.byId(a.opportunityId) ??
        OpportunitiesMock.opportunities.first;
    return Column(
      children: [
        OppCard(
          onTap: () => context.push('/opportunity/${o.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OppChip(
                  label: 'Ouverte',
                  color: AppColors.green,
                  textColor: AppColors.clubGreen),
              const SizedBox(height: AppDimens.sm),
              Text(o.title, style: AppTextStyles.h2()),
              const SizedBox(height: AppDimens.sm),
              _line(o.publisherName),
              _line(o.location),
              _line(OppFmt.range(o.startDate, o.endDate)),
              _line(
                  '${o.ageRange} · ${o.positionsLabel} · ${o.places} places'),
              _line('Clôture le ${OppFmt.date(o.deadline)}'),
              _line('Offre d’exemple · Académie fictive · Sans frais'),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.md),
        OppCard(child: _timeline(a)),
        const SizedBox(height: AppDimens.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimens.lg),
          decoration: BoxDecoration(
            color: AppColors.primaryTint,
            borderRadius:
                BorderRadius.circular(AppDimens.radiusCard),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Vous serez informé du résultat',
                  style: AppTextStyles.bodyStrong(
                      color: AppColors.primary)),
              const SizedBox(height: AppDimens.xs),
              Text(
                'Les statuts suivants sont des issues possibles, pas des décisions déjà prises.',
                style:
                    AppTextStyles.bodyStrong(color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _timeline(OpportunityApplication a) {
    final steps = <(ApplicationStatus, String, String, IconData)>[
      (ApplicationStatus.sent, 'Envoyée',
          '16 octobre 2026 · 09:30', LucideIcons.checkCircle),
      (ApplicationStatus.viewed, 'Vue',
          'Étape suivante · En attente du club', LucideIcons.eye),
      (ApplicationStatus.shortlisted, 'Présélectionné',
          'Si votre profil est retenu', LucideIcons.userPlus),
      (ApplicationStatus.rejected, 'Refusée',
          'Autre issue possible · Un motif sera affiché', LucideIcons.minusCircle),
    ];
    final currentIndex = a.status == ApplicationStatus.rejected
        ? 3
        : ApplicationStatus.values.indexOf(a.status);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Suivi de votre candidature', style: AppTextStyles.h2()),
        const SizedBox(height: AppDimens.lg),
        ...List.generate(steps.length, (i) {
          final (status, title, subtitle, icon) = steps[i];
          final reached = i <= currentIndex &&
              a.status != ApplicationStatus.rejected;
          final isRejectedStep =
              status == ApplicationStatus.rejected &&
                  a.status == ApplicationStatus.rejected;
          final active = reached || isRejectedStep;
          return Padding(
            padding:
                const EdgeInsets.only(bottom: AppDimens.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isRejectedStep
                      ? AppColors.danger
                      : active
                          ? AppColors.primary
                          : AppColors.textHint,
                ),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: AppTextStyles.bodyStrong(
                              color: active
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted)),
                      Text(subtitle,
                          style: AppTextStyles.caption(
                              color: active
                                  ? AppColors.textSecondary
                                  : AppColors.textHint)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _line(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(text, style: AppTextStyles.body()),
      );
}

/// Bottom sheet « Limite de candidatures » (3 / mois en gratuit).
Future<void> showApplicationLimitSheet(BuildContext context,
    {Opportunity? opportunity}) {
  final o = opportunity ?? OpportunitiesMock.opportunities.first;
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusSheet)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Limite de candidatures',
                      style: AppTextStyles.h2()),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.moreHorizontal,
                      color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            Text('En revue · Maquette statique · Données fictives',
                style: AppTextStyles.caption()),
            const SizedBox(height: AppDimens.md),
            Text(
              '${OpportunitiesMock.freeMonthlyLimit} / ${OpportunitiesMock.freeMonthlyLimit} candidatures ce mois-ci',
              style: AppTextStyles.bodyStrong(
                  color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimens.lg),
            Text('Vous avez atteint votre\nlimite.',
                style: AppTextStyles.display()),
            const SizedBox(height: AppDimens.lg),
            OppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o.title, style: AppTextStyles.h3()),
                  const SizedBox(height: AppDimens.sm),
                  Text('${o.publisherName} · ${o.places} places',
                      style: AppTextStyles.body()),
                  const SizedBox(height: AppDimens.sm),
                  Text('Clôture : ${OppFmt.date(o.deadline)}',
                      style: AppTextStyles.body()),
                  const SizedBox(height: AppDimens.md),
                  const OppGradientButton(
                      label: 'Postuler · Limite atteinte',
                      enabled: false),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimens.lg),
              decoration: BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius:
                    BorderRadius.circular(AppDimens.radiusCard),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.info,
                      color: AppColors.primary, size: 22),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Votre prochaine candidature gratuite',
                            style: AppTextStyles.bodyStrong(
                                color: AppColors.primary)),
                        const SizedBox(height: AppDimens.xs),
                        Text(
                          'Disponible le 1er novembre 2026. Les candidatures '
                          'déjà envoyées restent consultables et ne sont pas annulées.',
                          style: AppTextStyles.body(
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.md),
            OppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Avec Premium', style: AppTextStyles.h3()),
                  const SizedBox(height: AppDimens.sm),
                  Text(
                    'Candidatures illimitées et highlights illimités. '
                    'Le badge Vérifié reste indépendant.',
                    style: AppTextStyles.body(),
                  ),
                  const SizedBox(height: AppDimens.md),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push('/premium');
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimens.radiusCard),
                        ),
                      ),
                      child: Text('Découvrir Premium · X FCFA',
                          style: AppTextStyles.button(
                              color: AppColors.textPrimary)),
                    ),
                  ),
                  const SizedBox(height: AppDimens.sm),
                  Text(
                    'Limite gratuite de 3 / mois proposée, à valider. '
                    'Règle appliquée côté serveur.',
                    style: AppTextStyles.caption(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusCard),
                  ),
                ),
                child: Text('Voir mes candidatures',
                    style: AppTextStyles.button(
                        color: AppColors.textPrimary)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
