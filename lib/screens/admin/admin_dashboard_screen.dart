import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'admin_widgets.dart';
import 'mock_admin_data.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A03 — Administrator dashboard: KPI grid, platform activity chart,
/// moderation queue and pending verifications / security alerts.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.section),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminPageHeader(
            title: 'Bonjour Amina, voici vos priorités.',
            subtitle:
                'Une vue claire de l\'activité et des dossiers qui '
                'attendent votre attention.',
            trailing: Text('17 sept. – 16 oct. 2026'),
          ),
          const SizedBox(height: AppDimens.lg),
          const Wrap(
            spacing: AppDimens.md,
            runSpacing: AppDimens.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AdminSearchField(
                  hint: 'Rechercher dans l\'administration…', width: 340),
              AdminFilter('30 derniers jours'),
              AdminFilter('Tous les pays'),
              AdminFilter('Tous les rôles'),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          AdminBanner(
            title: '2 alertes de protection nécessitent une revue urgente',
            body: 'Un profil mineur signalé et une demande de '
                'suppression par un tuteur. Consulter les dossiers →',
            icon: LucideIcons.shield,
            color: AppColors.danger,
          ),
          const SizedBox(height: AppDimens.lg),
          const AdminStatGrid(
            cards: [
              AdminStatCard(
                  label: 'Utilisateurs actifs',
                  value: '8 420',
                  hint: '+12,8 % sur la période'),
              AdminStatCard(
                  label: 'Nouvelles inscriptions',
                  value: '684',
                  hint: '582 joueurs · 62 agents · 40 clubs',
                  hintColor: AppColors.textMuted),
              AdminStatCard(
                  label: 'Highlights reçus',
                  value: '1 286',
                  hint: '48 en attente de validation',
                  hintColor: AppColors.textMuted),
              AdminStatCard(
                  label: 'Stockage utilisé',
                  value: '428 Go',
                  hint: '42,8 % de la capacité de démo',
                  hintColor: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          LayoutBuilder(builder: (context, c) {
            final wide = c.maxWidth > 900;
            final chart = AdminSection(
              title: 'Activité de la plateforme',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Utilisateurs actifs · 30 jours',
                          style: AppTextStyles.bodyStrong(
                              color: AppColors.primary)),
                      const Spacer(),
                      Text('Période précédente +12,8 %',
                          style: AppTextStyles.caption()),
                    ],
                  ),
                  const SizedBox(height: AppDimens.lg),
                  const SizedBox(height: 180, child: _ActivityChart()),
                  const SizedBox(height: AppDimens.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('17 sept.', style: AppTextStyles.caption()),
                      Text('1 oct.', style: AppTextStyles.caption()),
                      Text('16 oct. 2026',
                          style: AppTextStyles.caption()),
                    ],
                  ),
                ],
              ),
            );
            final engagement = AdminSection(
              title: 'L\'engagement en chiffres',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('184 620',
                      style: AppTextStyles.display()
                          .copyWith(fontSize: 24)),
                  Text('vues de vidéos · 12 480 mentions J\'aime',
                      style: AppTextStyles.caption()),
                  const SizedBox(height: AppDimens.lg),
                  Text('6 240 / 4 368',
                      style: AppTextStyles.display()
                          .copyWith(fontSize: 24)),
                  Text('messages envoyés / ayant reçu une réponse',
                      style: AppTextStyles.caption()),
                  const SizedBox(height: AppDimens.sm),
                  const AdminPill('70 % de réponses',
                      color: AppColors.success),
                  const SizedBox(height: AppDimens.lg),
                  Text('4,8 %',
                      style: AppTextStyles.display()
                          .copyWith(fontSize: 24)),
                  Text('conversion Premium · 32 nouvelles '
                      'souscriptions / 684 inscriptions',
                      style: AppTextStyles.caption()),
                ],
              ),
            );
            if (!wide) {
              return Column(children: [
                chart,
                const SizedBox(height: AppDimens.lg),
                engagement,
              ]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: chart),
                const SizedBox(width: AppDimens.lg),
                Expanded(child: engagement),
              ],
            );
          }),
          const SizedBox(height: AppDimens.section),
          AdminPageHeader(
            title: 'Les plus anciens dossiers d\'abord',
            subtitle: '',
            trailing: AdminPrimaryButton('Ouvrir la modération →',
                icon: LucideIcons.arrowRight,
                onPressed: () => context.go('/admin/moderation')),
          ),
          const SizedBox(height: AppDimens.lg),
          AdminTable(
            columns: const [
              AdminCol('Highlight / propriétaire', flex: 3),
              AdminCol('Soumis le', flex: 2),
              AdminCol('Durée / tag', flex: 2),
              AdminCol('Priorité', flex: 2),
              AdminCol('Action', flex: 1),
            ],
            rows: [
              for (final v in adminVideos.take(3))
                [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.navy700,
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusSm),
                        ),
                        child: const Icon(LucideIcons.playCircle,
                            size: 18, color: Colors.white),
                      ),
                      const SizedBox(width: AppDimens.md),
                      Expanded(
                        child: Text('${v.tag}\n${v.player}',
                            style: AppTextStyles.bodyStrong()),
                      ),
                    ],
                  ),
                  Text(v.submittedAt, style: AppTextStyles.body()),
                  Text('${v.duration} · ${v.tag.split('·').last.trim()}',
                      style: AppTextStyles.body()),
                  Text('${v.status} · 25 h', style: AppTextStyles.body()),
                  AdminLink('Examiner',
                      onTap: () =>
                          context.push('/admin/moderation/${v.id}')),
                ],
            ],
          ),
          const AdminPagination(
              summary: '1–3 sur 48 résultats · 20 par page'),
          const SizedBox(height: AppDimens.section),
          LayoutBuilder(builder: (context, c) {
            final wide = c.maxWidth > 900;
            final verifications = AdminSection(
              title: 'Vérifications · 12 en attente',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final v in adminVerifications.take(2))
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppDimens.sm),
                      child: Text(
                          '${v.name} · ${v.role} · Soumis ${v.submittedAt.toLowerCase()}',
                          style: AppTextStyles.body()),
                    ),
                  const SizedBox(height: AppDimens.sm),
                  AdminOutlineButton('Voir les demandes →',
                      onPressed: () =>
                          context.go('/admin/verifications')),
                ],
              ),
            );
            final security = AdminSection(
              title: 'Sécurité · 2 urgences',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AdminBanner(
                    title: 'M-104 · Visibilité d\'un mineur',
                    body:
                        'Consentement à contrôler · Dossier prioritaire',
                    icon: LucideIcons.shield,
                    color: AppColors.danger,
                  ),
                  const SizedBox(height: AppDimens.md),
                  AdminLink('Accéder à la protection des mineurs',
                      onTap: () => context.go('/admin/minors')),
                ],
              ),
            );
            if (!wide) {
              return Column(children: [
                verifications,
                const SizedBox(height: AppDimens.lg),
                security,
              ]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: verifications),
                const SizedBox(width: AppDimens.lg),
                Expanded(child: security),
              ],
            );
          }),
          const SizedBox(height: AppDimens.section),
          Center(
            child: Text(
              'Données de démonstration · 16 octobre 2026, 09:41 · '
              'Africa/Douala · Maquette statique, aucune opération réelle',
              style: AppTextStyles.micro(),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple 12-bar activity chart; the final bar uses the brand gradient.
class _ActivityChart extends StatelessWidget {
  const _ActivityChart();

  static const _values = [
    0.45, 0.55, 0.52, 0.68, 0.62, 0.75, 0.70, 0.85, 0.80, 0.90, 0.86, 1.0
  ];

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BarsPainter(_values),
      size: Size.infinite,
    );
  }
}

class _BarsPainter extends CustomPainter {
  const _BarsPainter(this.values);
  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final n = values.length;
    final gap = size.width * 0.02;
    final barW = (size.width - gap * (n - 1)) / n;
    final muted = Paint()..color = AppColors.muted;
    for (var i = 0; i < n; i++) {
      final h = size.height * 0.85 * values[i];
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
            i * (barW + gap), size.height - h, barW, h),
        const Radius.circular(6),
      );
      if (i == n - 1) {
        canvas.drawRRect(
            rect,
            Paint()
              ..shader = const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: AppColors.primaryGradient,
              ).createShader(rect.outerRect));
      } else {
        canvas.drawRRect(rect, muted);
      }
      // day label
      final tp = TextPainter(
        text: TextSpan(
            text: '${i + 1}',
            style: AppTextStyles.micro()),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
          canvas,
          Offset(i * (barW + gap) + barW / 2 - tp.width / 2,
              size.height - h - tp.height - 4));
    }
  }

  @override
  bool shouldRepaint(_BarsPainter oldDelegate) =>
      oldDelegate.values != values;
}
