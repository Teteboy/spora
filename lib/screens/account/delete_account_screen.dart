import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import 'account_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// /delete-account — "Supprimer — Informations" puis "Supprimer — Confirmation".
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool _confirmStep = false;
  bool _deleting = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _confirmStep
          ? _DeleteConfirmation(
              key: const ValueKey('confirm'),
              deleting: _deleting,
              onBack: () => setState(() => _confirmStep = false),
              onKeep: () => accountBack(context),
              onDelete: _delete,
            )
          : _DeleteInformations(
              key: const ValueKey('info'),
              onContinue: () => setState(() => _confirmStep = true),
              onKeep: () => accountBack(context),
            ),
    );
  }

  Future<void> _delete() async {
    if (_deleting) return;
    setState(() => _deleting = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    showAccountSnack(context, 'Votre compte a été supprimé.');
    context.go('/welcome');
  }
}

// ── Étape 1 — Informations ──────────────────────────────────────────────────

class _DeleteInformations extends StatelessWidget {
  const _DeleteInformations(
      {super.key, required this.onContinue, required this.onKeep});

  final VoidCallback onContinue;
  final VoidCallback onKeep;

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    return AccountScaffold(
      title: 'Supprimer — Informations',
      onBack: () => accountBack(context),
      children: [
        const Icon(LucideIcons.trash2, size: 56, color: AppColors.errorText),
        const SizedBox(height: AppDimens.lg),
        const PageHeading(
          'Avant de partir',
          subtitle:
              'La suppression retire votre profil public et vos contenus selon les règles de conservation applicables.',
        ),
        AccountCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              IconRow(
                icon: LucideIcons.download,
                title: 'Exporter vos données',
                subtitle: 'Téléchargez une copie avant de continuer.',
                onTap: () => showAccountSnack(
                    context, 'Export de vos données demandé.'),
              ),
              const RowDivider(),
              IconRow(
                icon: LucideIcons.crown,
                title: 'Vérifier votre abonnement',
                subtitle: 'La résiliation suit les règles du prestataire.',
                onTap: () => context.push('/premium/subscription'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.section),
        DangerButton(
            label: 'Continuer la suppression', onPressed: onContinue),
        const SizedBox(height: AppDimens.md),
        SecondaryButton(label: 'Garder mon compte', onPressed: onKeep),
        const SizedBox(height: AppDimens.lg),
        Text(
          'Délais et obligations de conservation à valider juridiquement avant lancement.',
          style: AppTextStyles.body(color: p.text2),
        ),
      ],
    );
  }
}

// ── Étape 2 — Confirmation ──────────────────────────────────────────────────

class _DeleteConfirmation extends StatefulWidget {
  const _DeleteConfirmation({
    super.key,
    required this.deleting,
    required this.onBack,
    required this.onKeep,
    required this.onDelete,
  });

  final bool deleting;
  final VoidCallback onBack;
  final VoidCallback onKeep;
  final VoidCallback onDelete;

  @override
  State<_DeleteConfirmation> createState() => _DeleteConfirmationState();
}

class _DeleteConfirmationState extends State<_DeleteConfirmation> {
  final _confirm = TextEditingController();
  final _password = TextEditingController();
  bool _understood = false;

  @override
  void dispose() {
    _confirm.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _ready =>
      _confirm.text.trim().toUpperCase() == 'SUPPRIMER' &&
      _password.text.isNotEmpty &&
      _understood;

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    final name =
        context.read<AuthProvider>().currentUser?.name ?? 'votre compte';
    return AccountScaffold(
      title: 'Supprimer — Confirmation',
      onBack: widget.onBack,
      children: [
        const Icon(LucideIcons.trash2, size: 56, color: AppColors.errorText),
        const SizedBox(height: AppDimens.lg),
        PageHeading(
          'Confirmer la suppression',
          subtitle:
              'Cette demande concerne le compte de $name. Une confirmation supplémentaire protège votre compte.',
        ),
        LabeledField(
          label: 'Pour confirmer, saisissez SUPPRIMER',
          hint: 'SUPPRIMER',
          controller: _confirm,
          onChanged: (_) => setState(() {}),
        ),
        LabeledField(
          label: 'Votre mot de passe',
          hint: '••••••••••',
          controller: _password,
          obscure: true,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppDimens.xs),
        InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          onTap: () => setState(() => _understood = !_understood),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.sm),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: Checkbox(
                    value: _understood,
                    activeColor: AppColors.primary,
                    onChanged: (v) =>
                        setState(() => _understood = v ?? false),
                  ),
                ),
                const SizedBox(width: AppDimens.sm),
                Expanded(
                  child: Text(
                    'Je comprends les conséquences de cette demande.',
                    style: AppTextStyles.body(color: p.text),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimens.lg),
        DangerButton(
          label: widget.deleting
              ? 'Suppression en cours…'
              : 'Supprimer définitivement mon compte',
          onPressed: _ready && !widget.deleting ? widget.onDelete : null,
        ),
        const SizedBox(height: AppDimens.md),
        SecondaryButton(label: 'Garder mon compte', onPressed: widget.onKeep),
        const SizedBox(height: AppDimens.lg),
        Text(
          'Délais et obligations de conservation à valider juridiquement avant lancement.',
          style: AppTextStyles.body(color: p.text2),
        ),
      ],
    );
  }
}
