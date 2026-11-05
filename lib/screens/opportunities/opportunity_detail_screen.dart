import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/opportunity_model.dart';
import '../../providers/auth_provider.dart';
import 'opportunities_shared.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// 13 · Recrutement — Détail de la détection (/opportunity/:id)
/// États : ouverte / déjà postulé / fermée / expirée.
class OpportunityDetailScreen extends StatelessWidget {
  final String opportunityId;
  const OpportunityDetailScreen({super.key, required this.opportunityId});

  bool _isPublisher(BuildContext context) {
    final t = context.read<AuthProvider>().selectedUserType;
    return t == UserType.agent || t == UserType.recruiter;
  }

  /// Machine à états de la candidature.
  _ApplyState _stateFor(Opportunity o) {
    if (o.id.endsWith('-applied')) return _ApplyState.applied;
    switch (o.status) {
      case OpportunityStatus.closed:
        return _ApplyState.closed;
      case OpportunityStatus.expired:
        return _ApplyState.expired;
      default:
        return _ApplyState.open;
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = OpportunitiesMock.byId(opportunityId) ??
        OpportunitiesMock.opportunities.first;
    final state = _stateFor(o);
    final publisher = _isPublisher(context);

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildHeroImage(o, state),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppDimens.screenMargin,
                        AppDimens.lg,
                        AppDimens.screenMargin,
                        0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o.title, style: AppTextStyles.display()),
                        const SizedBox(height: AppDimens.lg),
                        _buildPublisher(o),
                        const SizedBox(height: AppDimens.lg),
                        _buildInfoCard(o),
                        const SizedBox(height: AppDimens.md),
                        if (state == _ApplyState.open)
                          _banner(
                            color: AppColors.primaryTint,
                            textColor: AppColors.primary,
                            text:
                                'Clôture le ${OppFmt.date(o.deadline)}',
                          ),
                        if (state == _ApplyState.applied)
                          _banner(
                            color: AppColors.green
                                .withValues(alpha: 0.12),
                            title: 'Vous avez déjà postulé',
                            titleColor: AppColors.clubGreen,
                            text:
                                'Envoyée le 16 octobre 2026 à 09:18 · En attente de lecture. '
                                'Vous pouvez échanger avec le recruteur depuis votre candidature.',
                          ),
                        if (state == _ApplyState.closed)
                          _banner(
                            color: AppColors.muted,
                            title:
                                'L’organisateur a fermé cette offre',
                            titleColor: AppColors.textPrimary,
                            text:
                                'Aucune nouvelle candidature ne peut être envoyée. '
                                'Les dossiers déjà transmis restent accessibles.',
                          ),
                        if (state == _ApplyState.expired)
                          _banner(
                            color: AppColors.muted,
                            title: 'Cette opportunité est expirée',
                            titleColor: AppColors.textPrimary,
                            text:
                                'État présenté après le ${OppFmt.date(o.deadline)}. '
                                'Aucun nouveau dossier ne peut être envoyé.',
                          ),
                        const SizedBox(height: AppDimens.lg),
                        Text(o.description,
                            style: AppTextStyles.body()),
                        if (o.criteria.isNotEmpty) ...[
                          const SizedBox(height: AppDimens.section),
                          Text('Pour postuler',
                              style: AppTextStyles.h2()),
                          const SizedBox(height: AppDimens.md),
                          ...o.criteria.map(_criterion),
                        ],
                        const SizedBox(height: AppDimens.sm),
                        Text(_feesCaption(o),
                            style: AppTextStyles.caption()),
                        const SizedBox(height: AppDimens.lg),
                        if (publisher)
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: AppDimens.md),
                            child: OppGradientButton(
                              label: 'Voir les candidats',
                              icon: LucideIcons.users,
                              onPressed: () => context.push(
                                  '/opportunity/${o.id}/candidates'),
                            ),
                          ),
                        if (state == _ApplyState.applied)
                          _outlineButton(
                              context,
                              'Suivre ma candidature',
                              () => context.push('/applications')),
                        if (state == _ApplyState.closed ||
                            state == _ApplyState.expired)
                          _outlineButton(
                              context,
                              'Voir d’autres opportunités',
                              () => context.go('/opportunities')),
                        const SizedBox(height: AppDimens.xxl),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildBottomBar(context, o, state),
          ],
        ),
      ),
    );
  }

  String _feesCaption(Opportunity o) => o.fees == 'Sans frais'
      ? 'Aucun paiement demandé via cette annonce d’exemple.'
      : '${o.fees} possibles · Offre fictive de démonstration';

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppDimens.screenMargin, 8, AppDimens.screenMargin, 12),
      child: Row(
        children: [
          _squareButton(
            icon: LucideIcons.arrowLeft,
            onTap: () => context.pop(),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Text('Détail de l’opportunité',
                style: AppTextStyles.display(),
                overflow: TextOverflow.ellipsis),
          ),
          _squareButton(
            icon: LucideIcons.share2,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  /// Bouton carré arrondi blanc (retour / partage), 48 px.
  Widget _squareButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.circular(AppDimens.radiusCard),
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 22, color: AppColors.textPrimary),
      ),
    );
  }

  /// Image pleine largeur + pastilles type / statut en surimpression.
  Widget _buildHeroImage(Opportunity o, _ApplyState state) {
    String? statusLabel;
    switch (state) {
      case _ApplyState.applied:
        statusLabel = 'Candidature envoyée';
        break;
      case _ApplyState.closed:
        statusLabel = 'Fermée';
        break;
      case _ApplyState.expired:
        statusLabel = 'Expirée';
        break;
      case _ApplyState.open:
        break;
    }
    return SizedBox(
      height: 190,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _netImage(o.imageUrl ?? '', height: 190),
          Positioned(
            top: AppDimens.lg,
            left: AppDimens.screenMargin,
            right: AppDimens.screenMargin,
            child: Row(
              children: [
                OppChip(
                    label: o.type.label,
                    color: o.type.color,
                    textColor: o.type.color),
                if (statusLabel != null) ...[
                  const SizedBox(width: AppDimens.sm),
                  OppChip(
                    label: statusLabel,
                    color: state == _ApplyState.applied
                        ? AppColors.primary
                        : AppColors.textMuted,
                    textColor: state == _ApplyState.applied
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    outlined: state != _ApplyState.applied,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublisher(Opportunity o) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.green.withValues(alpha: 0.12),
            borderRadius:
                BorderRadius.circular(AppDimens.radiusCard),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.shield,
                  size: 22, color: AppColors.clubGreen),
              Text(o.publisherInitials,
                  style:
                      AppTextStyles.micro(color: AppColors.clubGreen)
                          .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(width: AppDimens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(o.publisherName, style: AppTextStyles.h3()),
              const SizedBox(height: 2),
              Text(o.publisherRole,
                  style: AppTextStyles.caption(
                      color: AppColors.textSecondary)),
            ],
          ),
        ),
        if (o.publisherVerified)
          const Icon(LucideIcons.badgeCheck,
              color: AppColors.primary, size: 26),
      ],
    );
  }

  /// Carte gris clair : localisation, dates, âge + places, postes.
  Widget _buildInfoCard(Opportunity o) {
    final dateRange = OppFmt.range(o.startDate, o.endDate);
    final capacity = [
      if (o.ageRange.isNotEmpty) o.ageRange,
      '${o.places} places',
    ].join(' · ');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.lg, vertical: AppDimens.md),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(LucideIcons.mapPin, o.location),
          if (dateRange.isNotEmpty)
            _infoRow(LucideIcons.calendar, dateRange),
          _infoRow(LucideIcons.users, capacity),
          if (o.positionsLabel.isNotEmpty)
            _infoRow(LucideIcons.target,
                'Postes recherchés : ${o.positionsLabel}'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Text(text,
                style: AppTextStyles.body(
                    color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  /// Ligne de checklist "Pour postuler" — carré bleu + coche blanche.
  Widget _criterion(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius:
                  BorderRadius.circular(AppDimens.radiusSm),
            ),
            alignment: Alignment.center,
            child: const Icon(LucideIcons.check,
                size: 14, color: Colors.white),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Text(text,
                style: AppTextStyles.body(
                    color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _banner({
    required Color color,
    required String text,
    String? title,
    Color? titleColor,
    Color? textColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(title,
                  style: AppTextStyles.bodyStrong(
                      color: titleColor ?? AppColors.textPrimary)),
            ),
          Text(text,
              style: AppTextStyles.body(
                  color: textColor ?? AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _outlineButton(
      BuildContext context, String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: AppColors.border),
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDimens.radiusCard),
          ),
        ),
        child: Text(label,
            style: AppTextStyles.button(color: AppColors.textPrimary)),
      ),
    );
  }

  Widget _buildBottomBar(
      BuildContext context, Opportunity o, _ApplyState state) {
    String label;
    String caption;
    bool enabled;
    switch (state) {
      case _ApplyState.open:
        label = 'Postuler';
        caption = '';
        enabled = true;
        break;
      case _ApplyState.applied:
        label = 'Candidature envoyée';
        caption = 'Retrouvez votre dossier dans Mes candidatures.';
        enabled = false;
        break;
      case _ApplyState.closed:
        label = 'Candidatures fermées';
        caption = 'Fermée par l’organisateur avant la date limite.';
        enabled = false;
        break;
      case _ApplyState.expired:
        label = 'Offre expirée';
        caption =
            'La date limite du ${OppFmt.date(o.deadline)} est dépassée.';
        enabled = false;
        break;
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppDimens.screenMargin, 12, AppDimens.screenMargin, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OppGradientButton(
              label: label,
              icon: enabled ? LucideIcons.arrowRight : null,
              enabled: enabled,
              onPressed: () =>
                  context.push('/opportunity/${o.id}/apply'),
            ),
            if (caption.isNotEmpty) ...[
              const SizedBox(height: AppDimens.sm),
              Text(caption,
                  style: AppTextStyles.caption(),
                  textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}

/// Image réseau : bloc gris pendant le chargement,
/// placeholder navy foncé en cas d'erreur.
Widget _netImage(String url, {double? width, double? height}) {
  return Image.network(
    url,
    width: width,
    height: height,
    fit: BoxFit.cover,
    loadingBuilder: (context, child, progress) => progress == null
        ? child
        : Container(
            width: width, height: height, color: AppColors.muted),
    errorBuilder: (context, error, stack) => Container(
      width: width,
      height: height,
      color: AppColors.navy800,
      alignment: Alignment.center,
      child: const Icon(LucideIcons.imageOff,
          color: AppColors.darkTextMuted, size: 28),
    ),
  );
}

enum _ApplyState { open, applied, closed, expired }
