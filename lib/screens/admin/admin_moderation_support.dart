import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'admin_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Content only: navigation and the administration top bar belong to the shell.
class ModerationPage extends StatelessWidget {
  const ModerationPage({super.key, required this.title, required this.subtitle, required this.children});
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.appBg,
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AdminPageHeader(title: title, subtitle: subtitle, trailing: const Text('17 sept. – 16 oct. 2026')),
        const SizedBox(height: 28),
        for (final child in children) ...[child, const SizedBox(height: 24)],
        Text('Données de démonstration · 16 octobre 2026, 09:41 · Africa/Douala · Aucune opération réelle', style: AppTextStyles.micro()),
      ]),
    ),
  );
}

class ModerationColumns extends StatelessWidget {
  const ModerationColumns({super.key, required this.left, required this.right, this.leftFlex = 2});
  final Widget left;
  final Widget right;
  final int leftFlex;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    if (constraints.maxWidth < 760) {
      return Column(children: [left, const SizedBox(height: 24), right]);
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(flex: leftFlex, child: left), const SizedBox(width: 24), Expanded(child: right),
    ]);
  });
}

class ModerationText extends StatelessWidget {
  const ModerationText(this.text, {super.key, this.strong = false});
  final String text;
  final bool strong;
  @override
  Widget build(BuildContext context) => Text(text, style: strong ? AppTextStyles.bodyStrong() : AppTextStyles.body());
}

class ModerationSearch extends StatelessWidget {
  const ModerationSearch({super.key, required this.onChanged, this.hint = 'Rechercher un nom, une référence…'});
  final ValueChanged<String> onChanged;
  final String hint;
  @override
  Widget build(BuildContext context) => SizedBox(width: 300, child: TextField(
    onChanged: onChanged,
    style: AppTextStyles.body(),
    decoration: InputDecoration(hintText: hint, prefixIcon: const Icon(LucideIcons.search, color: AppColors.primary),
      filled: true, fillColor: AppColors.surface, isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border))),
  ));
}

class ModerationFilter extends StatelessWidget {
  const ModerationFilter({super.key, required this.value, required this.options, required this.onChanged});
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    initialValue: value, onSelected: onChanged,
    itemBuilder: (_) => options.map((s) => PopupMenuItem(value: s, child: Text(s))).toList(),
    child: AdminFilter(value, selected: value != options.first),
  );
}

class ProtectedDocument extends StatelessWidget {
  const ProtectedDocument(this.title, {super.key});
  final String title;
  @override
  Widget build(BuildContext context) => AdminCard(color: AppColors.appBg, child: Column(children: [
    const SizedBox(height: 12), const Icon(LucideIcons.fileText, color: AppColors.primary, size: 36),
    const SizedBox(height: 16), Text(title, style: AppTextStyles.bodyStrong()),
    const SizedBox(height: 16), Text('APERÇU FICTIF · DONNÉES MASQUÉES', style: AppTextStyles.micro()),
    const SizedBox(height: 12), Container(width: 130, height: 10, color: AppColors.border), const SizedBox(height: 12),
  ]));
}

void moderationNotice(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$message · Démonstration')));
}

/// Mandatory reason and explicit confirmation for sensitive local mock actions.
Future<bool> confirmModeration(BuildContext context, {
  required String title, required String body, required String confirmLabel,
  String initialReason = '', bool destructive = true, bool deletion = false,
}) async {
  final result = await showDialog<bool>(context: context, barrierDismissible: false,
    builder: (_) => _DecisionDialog(title: title, body: body, confirmLabel: confirmLabel,
      initialReason: initialReason, destructive: destructive, deletion: deletion));
  return result ?? false;
}

class _DecisionDialog extends StatefulWidget {
  const _DecisionDialog({required this.title, required this.body, required this.confirmLabel,
    required this.initialReason, required this.destructive, required this.deletion});
  final String title, body, confirmLabel, initialReason;
  final bool destructive, deletion;
  @override
  State<_DecisionDialog> createState() => _DecisionDialogState();
}

class _DecisionDialogState extends State<_DecisionDialog> {
  final _form = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: AppColors.surface, scrollable: true,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    title: Text(widget.title, style: AppTextStyles.h1()),
    content: SizedBox(width: 510, child: Form(key: _form, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text(widget.body, style: AppTextStyles.body()), const SizedBox(height: 24),
      TextFormField(initialValue: widget.initialReason, maxLines: 4,
        decoration: const InputDecoration(labelText: 'Motif obligatoire', border: OutlineInputBorder()),
        validator: (v) => v == null || v.trim().isEmpty ? 'Veuillez saisir un motif.' : null),
      const SizedBox(height: 20),
      if (widget.deletion) ...[
        const AdminBanner(title: 'Délais de suppression', body: 'Vidéos retirées sous 24 h. Données supprimées ou anonymisées sous 30 jours. Pièces comptables conservées selon les obligations légales.', color: AppColors.danger, icon: LucideIcons.shield),
        const SizedBox(height: 16),
        TextFormField(decoration: const InputDecoration(labelText: 'Saisir SUPPRIMER pour confirmer', border: OutlineInputBorder()),
          validator: (v) => v?.trim() != 'SUPPRIMER' ? 'Saisissez SUPPRIMER.' : null), const SizedBox(height: 16),
      ],
      const AdminBanner(title: 'Notification et traçabilité', body: 'Une notification est envoyée à l’utilisateur. Le motif, la cible et votre identité sont ajoutés au journal d’audit. Cette maquette ne transmet aucune donnée.'),
    ]))),
    actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
    actions: [AdminOutlineButton('Annuler', onPressed: () => Navigator.pop(context, false)),
      AdminPrimaryButton(widget.confirmLabel, icon: widget.destructive ? LucideIcons.x : LucideIcons.check,
        color: widget.destructive ? AppColors.errorText : AppColors.primary,
        onPressed: () { if (_form.currentState!.validate()) Navigator.pop(context, true); })],
  );
}
