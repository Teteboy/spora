import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_text_styles.dart';
import 'account_widgets.dart';

/// "/settings/notifications" — frame "Notifications".
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotifType {
  final String key;
  final String title;
  final String subtitle;
  final bool defaultValue;
  const _NotifType(this.key, this.title, this.subtitle, this.defaultValue);
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  static const _types = [
    _NotifType('messages', 'Nouveaux messages', 'Messages de recruteurs vérifiés', true),
    _NotifType('applications', 'Propositions et candidatures', 'Invitations et suivi de vos dossiers', true),
    _NotifType('profile_views', 'Vues du profil', 'Quand un recruteur consulte votre profil', true),
    _NotifType('likes', 'J’aime sur mes vidéos', 'Nouvelles interactions sur vos highlights', false),
    _NotifType('matches', 'Opportunités correspondantes', 'Offres adaptées à votre âge et votre poste', true),
    _NotifType('video_status', 'Statut de mes vidéos', 'Validation ou corrections nécessaires', true),
    _NotifType('news', 'Conseils et nouveautés SPORA', 'Actualités et recommandations', false),
  ];

  final Map<String, bool> _values = {for (final t in _types) t.key: t.defaultValue};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      for (final t in _types) {
        _values[t.key] = prefs.getBool('notif_${t.key}') ?? t.defaultValue;
      }
    });
  }

  Future<void> _set(String key, bool v) async {
    setState(() => _values[key] = v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_$key', v);
  }

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    return AccountScaffold(
      title: 'Notifications',
      boxedBack: true,
      onBack: () => accountBack(context, fallback: '/settings'),
      children: [
        const PageHeading('Choisissez vos alertes',
            subtitle: 'Personnalisez les notifications que vous recevez sur votre appareil.'),
        AccountCard(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg, vertical: AppDimens.sm),
          child: Column(
            children: _types
                .map((t) => SwitchRow(
                      title: t.title,
                      subtitle: t.subtitle,
                      value: _values[t.key]!,
                      onChanged: (v) => _set(t.key, v),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: AppDimens.lg),
        const InfoBanner(
          title: 'Alertes de sécurité',
          body: 'Les alertes essentielles de sécurité et de compte restent envoyées par e-mail.',
        ),
        const SizedBox(height: AppDimens.lg),
        Text('L’autorisation système peut être modifiée dans les réglages de votre appareil.',
            style: AppTextStyles.caption(color: p.text3)),
        const SizedBox(height: AppDimens.md),
        SecondaryButton(
          label: 'Ouvrir les réglages de l’appareil',
          onPressed: () => showAccountSnack(context, 'Ouverture des réglages système (démo)'),
        ),
      ],
    );
  }
}
