import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/opportunity_model.dart';
import 'opportunities_shared.dart';
import 'my_applications_screen.dart' show showApplicationLimitSheet;
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Postuler (/opportunity/:id/apply) — message + highlight joint,
/// puis écran de confirmation "Candidature envoyée" (même fichier).
class ApplyScreen extends StatefulWidget {
  final String opportunityId;
  const ApplyScreen({super.key, required this.opportunityId});

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  final _messageCtrl = TextEditingController(
      text:
          'Bonjour, je suis Jordan Mbala, attaquant au Paris FC U21. Je souhaite participer à votre détection et vous présenter mon jeu.');
  Map<String, String>? _highlight = OpportunitiesMock.myHighlights.first;
  bool _consent = true;
  bool _sent = false;

  Opportunity get _o =>
      OpportunitiesMock.byId(widget.opportunityId) ??
      OpportunitiesMock.opportunities.first;

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    // Limite gratuite : 3 candidatures / mois (compte premium illimité).
    if (OpportunitiesMock.applicationsThisMonth >=
        OpportunitiesMock.freeMonthlyLimit) {
      showApplicationLimitSheet(context, opportunity: _o);
      return;
    }
    setState(() => _sent = true);
  }

  Future<void> _pickHighlight() async {
    final selected = await showModalBottomSheet<Map<String, String>>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimens.radiusSheet)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: Text('Choisir un highlight', style: AppTextStyles.h3()),
            ),
            ...OpportunitiesMock.myHighlights.map(
              (h) => ListTile(
                leading: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusSm),
                  child: Image.network(h['thumb']!,
                      width: 72,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          width: 72, height: 44, color: AppColors.muted)),
                ),
                title: Text(h['title']!, style: AppTextStyles.bodyStrong()),
                subtitle: Text(h['duration']!,
                    style: AppTextStyles.caption()),
                trailing: _highlight == h
                    ? const Icon(LucideIcons.checkCircle2,
                        color: AppColors.primary)
                    : const Icon(LucideIcons.circle,
                        color: AppColors.textHint),
                onTap: () => Navigator.pop(ctx, h),
              ),
            ),
            const SizedBox(height: AppDimens.md),
          ],
        ),
      ),
    );
    if (selected != null) setState(() => _highlight = selected);
  }

  @override
  Widget build(BuildContext context) {
    return _sent ? _ConfirmationScreen(opportunity: _o) : _buildForm();
  }

  Widget _buildForm() {
    final o = _o;
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: Column(
          children: [
            _SubTopBar(title: 'Postuler', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppDimens.screenMargin),
                children: [
          OppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusPill),
                  child: const LinearProgressIndicator(
                    value: 0.35,
                    minHeight: 6,
                    backgroundColor: AppColors.muted,
                    valueColor:
                        AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(height: AppDimens.lg),
                Text(o.title, style: AppTextStyles.h1()),
                const SizedBox(height: AppDimens.xs),
                Text('${o.publisherName} · Offre d’exemple fictive',
                    style: AppTextStyles.body()),
                const SizedBox(height: AppDimens.lg),
                TextField(
                  controller: _messageCtrl,
                  maxLines: 5,
                  style:
                      AppTextStyles.body(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Votre message',
                    labelStyle:
                        AppTextStyles.body(color: AppColors.textMuted),
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: AppColors.surface,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          AppDimens.radiusInput),
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          AppDimens.radiusInput),
                      borderSide:
                          const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.lg),
                Text(
                  'Joindre un highlight${_highlight != null ? ' · 1 sélectionné' : ''}',
                  style: AppTextStyles.bodyStrong(),
                ),
                const SizedBox(height: AppDimens.sm),
                GestureDetector(
                  onTap: _pickHighlight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        AppDimens.radiusInput),
                    child: Image.network(
                      _highlight?['thumb'] ?? '',
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 160,
                        color: AppColors.muted,
                        child: const Icon(LucideIcons.film,
                            color: AppColors.textMuted, size: 40),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.sm),
                if (_highlight != null)
                  OppChip(
                    label:
                        '✓ ${_highlight!['title']} · ${_highlight!['duration']}',
                    color: AppColors.primaryTint,
                    textColor: AppColors.primary,
                  ),
                const SizedBox(height: AppDimens.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _consent,
                        activeColor: AppColors.textSecondary,
                        onChanged: (v) =>
                            setState(() => _consent = v ?? false),
                      ),
                    ),
                    const SizedBox(width: AppDimens.sm),
                    Expanded(
                      child: Text(
                        'J’accepte de partager mon profil et cette vidéo avec '
                        'l’${o.publisherName} pour l’examen de ma candidature.',
                        style: AppTextStyles.body(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.lg),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimens.lg),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusCard),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Votre dossier',
                          style: AppTextStyles.bodyStrong(
                              color: AppColors.clubGreen)),
                      const SizedBox(height: AppDimens.xs),
                      Text(
                        '19 ans · ATT · Disponible les '
                        '${OppFmt.range(o.startDate, o.endDate)}. '
                        'Aucun paiement demandé.',
                        style: AppTextStyles.bodyStrong(
                            color: AppColors.clubGreen),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(
            AppDimens.screenMargin, 12, AppDimens.screenMargin, 24),
        color: AppColors.surface,
        child: OppGradientButton(
          label: 'Envoyer ma candidature',
          enabled: _consent,
          onPressed: _submit,
        ),
      ),
    );
  }
}

/// Top bar: bordered back tile + h1 title (Figma header pattern).
class _SubTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const _SubTopBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimens.screenMargin,
          AppDimens.sm, AppDimens.screenMargin, AppDimens.md),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
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
            child: Text(title,
                style: AppTextStyles.h1(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

/// Écran de confirmation « Candidature envoyée ».
class _ConfirmationScreen extends StatelessWidget {
  final Opportunity opportunity;
  const _ConfirmationScreen({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final o = opportunity;
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: Column(
          children: [
            _SubTopBar(
                title: 'Candidature envoyée',
                onBack: () => context.go('/opportunities')),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppDimens.screenMargin),
                children: [
          const SizedBox(height: AppDimens.lg),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(color: AppColors.clubGreen, width: 2),
            ),
            child: const Icon(LucideIcons.check,
                color: AppColors.clubGreen, size: 36),
          ),
          const SizedBox(height: AppDimens.xl),
          Text('Votre candidature est\nenvoyée !',
              style: AppTextStyles.display()),
          const SizedBox(height: AppDimens.md),
          Text(
            'L’${o.publisherName} peut maintenant consulter votre profil, '
            'votre message et votre highlight.',
            style: AppTextStyles.bodyLarge(
                color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimens.xl),
          OppCard(
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
          const SizedBox(height: AppDimens.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimens.lg),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(AppDimens.radiusCard),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Exemple fictif',
                    style: AppTextStyles.bodyStrong(
                        color: AppColors.clubGreen)),
                const SizedBox(height: AppDimens.xs),
                Text(
                  'Aucun recrutement ni envoi réel n’est effectué dans cette maquette.',
                  style: AppTextStyles.bodyStrong(
                      color: AppColors.clubGreen),
                ),
              ],
            ),
          ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(
            AppDimens.screenMargin, 12, AppDimens.screenMargin, 24),
        color: AppColors.surface,
        child: OppGradientButton(
          label: 'Suivre mes candidatures',
          onPressed: () => context.push('/applications'),
        ),
      ),
    );
  }

  Widget _line(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(text, style: AppTextStyles.body()),
      );
}
