import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import 'account_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// What is being reported.
enum ReportKind { problem, profile, message }

/// "/report" — frames "Signaler un problème" + "M06 · Signalements et
/// confirmation". Optionally pass [kind] / [targetName] (e.g. from
/// `?type=profile&target=Horizon%20Talent`) to report a profile or message.
class ReportProblemScreen extends StatefulWidget {
  final ReportKind kind;
  final String? targetName;

  const ReportProblemScreen({super.key, this.kind = ReportKind.problem, this.targetName});

  /// Helper to build from go_router query parameters.
  factory ReportProblemScreen.fromQuery(Map<String, String> q) {
    final kind = switch (q['type']) {
      'profile' => ReportKind.profile,
      'message' => ReportKind.message,
      _ => ReportKind.problem,
    };
    return ReportProblemScreen(kind: kind, targetName: q['target']);
  }

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  static const _maxChars = 2000;

  final _subject = TextEditingController();
  final _description = TextEditingController();
  final _email = TextEditingController();
  final _categoryCtl = TextEditingController();
  String? _category;
  String? _attachment;
  bool _sending = false;
  String? _ticket;
  bool _showErrors = false;

  List<String> get _categories => switch (widget.kind) {
        ReportKind.profile => const [
            'Usurpation d’identité',
            'Faux profil',
            'Contenu inapproprié',
            'Comportement abusif',
            'Autre',
          ],
        ReportKind.message => const [
            'Demande de coordonnées personnelles',
            'Harcèlement ou menaces',
            'Arnaque ou demande d’argent',
            'Spam',
            'Autre',
          ],
        ReportKind.problem => const [
            'Lecture d’une vidéo',
            'Publication d’un highlight',
            'Connexion et compte',
            'Messagerie',
            'Paiement et Premium',
            'Autre',
          ],
      };

  @override
  void initState() {
    super.initState();
    _description.addListener(() => setState(() {}));
    _subject.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_email.text.isEmpty) {
      _email.text = context.read<AuthProvider>().currentUser?.email ?? 'jordan.mbala@email.com';
    }
  }

  @override
  void dispose() {
    _subject.dispose();
    _description.dispose();
    _email.dispose();
    _categoryCtl.dispose();
    super.dispose();
  }

  bool get _isProblem => widget.kind == ReportKind.problem;

  bool get _valid =>
      _category != null &&
      _description.text.trim().length >= 10 &&
      (!_isProblem || _subject.text.trim().isNotEmpty);

  Future<void> _pickCategory() async {
    final p = AccountPalette.of(context);
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: p.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusSheet))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppDimens.xl, 0, AppDimens.xl, AppDimens.sm),
                child: Text('Catégorie', style: AppTextStyles.h2(color: p.text)),
              ),
              ..._categories.map((c) => ListTile(
                    title: Text(c, style: AppTextStyles.body(color: p.text)),
                    trailing: c == _category
                        ? const Icon(LucideIcons.check, color: AppColors.primary)
                        : null,
                    onTap: () => Navigator.pop(ctx, c),
                  )),
            ],
          ),
        ),
      ),
    );
    if (picked != null) {
      setState(() {
        _category = picked;
        _categoryCtl.text = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_valid) {
      setState(() => _showErrors = true);
      return;
    }
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _sending = false;
      _ticket = 'SIG-${(math.Random().nextInt(900) + 100).toString().padLeft(3, '0')}';
    });
  }

  String get _title => switch (widget.kind) {
        ReportKind.profile => 'Signaler',
        ReportKind.message => 'Signaler',
        ReportKind.problem => 'Signaler un problème',
      };

  @override
  Widget build(BuildContext context) {
    if (_ticket != null) return _confirmation(context);
    final p = AccountPalette.of(context);

    return AccountScaffold(
      title: _title,
      boxedBack: _isProblem,
      bottom: GradientButton(
        label: 'Envoyer le signalement',
        loading: _sending,
        onPressed: _submit,
      ),
      children: [
        if (!_isProblem) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: StatusPill(
                label: widget.kind == ReportKind.profile ? 'Profil' : 'Message',
                color: AppColors.primary,
                background: p.tint),
          ),
          const SizedBox(height: AppDimens.lg),
          Text(widget.kind == ReportKind.profile ? 'Signaler ce profil' : 'Signaler ce message',
              style: AppTextStyles.h1(color: p.text).copyWith(fontSize: 24, height: 30 / 24)),
          const SizedBox(height: AppDimens.lg),
          InfoBanner(
            icon: LucideIcons.info,
            title: widget.kind == ReportKind.profile
                ? 'Profil : ${widget.targetName ?? 'Utilisateur'}'
                : 'Conversation : ${widget.targetName ?? 'Utilisateur'}',
            body: widget.kind == ReportKind.profile
                ? 'Identité ou comportement à examiner.'
                : 'Seul le message choisi et son contexte pertinent seront transmis.',
          ),
          const SizedBox(height: AppDimens.lg),
        ] else
          const PageHeading('Décrivez ce qui ne va pas',
              subtitle: 'Vos précisions nous aident à comprendre et à corriger le problème.'),
        LabeledField(
          label: _isProblem ? 'Catégorie du problème *' : 'Catégorie *',
          controller: _categoryCtl,
          hint: 'Choisir une catégorie',
          readOnly: true,
          onTap: _pickCategory,
          trailing: Icon(LucideIcons.chevronDown, color: p.text3, size: 28),
          errorText: _showErrors && _category == null ? 'Choisissez une catégorie.' : null,
        ),
        if (_isProblem)
          LabeledField(
            label: 'Objet *',
            controller: _subject,
            hint: 'Ex. La vidéo reste en chargement',
            errorText: _showErrors && _subject.text.trim().isEmpty ? 'Indiquez un objet.' : null,
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimens.sm, left: 2),
          child: Text(_isProblem ? 'Description *' : 'Informations complémentaires *',
              style: AppTextStyles.caption(color: p.text)),
        ),
        LabeledField(
          label: 'Que s’est-il passé ?',
          controller: _description,
          hint: 'Décrivez les étapes, le moment et ce que vous attendiez.',
          maxLines: 6,
          maxLength: _maxChars,
          errorText: _showErrors && _description.text.trim().length < 10
              ? 'Ajoutez au moins 10 caractères.'
              : null,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimens.lg),
          child: Text('${_description.text.length} / 2 000 caractères',
              style: AppTextStyles.caption(color: p.text3)),
        ),
        UploadCard(
          icon: LucideIcons.imagePlus,
          title: 'Ajouter une capture d’écran',
          hint: _isProblem
              ? 'PNG ou JPG · 10 Mo maximum · Facultatif'
              : 'Facultatif · Retirez toute donnée personnelle inutile.',
          buttonLabel: 'Joindre une capture',
          fileName: _attachment,
          onAdd: () => setState(() => _attachment = 'capture.png · 246 Ko'),
          onRemove: () => setState(() => _attachment = null),
        ),
        if (_isProblem) ...[
          LabeledField(label: 'E-mail de réponse', controller: _email, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: AppDimens.xs),
          const InfoBanner(
            title: 'Protégez vos informations',
            body: 'Masquez les coordonnées, messages privés et informations de paiement sur votre capture.',
          ),
          const SizedBox(height: AppDimens.md),
          Text('Informations techniques jointes : SPORA 1.0 · Android. Aucune donnée bancaire n’est collectée.',
              style: AppTextStyles.caption(color: p.text3)),
        ] else
          Text('N’incluez ni mot de passe ni information de paiement.',
              style: AppTextStyles.caption(color: p.text3)),
      ],
    );
  }

  Widget _confirmation(BuildContext context) {
    final p = AccountPalette.of(context);
    return PopScope(
      canPop: true,
      child: AccountScaffold(
        title: 'Signalement reçu',
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: StatusPill(label: 'Confirmation', color: AppColors.primary, background: p.tint),
          ),
          const SizedBox(height: AppDimens.xxl),
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.6, end: 1),
              duration: const Duration(milliseconds: 320),
              curve: const Cubic(0.3, 0, 0, 1.2),
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Icon(LucideIcons.check, color: AppColors.primary, size: 32),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.section),
          Text('Merci pour votre vigilance.',
              textAlign: TextAlign.center, style: AppTextStyles.h1(color: p.text)),
          const SizedBox(height: AppDimens.md),
          Text('Votre signalement $_ticket a été transmis à l’équipe SPORA.',
              textAlign: TextAlign.center, style: AppTextStyles.body(color: p.text)),
          const SizedBox(height: AppDimens.xxl),
          AccountCard(
            padding: const EdgeInsets.all(AppDimens.section),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Et maintenant ?', style: AppTextStyles.h3(color: p.text)),
                const SizedBox(height: AppDimens.lg),
                Text(
                    _isProblem
                        ? 'Notre équipe analyse votre signalement. Nous vous répondrons à ${_email.text} si nous avons besoin de précisions.'
                        : 'Nous examinerons le contexte signalé. Votre identité n’est pas communiquée à la personne signalée.',
                    style: AppTextStyles.body(color: p.text)),
                const SizedBox(height: AppDimens.lg),
                Text('En cas de danger immédiat, contactez les services d’urgence compétents.',
                    style: AppTextStyles.body(color: p.text)),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.xl),
          GradientButton(label: 'Terminer', onPressed: () => accountBack(context, fallback: '/settings')),
        ],
      ),
    );
  }
}
