import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../onboarding_draft.dart';
import '../onboarding_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum _UploadState { empty, uploading, done }

enum _VideoSource { gallery, camera }

const int _kMaxVideoBytes = 200 * 1024 * 1024;
const double _kStep = 0.012; // progress per tick
const Duration _kTick = Duration(milliseconds: 100);

/// Étape 3 — Vos highlights (optional presentation video).
class Step3Highlights extends StatefulWidget {
  const Step3Highlights({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.onBack,
    required this.onContinue,
  });

  final PlayerDraft draft;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  State<Step3Highlights> createState() => _Step3HighlightsState();
}

class _Step3HighlightsState extends State<Step3Highlights> {
  late _UploadState _state = widget.draft.videoAdded ? _UploadState.done : _UploadState.empty;
  double _progress = 0;
  bool _paused = false;
  Timer? _timer;
  String _fileName = '';
  int _bytes = 0;
  String? _duration;

  PlayerDraft get d => widget.draft;

  @override
  void initState() {
    super.initState();
    _fileName = d.videoName ?? '';
    _bytes = d.videoBytes;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _slug {
    final s = d.firstName.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    return s.isEmpty ? 'joueur' : s;
  }

  String get _title => d.fullName.isEmpty ? 'Ma présentation' : 'Présentation de ${d.fullName}';

  String get _meta => [_fileName, if (_duration != null) _duration!, formatMo(_bytes)].join(' · ');

  Future<void> _choose() async {
    final src = await showOnbChoiceSheet<_VideoSource>(
      context,
      title: 'Ajouter une vidéo',
      choices: const [
        OnbChoice(_VideoSource.gallery, 'Choisir dans la galerie', icon: LucideIcons.film),
        OnbChoice(_VideoSource.camera, 'Filmer avec la caméra', icon: LucideIcons.video),
      ],
    );
    if (src == null || !mounted) return;

    XFile? file;
    var simulated = false;
    try {
      file = await ImagePicker().pickVideo(
        source: src == _VideoSource.camera ? ImageSource.camera : ImageSource.gallery,
        maxDuration: const Duration(seconds: 60),
      );
    } catch (_) {
      simulated = true; // Picker unavailable on this platform → demo video.
    }
    if (!mounted) return;

    if (file != null) {
      final name = file.name.isEmpty ? 'presentation-$_slug.mp4' : file.name;
      final lower = name.toLowerCase();
      if (!(lower.endsWith('.mp4') || lower.endsWith('.mov'))) {
        showOnbSnack(context, 'Format non pris en charge. Utilisez une vidéo MP4 ou MOV.', error: true);
        return;
      }
      int size;
      try {
        size = await file.length();
      } catch (_) {
        size = 0;
      }
      if (!mounted) return;
      if (size > _kMaxVideoBytes) {
        showOnbSnack(context, 'Vidéo trop lourde : 200 Mo maximum.', error: true);
        return;
      }
      _start(name, size, null);
    } else if (simulated) {
      showOnbSnack(context, 'Sélection indisponible ici : une vidéo de démonstration est utilisée.');
      _start('presentation-$_slug.mp4', 38 * 1024 * 1024, '00:42');
    }
  }

  void _start(String name, int bytes, String? duration) {
    _timer?.cancel();
    setState(() {
      _state = _UploadState.uploading;
      _progress = 0;
      _paused = false;
      _fileName = name;
      _bytes = bytes;
      _duration = duration;
      d.videoAdded = false;
    });
    widget.onChanged();
    _timer = Timer.periodic(_kTick, (_) => _tick());
  }

  void _tick() {
    if (_paused || !mounted) return;
    setState(() => _progress = (_progress + _kStep).clamp(0.0, 1.0).toDouble());
    if (_progress >= 1) {
      _timer?.cancel();
      setState(() {
        _state = _UploadState.done;
        d
          ..videoAdded = true
          ..videoSkipped = false
          ..videoName = _fileName
          ..videoBytes = _bytes
          ..thumbnail = 0;
      });
      widget.onChanged();
    }
  }

  void _cancel() {
    _timer?.cancel();
    setState(() {
      _state = _UploadState.empty;
      _progress = 0;
    });
    showOnbSnack(context, 'Envoi annulé.');
  }

  void _skip() {
    _timer?.cancel();
    d.videoSkipped = !d.videoAdded;
    widget.onChanged();
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final uploading = _state == _UploadState.uploading;
    return OnbScaffold(
      title: 'Vos highlights',
      boxedBack: _state != _UploadState.empty,
      onBack: () {
        _timer?.cancel();
        widget.onBack();
      },
      eyebrow: 'Étape 3 sur 3',
      progress: 1,
      bottom: OnbPrimaryButton(
        label: uploading ? 'Envoi en cours…' : 'Continuer',
        onPressed: uploading ? null : _skip,
      ),
      children: [
        Semantics(header: true, child: Text('Vos highlights', style: AppTextStyles.h1())),
        const SizedBox(height: 8),
        Text('Ajoutez votre vidéo de présentation',
            style: AppTextStyles.bodyLarge(color: AppColors.textSecondary)),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: KeyedSubtree(
            key: ValueKey(_state),
            child: switch (_state) {
              _UploadState.empty => _emptyCard(),
              _UploadState.uploading => _uploadingCard(),
              _UploadState.done => _doneCard(),
            },
          ),
        ),
        const SizedBox(height: 16),
        if (_state == _UploadState.empty)
          _tipsCard()
        else ...[
          Text('MP4 · MOV · 60 s maximum · 200 Mo maximum', style: AppTextStyles.caption()),
          const SizedBox(height: 16),
          OnbCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Visez 30 secondes', style: AppTextStyles.h3()),
                const SizedBox(height: 12),
                Text(
                  'Durée recommandée, et non une limite.\nMontrez votre meilleur geste en premier.',
                  style: AppTextStyles.bodyLarge(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        OnbToggleRow(
          label: 'Envoi en Wi-Fi uniquement',
          value: d.wifiOnly,
          onChanged: (v) {
            setState(() => d.wifiOnly = v);
            widget.onChanged();
          },
        ),
        const SizedBox(height: 16),
        Text(
          switch (_state) {
            _UploadState.empty => 'Toutes les vidéos passent en modération avant leur mise en ligne.',
            _UploadState.uploading => 'Vous pouvez quitter cet écran, l’envoi continue.',
            _UploadState.done =>
              'E-mail vérifié requis pour publier. Toutes les vidéos passent en modération.',
          },
          style: AppTextStyles.caption(),
        ),
        if (_state == _UploadState.empty) ...[
          const SizedBox(height: 16),
          OnbTextButton(label: 'Je le ferai plus tard', filled: true, onPressed: _skip),
        ],
      ],
    );
  }

  Widget _emptyCard() {
    return OnbCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.upload, size: 48, color: AppColors.primary),
          const SizedBox(height: 16),
          Text('Ajoutez votre vidéo de présentation', style: AppTextStyles.h3()),
          const SizedBox(height: 12),
          Text('MP4 · MOV · 60 s maximum · 200 Mo source', style: AppTextStyles.caption()),
          const SizedBox(height: 16),
          OnbSecondaryButton(label: 'Choisir une vidéo', onPressed: _choose),
        ],
      ),
    );
  }

  Widget _uploadingCard() {
    final pct = (_progress * 100).round();
    final sent = _bytes * _progress;
    final remaining = ((1 - _progress) / _kStep * _kTick.inMilliseconds / 1000).ceil();
    return OnbCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnbVideoThumb(seed: 0),
          const SizedBox(height: 16),
          OnbStatusChip(label: _paused ? 'Envoi en pause' : 'Envoi en cours'),
          const SizedBox(height: 12),
          Text(_title, style: AppTextStyles.h3()),
          const SizedBox(height: 8),
          Text(_meta, style: AppTextStyles.body(color: AppColors.textMuted)),
          const SizedBox(height: 16),
          Semantics(
            liveRegion: true,
            child: Text('$pct %', style: AppTextStyles.h3(color: AppColors.primary)),
          ),
          const SizedBox(height: 10),
          OnbProgressBar(value: _progress, height: 8),
          const SizedBox(height: 10),
          Text(
            '${formatMo(sent)} sur ${formatMo(_bytes)} · Temps restant estimé : ${_paused ? '—' : '$remaining s'}',
            style: AppTextStyles.body(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OnbSecondaryButton(
                  label: _paused ? 'Reprendre' : 'Pause',
                  onPressed: () => setState(() => _paused = !_paused),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: OnbTextButton(label: 'Annuler', onPressed: _cancel)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _doneCard() {
    return OnbCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnbVideoThumb(seed: d.thumbnail),
          const SizedBox(height: 16),
          const OnbStatusChip(label: 'Vidéo ajoutée', tone: OnbTone.success),
          const SizedBox(height: 12),
          Text(_title, style: AppTextStyles.h3()),
          const SizedBox(height: 8),
          Text(_meta, style: AppTextStyles.body(color: AppColors.textMuted)),
          const SizedBox(height: 16),
          const OnbBanner(
            tone: OnbTone.success,
            title: 'Vidéo reçue',
            message: 'Elle sera vérifiée avant sa mise en ligne.',
            boldMessage: false,
          ),
          const SizedBox(height: 16),
          Text('Choisissez une miniature', style: AppTextStyles.h3()),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: d.thumbnail == i,
                    label: 'Miniature ${i + 1}',
                    excludeSemantics: true,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => d.thumbnail = i);
                        widget.onChanged();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: d.thumbnail == i ? AppColors.primary : AppColors.surface,
                            width: 2,
                          ),
                        ),
                        child: OnbVideoThumb(seed: i, radius: 8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          OnbSecondaryButton(label: 'Remplacer la vidéo', onPressed: _choose),
        ],
      ),
    );
  }

  Widget _tipsCard() {
    return const OnbCard(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          OnbInfoRow(
            icon: LucideIcons.timer,
            title: 'Visez 30 secondes',
            subtitle: 'Durée recommandée pour votre présentation ; limite technique de 60 secondes.',
          ),
          OnbInfoRow(icon: LucideIcons.sparkles, title: 'Votre meilleur geste en premier'),
          OnbInfoRow(icon: LucideIcons.sun, title: 'Filmez en paysage, bonne lumière'),
        ],
      ),
    );
  }
}
