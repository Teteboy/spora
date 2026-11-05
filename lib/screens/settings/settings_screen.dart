import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/theme_provider.dart';
import '../account/account_widgets.dart';
import 'app_locale.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// "/settings" — frame "Paramètres".
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dataSaver = true;
  bool _wifiUploads = true;
  int _autoplay = 0; // 0 Wi-Fi seulement, 1 Toujours, 2 Jamais
  int _quality = 0; // 0 Auto, 1 360p, 2 720p

  @override
  void initState() {
    super.initState();
    AppLocale.load();
    DataSaverPrefs.load().then((m) {
      if (!mounted) return;
      setState(() {
        _dataSaver = m[DataSaverPrefs.keySaver] as bool;
        _autoplay = m[DataSaverPrefs.keyAutoplay] as int;
        _quality = m[DataSaverPrefs.keyQuality] as int;
        _wifiUploads = m[DataSaverPrefs.keyWifiUploads] as bool;
      });
    });
  }

  void _persist() => DataSaverPrefs.save(
      saver: _dataSaver, autoplay: _autoplay, quality: _quality, wifiUploads: _wifiUploads);

  void _setDataSaver(bool v) {
    setState(() {
      _dataSaver = v;
      if (v) {
        _wifiUploads = true;
        _autoplay = 2; // no autoplay
        _quality = 1;
      }
    });
    _persist();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLocale.notifier,
      builder: (context, locale, _) {
        final t = AppLocale.t;
        final themeProvider = context.watch<ThemeProvider>();
        final mode = themeProvider.themeMode;
        final p = AccountPalette.of(context);

        return AccountScaffold(
          title: t('Paramètres', 'Settings'),
          onBack: () => accountBack(context, fallback: '/profile'),
          children: [
            _Header(t('Préférences', 'Preferences')),
            AccountCard(
              padding: const EdgeInsets.symmetric(vertical: AppDimens.sm),
              child: Column(
                children: [
                  _OptionsRow(
                    icon: LucideIcons.languages,
                    title: t('Langue', 'Language'),
                    options: const ['Français', 'English'],
                    selected: AppLocale.isEnglish ? 1 : 0,
                    onSelect: (i) => AppLocale.set(i == 1 ? AppLocale.en : AppLocale.fr),
                  ),
                  _OptionsRow(
                    icon: LucideIcons.moon,
                    title: t('Thème', 'Theme'),
                    options: [t('Système', 'System'), t('Clair', 'Light'), t('Sombre', 'Dark')],
                    selected: mode == ThemeMode.system ? 0 : (mode == ThemeMode.light ? 1 : 2),
                    onSelect: (i) => themeProvider.setThemeMode(
                        const [ThemeMode.system, ThemeMode.light, ThemeMode.dark][i]),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg),
                    child: SwitchRow(
                      title: t('Mode économie de données', 'Data saver mode'),
                      value: _dataSaver,
                      onChanged: _setDataSaver,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppDimens.lg, 0, AppDimens.lg, AppDimens.sm),
                    child: Text(
                      t('Posters avant lecture, qualité réduite, envois en Wi-Fi uniquement, pas de lecture automatique. Économies variables selon votre usage.',
                          'Posters before playback, reduced quality, Wi-Fi-only uploads, no autoplay. Savings vary with usage.'),
                      style: AppTextStyles.caption(color: p.text3),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg),
                    child: SwitchRow(
                      title: t('Envois vidéo en Wi-Fi uniquement', 'Upload videos on Wi-Fi only'),
                      value: _wifiUploads,
                      onChanged: (v) {
                        setState(() => _wifiUploads = v);
                        _persist();
                      },
                    ),
                  ),
                  _OptionsRow(
                    icon: LucideIcons.play,
                    title: t('Lecture automatique', 'Autoplay'),
                    options: [t('Wi-Fi seulement', 'Wi-Fi only'), t('Toujours', 'Always'), t('Jamais', 'Never')],
                    selected: _autoplay,
                    onSelect: (i) {
                      setState(() => _autoplay = i);
                      _persist();
                    },
                  ),
                  _OptionsRow(
                    icon: LucideIcons.video,
                    title: t('Qualité vidéo', 'Video quality'),
                    options: const ['Auto', '360p', '720p'],
                    selected: _quality,
                    onSelect: (i) {
                      setState(() => _quality = i);
                      _persist();
                    },
                  ),
                ],
              ),
            ),
            _Header(t('Votre compte', 'Your account')),
            _LinkCard(rows: [
              _Link(LucideIcons.bell, t('Notifications', 'Notifications'),
                  t('Choisir les alertes reçues', 'Choose which alerts you get'),
                  () => context.push('/settings/notifications')),
              _Link(LucideIcons.shield, t('Confidentialité', 'Privacy'),
                  t('Visibilité, coordonnées, blocages', 'Visibility, contact details, blocks'),
                  () => context.push('/settings/privacy')),
              _Link(LucideIcons.lock, t('Sécurité', 'Security'),
                  t('Mot de passe et appareils', 'Password and devices'),
                  () => context.push('/settings/security')),
            ]),
            _Header(t('Vos données', 'Your data')),
            _LinkCard(rows: [
              _Link(LucideIcons.download, t('Exporter mes données', 'Export my data'),
                  t('Demander une copie de vos informations', 'Request a copy of your information'),
                  () => showAccountSnack(context,
                      t('Demande envoyée. Vous recevrez un e-mail.', 'Request sent. You will receive an e-mail.'))),
              _Link(LucideIcons.trash2, t('Supprimer mon compte', 'Delete my account'),
                  t('Confirmation en deux étapes', 'Two-step confirmation'),
                  () => context.push('/delete-account')),
            ]),
            _Header(t('Aide', 'Help')),
            _LinkCard(rows: [
              _Link(LucideIcons.helpCircle, t('Aide et support', 'Help & support'),
                  t('FAQ et contact', 'FAQ and contact'), () => context.push('/help')),
              _Link(LucideIcons.flag, t('Signaler un problème', 'Report a problem'),
                  t('Bug, contenu ou comportement', 'Bug, content or behaviour'), () => context.push('/report')),
            ]),
            _Header(t('À propos', 'About')),
            _LinkCard(rows: [
              _Link(LucideIcons.info, 'SPORA · Version 1.0',
                  t('Maquette de démonstration', 'Demo prototype'), () => _about(context)),
              _Link(LucideIcons.fileText, t('Conditions d’utilisation', 'Terms of use'), null,
                  () => showAccountSnack(context, t('Bientôt disponible', 'Coming soon'))),
              _Link(LucideIcons.shieldCheck, t('Politique de confidentialité', 'Privacy policy'), null,
                  () => showAccountSnack(context, t('Bientôt disponible', 'Coming soon'))),
            ]),
          ],
        );
      },
    );
  }

  void _about(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'SPORA',
      applicationVersion: '1.0.0',
      applicationLegalese: '© SPORA',
      children: [
        const SizedBox(height: AppDimens.md),
        Text(
          AppLocale.t('La plateforme qui connecte joueurs, agents et clubs.',
              'The platform connecting players, agents and clubs.'),
          style: AppTextStyles.body(),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.lg, bottom: AppDimens.md),
      child: Text(text, style: AppTextStyles.h2(color: AccountPalette.of(context).text)),
    );
  }
}

/// Row with icon, title and inline "A · B · C" choices (selected in brand blue).
class _OptionsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelect;

  const _OptionsRow({
    required this.icon,
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg, vertical: AppDimens.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: AppDimens.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body(color: p.text)),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (var i = 0; i < options.length; i++) ...[
                      Semantics(
                        button: true,
                        selected: i == selected,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                          onTap: () => onSelect(i),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                            child: Text(
                              options[i],
                              style: i == selected
                                  ? AppTextStyles.bodyStrong(color: AppColors.primary)
                                  : AppTextStyles.body(color: p.text2),
                            ),
                          ),
                        ),
                      ),
                      if (i < options.length - 1)
                        Text(' · ', style: AppTextStyles.body(color: p.text3)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Link {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const _Link(this.icon, this.title, this.subtitle, this.onTap);
}

class _LinkCard extends StatelessWidget {
  final List<_Link> rows;
  const _LinkCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return AccountCard(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.sm),
      child: Column(
        children: rows
            .map((r) => IconRow(
                  icon: r.icon,
                  title: r.title,
                  subtitle: r.subtitle,
                  onTap: r.onTap,
                  chevron: true,
                ))
            .toList(),
      ),
    );
  }
}
