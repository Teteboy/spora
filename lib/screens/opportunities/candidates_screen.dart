import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/opportunity_model.dart';
import 'opportunities_shared.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Candidats (/opportunity/:id/candidates) — vue éditeur.
class CandidatesScreen extends StatefulWidget {
  final String opportunityId;
  const CandidatesScreen({super.key, required this.opportunityId});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
  String _filter = 'Tous';
  static const _filters = ['Tous', 'À examiner', 'Présélectionnés', 'Refusés'];
  final Set<String> _expanded = {};

  Opportunity get _o =>
      OpportunitiesMock.byId(widget.opportunityId) ??
      OpportunitiesMock.opportunities.first;

  List<OpportunityApplication> get _items =>
      OpportunitiesMock.applications.where((a) {
        switch (_filter) {
          case 'À examiner':
            return a.status == ApplicationStatus.sent ||
                a.status == ApplicationStatus.viewed;
          case 'Présélectionnés':
            return a.status == ApplicationStatus.shortlisted;
          case 'Refusés':
            return a.status == ApplicationStatus.rejected;
          default:
            return true;
        }
      }).toList();

  void _setStatus(OpportunityApplication a, ApplicationStatus s) {
    final i = OpportunitiesMock.applications.indexOf(a);
    OpportunitiesMock.applications[i] = OpportunityApplication(
      id: a.id,
      opportunityId: a.opportunityId,
      playerName: a.playerName,
      position: a.position,
      age: a.age,
      city: a.city,
      country: a.country,
      level: a.level,
      avatarUrl: a.avatarUrl,
      verified: a.verified,
      message: a.message,
      highlightTitle: a.highlightTitle,
      highlightDuration: a.highlightDuration,
      highlightThumb: a.highlightThumb,
      status: s,
      sentAt: a.sentAt,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final o = _o;
    final items = _items;
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppDimens.screenMargin,
                  AppDimens.sm, AppDimens.screenMargin, AppDimens.md),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: AppDimens.minTouch,
                      height: AppDimens.minTouch,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(
                            AppDimens.radiusInput),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(LucideIcons.arrowLeft,
                          size: 22, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: Text('Candidats',
                        style: AppTextStyles.h1(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppDimens.screenMargin),
                children: [
          Text(o.title, style: AppTextStyles.h1()),
          const SizedBox(height: AppDimens.sm),
          Text(
            '${o.candidatesCount} candidatures · ${o.toReviewCount} à examiner',
            style: AppTextStyles.body(),
          ),
          const SizedBox(height: AppDimens.lg),
          Wrap(
            spacing: AppDimens.sm,
            runSpacing: AppDimens.sm,
            children: _filters.map((f) {
              final sel = _filter == f;
              return GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusPill),
                    border: Border.all(
                      color: sel ? AppColors.primary : AppColors.border,
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
          const SizedBox(height: AppDimens.lg),
          ...items.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.md),
                child: _candidateCard(a),
              )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _candidateCard(OpportunityApplication a) {
    final expanded = _expanded.contains(a.id);
    return OppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimens.sm),
            decoration: BoxDecoration(
              color: AppColors.appBg,
              borderRadius:
                  BorderRadius.circular(AppDimens.radiusInput),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusSm),
                  child: Image.network(
                    a.avatarUrl ?? '',
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                        width: 64, height: 64, color: AppColors.muted),
                  ),
                ),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.playerName,
                          style: AppTextStyles.bodyStrong()),
                      Text(
                          '${a.position} · ${a.age} ans · ${a.country}',
                          style: AppTextStyles.body()),
                      Text('${a.city} · ${a.level}',
                          style: AppTextStyles.body()),
                    ],
                  ),
                ),
                if (a.verified)
                  const Icon(LucideIcons.badgeCheck,
                      color: AppColors.primary, size: 20),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.md),
          Text(
            'Profil complet · Highlight joint · Reçu aujourd’hui',
            style: AppTextStyles.body(),
          ),
          if (expanded) ...[
            const SizedBox(height: AppDimens.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimens.md),
              decoration: BoxDecoration(
                color: AppColors.muted,
                borderRadius:
                    BorderRadius.circular(AppDimens.radiusInput),
              ),
              child: Text('« ${a.message} »',
                  style: AppTextStyles.body()),
            ),
            const SizedBox(height: AppDimens.sm),
            Row(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusSm),
                  child: Image.network(
                    a.highlightThumb ?? '',
                    width: 96,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                        width: 96, height: 56, color: AppColors.muted),
                  ),
                ),
                const SizedBox(width: AppDimens.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.highlightTitle ?? '',
                          style: AppTextStyles.bodyStrong()),
                      Text(a.highlightDuration ?? '',
                          style: AppTextStyles.caption()),
                    ],
                  ),
                ),
                const Icon(LucideIcons.playCircle,
                    color: AppColors.primary),
              ],
            ),
          ],
          const SizedBox(height: AppDimens.md),
          OppGradientButton(
            label: expanded ? 'Masquer la candidature' : 'Voir la candidature',
            onPressed: () => setState(() => expanded
                ? _expanded.remove(a.id)
                : _expanded.add(a.id)),
          ),
          const SizedBox(height: AppDimens.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: a.status == ApplicationStatus.shortlisted
                      ? null
                      : () => _setStatus(
                          a, ApplicationStatus.shortlisted),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12),
                    side:
                        const BorderSide(color: AppColors.border),
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          AppDimens.radiusInput),
                    ),
                  ),
                  child: Text(
                    a.status == ApplicationStatus.shortlisted
                        ? 'Présélectionné ✓'
                        : 'Présélectionner',
                    style: AppTextStyles.button(
                        color: AppColors.textPrimary),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.sm),
              Expanded(
                child: FilledButton(
                  onPressed: a.status == ApplicationStatus.rejected
                      ? null
                      : () =>
                          _setStatus(a, ApplicationStatus.rejected),
                  style: FilledButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: AppColors.danger,
                    disabledBackgroundColor:
                        AppColors.danger.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          AppDimens.radiusInput),
                    ),
                  ),
                  child: Text('Refuser', style: AppTextStyles.button()),
                ),
              ),
              const SizedBox(width: AppDimens.sm),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusInput),
                  border: Border.all(color: AppColors.border),
                ),
                child: IconButton(
                  icon: const Icon(LucideIcons.messageSquare,
                      size: 20, color: AppColors.textPrimary),
                  onPressed: () => context.push('/chat/${a.id}',
                      extra: {'name': a.playerName}),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
