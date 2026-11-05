import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import 'account_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// "/settings/security" — frame "Sécurité et appareils connectés".
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _Device {
  final String id;
  final String name;
  final String meta;
  final IconData icon;
  final bool current;
  const _Device(this.id, this.name, this.meta, this.icon, {this.current = false});
}

class _SecurityScreenState extends State<SecurityScreen> {
  final List<_Device> _devices = [
    const _Device('d1', 'Android · Appareil actuel', 'Paris, France · Aujourd’hui à 09:41',
        LucideIcons.smartphone, current: true),
    const _Device('d2', 'Chrome · Windows', 'Paris, France · Hier à 18:20', LucideIcons.monitor),
    const _Device('d3', 'Safari · iPad', 'Lyon, France · 12 octobre à 21:05', LucideIcons.tablet),
  ];

  Future<void> _revoke(_Device d) async {
    final ok = await showAccountDialog<bool>(
      context: context,
      title: 'Déconnecter cet appareil ?',
      message: '${d.name} devra se reconnecter avec votre mot de passe.',
      primaryLabel: 'Déconnecter',
      secondaryLabel: 'Annuler',
      primaryValue: true,
      secondaryValue: false,
      primaryDanger: true,
    );
    if (ok != true || !mounted) return;
    setState(() => _devices.remove(d));
    showAccountSnack(context, '${d.name} a été déconnecté');
  }

  Future<void> _revokeOthers() async {
    final others = _devices.where((d) => !d.current).toList();
    if (others.isEmpty) {
      showAccountSnack(context, 'Aucun autre appareil connecté');
      return;
    }
    final ok = await showAccountDialog<bool>(
      context: context,
      title: 'Déconnecter les autres appareils ?',
      message: '${others.length} appareil(s) seront déconnectés. Cette session reste active.',
      primaryLabel: 'Déconnecter',
      secondaryLabel: 'Annuler',
      primaryValue: true,
      secondaryValue: false,
      primaryDanger: true,
    );
    if (ok != true || !mounted) return;
    setState(() => _devices.removeWhere((d) => !d.current));
    showAccountSnack(context, 'Les autres appareils ont été déconnectés');
  }

  Future<void> _signOutAll() async {
    final ok = await showAccountDialog<bool>(
      context: context,
      title: 'Se déconnecter partout ?',
      message: 'Toutes les sessions, y compris celle-ci, seront fermées.',
      primaryLabel: 'Se déconnecter de tous les appareils',
      secondaryLabel: 'Annuler',
      primaryValue: true,
      secondaryValue: false,
      primaryDanger: true,
    );
    if (ok != true || !mounted) return;
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    context.go('/login');
  }

  void _changePassword() {
    final p = AccountPalette.of(context);
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: p.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusSheet))),
      builder: (ctx) => const _ChangePasswordSheet(),
    ).then((done) {
      if (done == true && mounted) showAccountSnack(context, 'Mot de passe mis à jour');
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    final email = context.watch<AuthProvider>().currentUser?.email ?? 'jordan.mbala@email.com';
    return AccountScaffold(
      title: 'Sécurité',
      boxedBack: true,
      onBack: () => accountBack(context, fallback: '/settings'),
      children: [
        const PageHeading('Protégez votre compte'),
        AccountCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.mailCheck, color: AppColors.primary, size: 22),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Adresse e-mail vérifiée', style: AppTextStyles.bodyStrong(color: p.text)),
                        Text(email, style: AppTextStyles.caption(color: p.text2)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.md),
              SecondaryButton(label: 'Changer le mot de passe', height: 48, onPressed: _changePassword),
            ],
          ),
        ),
        const SectionTitle('Appareils connectés'),
        ..._devices.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.md),
              child: AccountCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(d.icon, color: AppColors.primary, size: 22),
                        const SizedBox(width: AppDimens.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d.name, style: AppTextStyles.bodyStrong(color: p.text)),
                              Text(d.meta, style: AppTextStyles.caption(color: p.text3)),
                              if (d.current) ...[
                                const SizedBox(height: AppDimens.sm),
                                StatusPill(
                                    label: 'Cette session',
                                    color: AppColors.clubGreen,
                                    background: p.successTint),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (!d.current) ...[
                      const SizedBox(height: AppDimens.md),
                      SecondaryButton(
                          label: 'Déconnecter cet appareil', height: 48, onPressed: () => _revoke(d)),
                    ],
                  ],
                ),
              ),
            )),
        SecondaryButton(label: 'Déconnecter les autres appareils', onPressed: _revokeOthers),
        const SizedBox(height: AppDimens.md),
        SecondaryButton(
          label: 'Se déconnecter de tous les appareils',
          textColor: AppColors.errorText,
          onPressed: _signOutAll,
        ),
        const SizedBox(height: AppDimens.lg),
        const InfoBanner(
          title: 'Une activité inhabituelle ?',
          body:
              'Changez votre mot de passe et déconnectez les appareils que vous ne reconnaissez pas. Les villes de connexion sont approximatives.',
        ),
      ],
    );
  }
}

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (_current.text.isEmpty) {
      setState(() => _error = 'Saisissez votre mot de passe actuel.');
      return;
    }
    if (_new.text.length < 8) {
      setState(() => _error = 'Le nouveau mot de passe doit contenir au moins 8 caractères.');
      return;
    }
    if (_new.text != _confirm.text) {
      setState(() => _error = 'Les mots de passe ne correspondent pas.');
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppDimens.xl, AppDimens.md, AppDimens.xl, AppDimens.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration:
                      BoxDecoration(color: p.border, borderRadius: BorderRadius.circular(AppDimens.radiusPill)),
                ),
              ),
              const SizedBox(height: AppDimens.xl),
              Text('Changer le mot de passe', style: AppTextStyles.h1(color: p.text)),
              const SizedBox(height: AppDimens.lg),
              LabeledField(label: 'Mot de passe actuel', controller: _current, obscure: true),
              LabeledField(
                  label: 'Nouveau mot de passe', controller: _new, obscure: true, hint: '8 caractères minimum'),
              LabeledField(
                  label: 'Confirmer le nouveau mot de passe',
                  controller: _confirm,
                  obscure: true,
                  errorText: _error),
              const SizedBox(height: AppDimens.sm),
              GradientButton(label: 'Mettre à jour', loading: _loading, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
