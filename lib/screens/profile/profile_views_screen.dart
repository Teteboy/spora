import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Vues du profil — frames "Vues du profil — Gratuit" & "— Premium".
class ProfileViewsScreen extends StatefulWidget {
  const ProfileViewsScreen({super.key});

  @override
  State<ProfileViewsScreen> createState() => _ProfileViewsScreenState();
}

class _ProfileViewsScreenState extends State<ProfileViewsScreen> {
  bool _thirtyDays = false;

  static const _weekBars = [0.35, 0.55, 0.30, 0.65, 0.5, 0.75, 0.9];
  static const _weekLabels = ['S', 'D', 'L', 'M', 'M', 'J', 'V'];

  static const _viewers = [
    _Viewer('Académie des Rives', 'Cameroun', 'Aujourd’hui à 09:10',
        'Club vérifié', true),
    _Viewer('Horizon Talent', 'Côte d’Ivoire', 'Hier à 16:20',
        'Agent vérifié', false),
    _Viewer('Étoile du Littoral', 'Côte d’Ivoire', 'Mercredi à 11:42',
        'Club vérifié', true),
  ];

  @override
  Widget build(BuildContext context) {
    final isPremium =
        context.watch<AuthProvider>().currentUser?.isPremium ?? false;

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.screenMargin, vertical: AppDimens.lg),
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
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
                Text('Vues du profil', style: AppTextStyles.h1()),
              ],
            ),
            const SizedBox(height: AppDimens.lg),
            Text('Qui a consulté mon\nprofil', style: AppTextStyles.display()),
            const SizedBox(height: AppDimens.lg),

            // Period pills
            Row(
              children: [
                _pill('7 jours', !_thirtyDays,
                    () => setState(() => _thirtyDays = false)),
                const SizedBox(width: AppDimens.md),
                _pill('30 jours', _thirtyDays,
                    () => setState(() => _thirtyDays = true)),
              ],
            ),
            const SizedBox(height: AppDimens.lg),

            // Chart card
            Container(
              padding: const EdgeInsets.all(AppDimens.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(AppDimens.radiusCard),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isPremium)
                    Container(
                      margin:
                          const EdgeInsets.only(bottom: AppDimens.md),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.premiumBg,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusPill),
                      ),
                      child: Text('Premium',
                          style: AppTextStyles.caption(
                              color: AppColors.goldDark)),
                    ),
                  if (isPremium)
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text('248', style: AppTextStyles.h1()),
                              Text(
                                  'Vues · ${_thirtyDays ? 30 : 7} jours',
                                  style: AppTextStyles.body()),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text('+18 %', style: AppTextStyles.h1()),
                              Text('Évolution',
                                  style: AppTextStyles.body()),
                            ],
                          ),
                        ),
                      ],
                    )
                  else ...[
                    Text('248 vues · +18 %', style: AppTextStyles.h1()),
                    const SizedBox(height: AppDimens.xs),
                    Text(
                        'Du 10 au 16 octobre 2026 · ${_thirtyDays ? 30 : 7} jours',
                        style: AppTextStyles.body()),
                  ],
                  const SizedBox(height: AppDimens.lg),
                  SizedBox(
                    height: 180,
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _BarsPainter(
                        _thirtyDays
                            ? List.generate(
                                30,
                                (i) =>
                                    0.3 +
                                    0.6 *
                                        ((i * 7 + 3) % 10) /
                                        10)
                            : _weekBars,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.sm),
                  if (!_thirtyDays)
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                      children: _weekLabels
                          .map((l) => Text(l,
                              style: AppTextStyles.caption()))
                          .toList(),
                    )
                  else
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text('17 sept.', style: AppTextStyles.caption()),
                        Text('16 oct.', style: AppTextStyles.caption()),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.section),

            Text('Dernières consultations', style: AppTextStyles.h1()),
            const SizedBox(height: AppDimens.md),

            if (isPremium)
              for (final v in _viewers) ...[
                _viewerCard(v),
                const SizedBox(height: AppDimens.lg),
              ]
            else ...[
              _viewerCard(_viewers.first),
              const SizedBox(height: AppDimens.lg),
              _lockedCard(),
            ],
            const SizedBox(height: AppDimens.section),
          ],
        ),
      ),
    );
  }

  Widget _pill(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryTint : AppColors.surface,
          borderRadius:
              BorderRadius.circular(AppDimens.radiusPill),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(label,
            style: AppTextStyles.bodyStrong(
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary)),
      ),
    );
  }

  Widget _viewerCard(_Viewer v) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F6EE),
              borderRadius:
                  BorderRadius.circular(AppDimens.radiusInput),
            ),
            child: const Icon(LucideIcons.shield,
                color: AppColors.clubGreen, size: 26),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(v.name, style: AppTextStyles.h3()),
                const SizedBox(height: AppDimens.xxs),
                Text('${v.country} · ${v.time}',
                    style: AppTextStyles.body()),
                const SizedBox(height: AppDimens.xs),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(
                            AppDimens.radiusPill),
                      ),
                      child: Text(v.badge,
                          style: AppTextStyles.caption(
                              color: AppColors.primary)),
                    ),
                    const SizedBox(width: AppDimens.xs),
                    const Icon(LucideIcons.badgeCheck,
                        size: 16, color: AppColors.primary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Free tier: blurred/locked viewer rows + Premium CTA.
  Widget _lockedCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimens.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < 2; i++) ...[
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryTint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.moreHorizontal,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _blurBar(160),
                      const SizedBox(height: AppDimens.sm),
                      _blurBar(220),
                    ],
                  ),
                ),
                const Icon(LucideIcons.lock,
                    color: AppColors.goldDark, size: 24),
              ],
            ),
            const SizedBox(height: AppDimens.lg),
          ],
          Text('Passer à Premium pour tout voir',
              style: AppTextStyles.h3()),
          const SizedBox(height: AppDimens.sm),
          Text(
            'Découvrez les autres visiteurs et vos statistiques détaillées. La vérification d’identité reste indépendante de l’abonnement.',
            style: AppTextStyles.body(),
          ),
          const SizedBox(height: AppDimens.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/premium'),
              icon: const Icon(LucideIcons.crown,
                  color: AppColors.navy900),
              label: Text('Passer à Premium',
                  style: AppTextStyles.button(color: AppColors.navy900)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusCard)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blurBar(double width) => Container(
        width: width,
        height: 12,
        decoration: BoxDecoration(
          color: AppColors.muted,
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        ),
      );
}

class _Viewer {
  final String name;
  final String country;
  final String time;
  final String badge;
  final bool isClub;
  const _Viewer(this.name, this.country, this.time, this.badge, this.isClub);
}

class _BarsPainter extends CustomPainter {
  final List<double> values;
  _BarsPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final n = values.length;
    final gap = size.width * 0.02;
    final barW = (size.width - gap * (n - 1)) / n;
    for (var i = 0; i < n; i++) {
      final h = size.height * values[i];
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(i * (barW + gap), size.height - h, barW, h),
        const Radius.circular(4),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.primaryGradient,
          ).createShader(rect.outerRect),
      );
    }
  }

  @override
  bool shouldRepaint(_BarsPainter old) => old.values != values;
}
