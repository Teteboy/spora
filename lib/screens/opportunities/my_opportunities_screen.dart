import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/opportunity_model.dart';
import 'opportunities_shared.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Mes opportunités (/opportunities/mine) — vue éditeur.
class MyOpportunitiesScreen extends StatefulWidget {
  const MyOpportunitiesScreen({super.key});

  @override
  State<MyOpportunitiesScreen> createState() =>
      _MyOpportunitiesScreenState();
}

class _MyOpportunitiesScreenState extends State<MyOpportunitiesScreen> {
  String _filter = 'Toutes';
  static const _filters = ['Toutes', 'Ouvertes', 'Fermées', 'Brouillons'];

  List<Opportunity> get _items => OpportunitiesMock.mine.where((o) {
        switch (_filter) {
          case 'Ouvertes':
            return o.status == OpportunityStatus.open ||
                o.status == OpportunityStatus.pendingValidation;
          case 'Fermées':
            return o.status == OpportunityStatus.closed ||
                o.status == OpportunityStatus.expired;
          case 'Brouillons':
            return o.status == OpportunityStatus.draft;
          default:
            return true;
        }
      }).toList();

  Color _statusColor(OpportunityStatus s) {
    switch (s) {
      case OpportunityStatus.open:
        return AppColors.green;
      case OpportunityStatus.closed:
      case OpportunityStatus.expired:
        return AppColors.muted;
      case OpportunityStatus.pendingValidation:
        return AppColors.warning;
      case OpportunityStatus.draft:
        return AppColors.primaryTint;
    }
  }

  Color _statusTextColor(OpportunityStatus s) {
    switch (s) {
      case OpportunityStatus.open:
        return AppColors.clubGreen;
      case OpportunityStatus.closed:
      case OpportunityStatus.expired:
        return AppColors.textSecondary;
      case OpportunityStatus.pendingValidation:
        return AppColors.goldDark;
      case OpportunityStatus.draft:
        return AppColors.primary;
    }
  }

  void _close(Opportunity o) {
    setState(() {
      // Action "fermer" : bascule le statut côté maquette.
      final i = OpportunitiesMock.mine.indexOf(o);
      OpportunitiesMock.mine[i] = Opportunity(
        id: o.id,
        type: o.type,
        title: o.title,
        description: o.description,
        publisherName: o.publisherName,
        publisherRole: o.publisherRole,
        publisherInitials: o.publisherInitials,
        publisherVerified: o.publisherVerified,
        city: o.city,
        country: o.country,
        startDate: o.startDate,
        endDate: o.endDate,
        deadline: o.deadline,
        places: o.places,
        ageMin: o.ageMin,
        ageMax: o.ageMax,
        positions: o.positions,
        status: OpportunityStatus.closed,
        isMine: true,
        candidatesCount: o.candidatesCount,
        toReviewCount: o.toReviewCount,
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Offre fermée')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final open = OpportunitiesMock.mine
        .where((o) => o.status == OpportunityStatus.open)
        .length;
    final candidates = OpportunitiesMock.mine
        .fold<int>(0, (s, o) => s + o.candidatesCount);
    final toReview = OpportunitiesMock.mine
        .fold<int>(0, (s, o) => s + o.toReviewCount);

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
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
                            borderRadius: BorderRadius.circular(
                                AppDimens.radiusInput),
                            border:
                                Border.all(color: AppColors.border),
                          ),
                          child: const Icon(LucideIcons.arrowLeft,
                              size: 22,
                              color: AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: AppDimens.md),
                      Expanded(
                        child: Text('Mes opportunités',
                            style: AppTextStyles.h1(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.xl),
                  Row(
                    children: [
                      _stat('$open', 'Ouverte'),
                      _stat('$candidates', 'Candidats'),
                      _stat('$toReview', 'À examiner'),
                    ],
                  ),
                  const SizedBox(height: AppDimens.xl),
                  Wrap(
                    spacing: AppDimens.sm,
                    children: _filters.map((f) {
                      final sel = _filter == f;
                      return GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 9),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                                AppDimens.radiusPill),
                            border: Border.all(
                              color: sel
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: sel ? 1.5 : 1,
                            ),
                          ),
                          child: Text(f,
                              style: AppTextStyles.bodyStrong(
                                  color: sel
                                      ? AppColors.primary
                                      : AppColors.textSecondary)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppDimens.xl),
                  ...items.map((o) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppDimens.md),
                        child: _card(o),
                      )),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(AppDimens.screenMargin,
                  12, AppDimens.screenMargin, 24),
              color: AppColors.surface,
              child: OppGradientButton(
                label: 'Publier une opportunité',
                onPressed: () =>
                    context.push('/opportunities/publish'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String number, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number, style: AppTextStyles.h2()),
          Text(label, style: AppTextStyles.bodyStrong()),
        ],
      ),
    );
  }

  Widget _card(Opportunity o) {
    return OppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              OppChip(
                label: o.status.label,
                color: _statusColor(o.status),
                textColor: _statusTextColor(o.status),
              ),
              const Spacer(),
              if (o.status == OpportunityStatus.open)
                PopupMenuButton<String>(
                  icon: const Icon(LucideIcons.moreHorizontal,
                      color: AppColors.textMuted),
                  onSelected: (v) {
                    if (v == 'close') _close(o);
                    if (v == 'candidates') {
                      context.push('/opportunity/${o.id}/candidates');
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                        value: 'candidates',
                        child: Text('Voir les candidats')),
                    PopupMenuItem(
                        value: 'close', child: Text('Fermer l’offre')),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          Text(o.title, style: AppTextStyles.h2()),
          const SizedBox(height: AppDimens.sm),
          _line(o.publisherName),
          _line(o.location),
          _line(OppFmt.range(o.startDate, o.endDate)),
          _line(
              '${o.ageRange.isEmpty ? '' : '${o.ageRange} · '}${o.positionsLabel}${o.positionsLabel.isEmpty ? '' : ' · '}${o.places} places'),
          _line('Clôture le ${OppFmt.date(o.deadline)}'),
          _line('Offre d’exemple · Académie fictive · Sans frais'),
          if (o.candidatesCount > 0) ...[
            const SizedBox(height: AppDimens.sm),
            GestureDetector(
              onTap: () =>
                  context.push('/opportunity/${o.id}/candidates'),
              child: Text(
                '${o.candidatesCount} candidatures · ${o.toReviewCount} à examiner →',
                style: AppTextStyles.bodyStrong(color: AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _line(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(text, style: AppTextStyles.body()),
      );
}
