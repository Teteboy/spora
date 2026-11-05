import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'account_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// "/settings/privacy" — frame "Confidentialité et utilisateurs bloqués".
class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _BlockedUser {
  final String name;
  final String date;
  const _BlockedUser(this.name, this.date);

  String get initials =>
      name.split(' ').where((s) => s.isNotEmpty).take(2).map((s) => s[0].toUpperCase()).join();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _visible = true;
  bool _hideContact = true;
  bool _hideLocation = true;
  final List<_BlockedUser> _blocked = [
    const _BlockedUser('Malik Diop', '14 octobre 2026'),
    const _BlockedUser('Kevin Ondo', '2 septembre 2026'),
  ];

  Future<void> _toggleVisible(bool v) async {
    if (!v) {
      final ok = await showAccountDialog<bool>(
        context: context,
        title: 'Masquer votre profil ?',
        message:
            'Votre profil n’apparaîtra plus dans la recherche ni dans la découverte. Vos conversations en cours restent accessibles.',
        primaryLabel: 'Masquer mon profil',
        secondaryLabel: 'Annuler',
        primaryValue: true,
        secondaryValue: false,
      );
      if (ok != true) return;
    }
    if (!mounted) return;
    setState(() => _visible = v);
    showAccountSnack(context, v ? 'Profil visible dans la découverte' : 'Profil masqué de la recherche');
  }

  void _unblock(_BlockedUser u) {
    final index = _blocked.indexOf(u);
    setState(() => _blocked.remove(u));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy800,
        content: Text('${u.name} a été débloqué', style: AppTextStyles.body(color: AppColors.textLight)),
        action: SnackBarAction(
          label: 'Annuler',
          textColor: AppColors.gold,
          onPressed: () {
            if (!mounted) return;
            setState(() => _blocked.insert(index.clamp(0, _blocked.length), u));
          },
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    return AccountScaffold(
      title: 'Confidentialité',
      boxedBack: true,
      onBack: () => accountBack(context, fallback: '/settings'),
      children: [
        const PageHeading('Votre visibilité, vos choix'),
        AccountCard(
          padding: const EdgeInsets.fromLTRB(AppDimens.lg, AppDimens.sm, AppDimens.lg, AppDimens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchRow(
                title: 'Visible dans la découverte',
                subtitle: _visible
                    ? 'Uniquement pour les agents et clubs vérifiés'
                    : 'Profil masqué : absent de la recherche et de la découverte',
                value: _visible,
                onChanged: _toggleVisible,
              ),
              SwitchRow(
                title: 'Masquer mes coordonnées',
                subtitle: 'Votre e-mail et votre téléphone ne sont pas publics',
                value: _hideContact,
                onChanged: (v) => setState(() => _hideContact = v),
              ),
              SwitchRow(
                title: 'Masquer ma localisation exacte',
                subtitle: 'Seule votre ville est affichée',
                value: _hideLocation,
                onChanged: (v) => setState(() => _hideLocation = v),
              ),
              const SizedBox(height: AppDimens.sm),
              Text(
                (_hideContact && _hideLocation)
                    ? 'La protection des coordonnées et de la localisation exacte reste active.'
                    : 'Attention : certaines informations personnelles sont visibles.',
                style: AppTextStyles.caption(
                    color: (_hideContact && _hideLocation) ? p.text3 : AppColors.errorText),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.lg),
        const InfoBanner(
          title: 'Protection des mineurs',
          body:
              'Le consentement du représentant légal est requis avant toute apparition dans la découverte. Les échanges restent encadrés.',
        ),
        SectionTitle('Utilisateurs bloqués · ${_blocked.length}'),
        if (_blocked.isEmpty)
          AccountCard(
            child: Row(
              children: [
                Icon(LucideIcons.checkCircle, color: p.text3),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: Text('Aucun utilisateur bloqué.', style: AppTextStyles.body(color: p.text2)),
                ),
              ],
            ),
          )
        else
          ..._blocked.map((u) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.md),
                child: AccountCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: p.tint,
                            child: Text(u.initials,
                                style: AppTextStyles.bodyStrong(color: AppColors.primary)),
                          ),
                          const SizedBox(width: AppDimens.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(u.name, style: AppTextStyles.bodyStrong(color: p.text)),
                                Text('Bloqué le ${u.date}', style: AppTextStyles.caption(color: p.text3)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.md),
                      SecondaryButton(label: 'Débloquer', height: 48, onPressed: () => _unblock(u)),
                    ],
                  ),
                ),
              )),
        const SizedBox(height: AppDimens.sm),
        Text('Les utilisateurs bloqués ne peuvent plus vous contacter ni consulter votre profil.',
            style: AppTextStyles.caption(color: p.text3)),
        const SizedBox(height: AppDimens.lg),
        Material(
          color: p.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppDimens.radiusCard),
            onTap: () => showAccountSnack(context, 'Politique de confidentialité (bientôt disponible)'),
            child: SizedBox(
              height: 52,
              child: Center(
                child: Text('Consulter la politique de confidentialité',
                    style: AppTextStyles.button(color: AppColors.primary)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
