import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'highlights_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum HighlightUploadState { source, trim, details, uploading, paused, wifi, resuming, processing, failed, validation }

class PublishHighlightScreen extends StatefulWidget {
  const PublishHighlightScreen({super.key});
  @override
  State<PublishHighlightScreen> createState() => _PublishHighlightScreenState();
}

class _PublishHighlightScreenState extends State<PublishHighlightScreen> {
  HighlightUploadState _state = HighlightUploadState.source;
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController(text: 'Finition en une touche');
  String? _tag;
  bool _rights = true;
  bool _wifiOnly = true;
  bool _private = false;
  RangeValues _range = const RangeValues(0, 42);
  double _progress = .62;
  Timer? _timer;
  static const _labels = ['Source de la vidéo', 'Découper la vidéo', 'Publier un highlight', 'Envoi — 62 %', 'Envoi en pause', 'En attente du Wi-Fi', 'Reprise de l’envoi', 'En traitement', 'Échec de l’envoi', 'Vidéo en validation'];

  @override
  void dispose() { _timer?.cancel(); _title.dispose(); super.dispose(); }

  void _change(HighlightUploadState value) { _timer?.cancel(); setState(() => _state = value); }

  void _upload({bool resume = false}) {
    _timer?.cancel();
    setState(() { _state = resume ? HighlightUploadState.resuming : HighlightUploadState.uploading; if (resume && _progress < .68) _progress = .68; });
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        _progress = (_progress + .06).clamp(0.0, 1.0).toDouble();
        if (_progress >= 1) {
          timer.cancel();
          _state = HighlightUploadState.processing;
          _timer = Timer(const Duration(seconds: 5), () {
            if (mounted) setState(() => _state = HighlightUploadState.validation);
          });
        }
      });
    });
  }

  Future<void> _source() async {
    final chosen = await showModalBottomSheet<String>(context: context, showDragHandle: true, builder: (sheet) => Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Source de la vidéo', style: AppTextStyles.h2()),
      const SizedBox(height: 12),
      Text('Choisissez une vidéo de 60 secondes maximum et de moins de 200 Mo.', style: AppTextStyles.body()),
      ListTile(leading: const Icon(LucideIcons.video, color: AppColors.primary), title: Text('Caméra', style: AppTextStyles.h3()), subtitle: Text('Autorisez l’accès à la caméra et au microphone pour filmer votre action.', style: AppTextStyles.caption()), onTap: () => Navigator.pop(sheet, 'Caméra')),
      ListTile(leading: const Icon(LucideIcons.galleryHorizontal, color: AppColors.primary), title: Text('Galerie', style: AppTextStyles.h3()), subtitle: Text('Autorisez l’accès aux vidéos sélectionnées de votre galerie.', style: AppTextStyles.caption()), onTap: () => Navigator.pop(sheet, 'Galerie')),
      Text('Simulation : aucun accès à vos fichiers n’est nécessaire.', style: AppTextStyles.micro()),
    ])));
    if (chosen != null && mounted) _change(HighlightUploadState.trim);
  }

  Widget _button(String label, VoidCallback action, {bool secondary = false}) => Padding(padding: const EdgeInsets.only(top: 12), child: SizedBox(width: double.infinity, height: 48, child: secondary ? OutlinedButton(onPressed: action, child: Text(label, style: AppTextStyles.button(color: AppColors.textPrimary))) : DecoratedBox(decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.primaryGradient), borderRadius: BorderRadius.circular(999)), child: FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.surface.withValues(alpha: 0)), onPressed: action, child: Text(label, style: AppTextStyles.button())))));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.appBg,
    body: SafeArea(child: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(AppDimens.screenMargin, AppDimens.sm, AppDimens.screenMargin, AppDimens.md),
        child: Row(children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: AppDimens.minTouch,
              height: AppDimens.minTouch,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.radiusInput),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(LucideIcons.arrowLeft, size: 22, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(child: Text(_labels[_state.index], style: AppTextStyles.h2(), maxLines: 1, overflow: TextOverflow.ellipsis)),
          PopupMenuButton<HighlightUploadState>(
            tooltip: 'Simuler un état',
            onSelected: _change,
            itemBuilder: (_) => [for (final value in HighlightUploadState.values) PopupMenuItem(value: value, child: Text(_labels[value.index], style: AppTextStyles.caption()))],
            child: Container(
              width: AppDimens.minTouch,
              height: AppDimens.minTouch,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.radiusInput),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(LucideIcons.moreVertical, size: 22, color: AppColors.textPrimary),
            ),
          ),
        ]),
      ),
      Expanded(child: ListView(padding: const EdgeInsets.all(AppDimens.screenMargin), children: [
      Row(children: [for (var i = 0; i < 3; i++) Expanded(child: Container(margin: const EdgeInsets.only(right: 6), height: 4, decoration: BoxDecoration(color: i <= (_state.index < 2 ? _state.index : 2) ? AppColors.primary : AppColors.border, borderRadius: BorderRadius.circular(999))))]),
      const SizedBox(height: 24),
      if (_state == HighlightUploadState.source) ...[
        ClipRRect(borderRadius: BorderRadius.circular(16), child: const HighlightPoster(height: 220, child: Icon(LucideIcons.video, size: 56, color: AppColors.surface))),
        const SizedBox(height: 24), Text('Montrez votre talent', style: AppTextStyles.h1()), const SizedBox(height: 8), Text('Votre prochaine opportunité commence par une action. Importez votre meilleur moment.', style: AppTextStyles.body()),
        _button('Choisir une vidéo', _source),
        const SizedBox(height: 16), Text('60 secondes maximum · 200 Mo maximum', style: AppTextStyles.caption()),
      ] else if (_state == HighlightUploadState.trim) ...[
        ClipRRect(borderRadius: BorderRadius.circular(16), child: const HighlightPoster(height: 300, child: Icon(LucideIcons.playCircle, color: AppColors.surface, size: 56))),
        const SizedBox(height: 24), Text('Gardez le meilleur de votre action', style: AppTextStyles.h2()), const SizedBox(height: 8), Text('Déplacez les poignées pour sélectionner votre extrait.', style: AppTextStyles.body()),
        const SizedBox(height: 16), SizedBox(height: 64, child: Row(children: [for (var i = 0; i < 7; i++) Expanded(child: Container(margin: const EdgeInsets.all(1), color: i.isEven ? AppColors.navy700 : AppColors.clubGreen, child: const Center(child: Icon(LucideIcons.footprints, color: AppColors.darkTextMuted))))])),
        RangeSlider(values: _range, max: 60, divisions: 60, labels: RangeLabels('${_range.start.round()} s', '${_range.end.round()} s'), onChanged: (value) => setState(() => _range = value)),
        Text('${_range.start.round()} s → ${_range.end.round()} s · Durée : ${(_range.end - _range.start).round()} s / 60 s max.', style: AppTextStyles.caption()),
        Text('Source 84 Mo · Après compression 32 Mo', style: AppTextStyles.caption()),
        _button('Utiliser cet extrait', () { if (_range.end > _range.start) _change(HighlightUploadState.details); }), _button('Changer la vidéo', _source, secondary: true),
      ] else if (_state == HighlightUploadState.details) _details() else _transfer(),
      ])),
    ])),
  );

  Widget _details() => Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)), child: Row(children: [ClipRRect(borderRadius: BorderRadius.circular(12), child: const SizedBox(width: 108, child: HighlightPoster(height: 90, child: Icon(LucideIcons.play, color: AppColors.surface)))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Mon action décisive', style: AppTextStyles.h3()), Text('00:${(_range.end - _range.start).round()} / 01:00 max.', style: AppTextStyles.caption()), TextButton(onPressed: _source, child: const Text('Changer la vidéo'))]))])),
    const SizedBox(height: 20), Text('Titre *', style: AppTextStyles.bodyStrong()), const SizedBox(height: 8), TextFormField(controller: _title, maxLength: 100, style: AppTextStyles.body(), decoration: const InputDecoration(filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))), validator: (value) => value == null || value.trim().isEmpty ? 'Ajoutez un titre' : null),
    const SizedBox(height: 12), Text('Type d’action *', style: AppTextStyles.bodyStrong()),
    FormField<String>(validator: (_) => _tag == null ? 'Sélectionnez un type d’action' : null, builder: (field) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Wrap(spacing: 8, children: [for (final tag in highlightTags) ChoiceChip(shape: const StadiumBorder(), label: Text(tag, style: AppTextStyles.caption(color: _tag == tag ? AppColors.primary : AppColors.textSecondary)), selected: _tag == tag, onSelected: (_) => setState(() { _tag = tag; field.didChange(tag); }))]), if (field.hasError) Text(field.errorText!, style: AppTextStyles.caption(color: AppColors.errorText))])),
    const SizedBox(height: 16), Text('Description', style: AppTextStyles.bodyStrong()), const SizedBox(height: 8), TextFormField(maxLines: 3, style: AppTextStyles.body(), decoration: const InputDecoration(hintText: 'Décrivez votre action…', filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))))),
    const SizedBox(height: 16), Text('Qui peut voir cette vidéo ?', style: AppTextStyles.h3()),
    ListTile(contentPadding: EdgeInsets.zero, leading: Icon(_private ? LucideIcons.circle : LucideIcons.circleDot, color: AppColors.primary), title: Text('Public', style: AppTextStyles.body()), onTap: () => setState(() => _private = false)),
    ListTile(contentPadding: EdgeInsets.zero, leading: Icon(_private ? LucideIcons.circleDot : LucideIcons.circle, color: AppColors.primary), title: Text('Agents et clubs uniquement', style: AppTextStyles.body()), onTap: () => setState(() => _private = true)),
    SwitchListTile(contentPadding: EdgeInsets.zero, title: Text('Envoyer uniquement en Wi-Fi', style: AppTextStyles.body()), value: _wifiOnly, onChanged: (value) => setState(() => _wifiOnly = value)),
    CheckboxListTile(contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading, title: Text('Je détiens les droits de cette vidéo et l’autorisation des personnes identifiables.', style: AppTextStyles.caption()), value: _rights, onChanged: (value) => setState(() => _rights = value ?? false)),
    Text('Votre highlight sera vérifié par la modération avant sa mise en ligne.', style: AppTextStyles.caption()),
    _button('Publier', () { if (_form.currentState!.validate() && _rights) { _progress = .62; _upload(); } else if (!_rights) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Confirmez que vous détenez les droits de la vidéo.'))); } }),
  ]));

  Widget _transfer() {
    final done = _state == HighlightUploadState.validation;
    final processing = _state == HighlightUploadState.processing;
    final paused = _state == HighlightUploadState.paused;
    final failed = _state == HighlightUploadState.failed;
    final wifi = _state == HighlightUploadState.wifi;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipRRect(borderRadius: BorderRadius.circular(16), child: const HighlightPoster(height: 200)),
      const SizedBox(height: 20), Text(_title.text, style: AppTextStyles.h1()),
      const SizedBox(height: 12), Chip(shape: const StadiumBorder(), backgroundColor: done || processing ? AppColors.green.withValues(alpha: .1) : AppColors.primaryTint, label: Text(_labels[_state.index], style: AppTextStyles.caption(color: done || processing ? AppColors.clubGreen : AppColors.primary))),
      const SizedBox(height: 12), Text('42 secondes · Source 84 Mo · Après compression 32 Mo', style: AppTextStyles.caption()),
      const SizedBox(height: 20), Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(done ? 'Votre vidéo est en validation' : processing ? 'Votre vidéo est bien arrivée' : failed ? 'L’envoi a échoué' : wifi ? 'En attente d’une connexion Wi-Fi' : 'Transfert sécurisé', style: AppTextStyles.h2()),
        const SizedBox(height: 24), Text(done ? 'En validation' : processing ? 'Envoyée' : '${(_progress * 100).round()} %', style: AppTextStyles.display()),
        const SizedBox(height: 20), LinearProgressIndicator(value: done || processing ? 1 : _progress, minHeight: 7, borderRadius: BorderRadius.circular(999), backgroundColor: AppColors.border),
        const SizedBox(height: 16), Text(done ? 'Notre équipe vérifie votre highlight. Vous serez notifié dès sa publication.' : processing ? 'Création du poster et des qualités de lecture. La vidéo passera ensuite en validation avant publication.' : wifi ? 'L’envoi reprendra automatiquement dès que le Wi-Fi sera disponible.' : failed ? 'Une erreur est survenue. Vos données sont conservées : réessayez sans recommencer.' : paused ? '19,8 Mo sur 32 Mo envoyés. Vous pouvez reprendre sans recommencer depuis zéro.' : _state == HighlightUploadState.resuming ? 'La connexion est rétablie. Le transfert reprend à partir de la dernière partie reçue.' : 'Envoi de votre vidéo en cours. Vous pouvez mettre le transfert en pause.', style: AppTextStyles.body()),
        if (done) _button('Voir mes highlights', () => context.push('/highlights/mine'))
        else if (processing) ...[_button('Voir mes highlights', () => context.push('/highlights/mine')), _button('Simuler la validation', () => _change(HighlightUploadState.validation), secondary: true)]
        else ...[
          _button(failed ? 'Réessayer' : paused ? 'Reprendre l’envoi' : wifi ? 'Utiliser les données mobiles' : 'Mettre en pause', () { if (failed || paused || wifi) { _upload(resume: true); } else { _change(HighlightUploadState.paused); } }),
          if (!wifi) _button('Attendre le Wi-Fi', () => _change(HighlightUploadState.wifi), secondary: true),
          if (wifi) _button('Simuler le retour du Wi-Fi', () => _upload(resume: true), secondary: true),
          _button('Annuler l’envoi', () async { final cancel = await showDialog<bool>(context: context, builder: (dialog) => AlertDialog(title: Text('Annuler l’envoi ?', style: AppTextStyles.h2()), content: const Text('Votre vidéo ne sera pas publiée.'), actions: [TextButton(onPressed: () => Navigator.pop(dialog, false), child: const Text('Continuer')), TextButton(onPressed: () => Navigator.pop(dialog, true), child: const Text('Annuler l’envoi'))])); if (cancel == true && mounted) _change(HighlightUploadState.details); }, secondary: true),
        ],
      ])),
      const SizedBox(height: 16), Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.primaryTint, borderRadius: BorderRadius.circular(16)), child: Text(done || processing ? 'Visible uniquement par vous\nEnvoyée → En traitement → En validation → En ligne. Chaque vidéo est revue avant publication.' : 'Vos données restent protégées\nSource limitée à 60 secondes et 200 Mo avant compression. Une interruption ne supprime pas les parties déjà envoyées.', style: AppTextStyles.body(color: AppColors.primary))),
    ]);
  }
}
