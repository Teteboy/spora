import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'profile_mock_data.dart';
import 'profile_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Private shortlist — /my-list
/// Frames « Ma liste — Joueurs et notes » + « Ma liste — Vide » and the
/// « Ma note privée » bottom sheet.
class MyListScreen extends StatefulWidget {
  const MyListScreen({super.key});

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
  int _tab = 0; // 0 Joueurs · 1 Notes
  late List<ShortlistEntry> _items = ProfileMockData.shortlist();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: ListView(
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimens.screenMargin),
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/profile');
                    }
                  },
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
                Expanded(
                  child: Text('Ma liste',
                      style: AppTextStyles.h1(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(children: [
              PillChip(
                  label: 'Joueurs',
                  selected: _tab == 0,
                  onTap: () => setState(() => _tab = 0)),
              const SizedBox(width: 8),
              PillChip(
                  label: 'Notes',
                  selected: _tab == 1,
                  onTap: () => setState(() => _tab = 1)),
            ]),
            const SizedBox(height: 20),
            Text(
              _items.isEmpty
                  ? '0 joueur enregistré'
                  : '${_items.length} joueurs enregistrés',
              style: AppTextStyles.h1(),
            ),
            const SizedBox(height: 20),
            if (_items.isEmpty) _emptyState() else ..._buildList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _items.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlineButton(
                        label: 'Comparer les sélections', onTap: () {}),
                    const SizedBox(height: 8),
                    Text('Sélectionner · Retirer de la liste · Ajouter une note',
                        style: AppTextStyles.caption()),
                  ],
                ),
              ),
            ),
    );
  }

  List<Widget> _buildList() {
    final showNotesOnly = _tab == 1;
    final widgets = <Widget>[
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryTint,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        ),
        child: Text('Ajouté à votre liste\n${_items.first.name} · Annuler',
            style: AppTextStyles.bodyStrong(color: AppColors.primary)),
      ),
      const SizedBox(height: 12),
    ];
    for (var i = 0; i < _items.length; i++) {
      final e = _items[i];
      if (!showNotesOnly) {
        widgets.add(_playerCard(e, i));
        widgets.add(const SizedBox(height: 8));
      }
      if (e.note != null) {
        widgets.add(GestureDetector(
          onTap: () => _editNote(i),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(AppDimens.radiusCard),
            ),
            child: Text('Note privée\n${e.note}',
                style: AppTextStyles.bodyStrong(color: AppColors.primary)),
          ),
        ));
        widgets.add(const SizedBox(height: 8));
      } else if (showNotesOnly) {
        widgets.add(_playerCard(e, i));
        widgets.add(const SizedBox(height: 8));
      }
    }
    return widgets;
  }

  Widget _playerCard(ShortlistEntry e, int index) {
    return ProfileCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.muted,
            backgroundImage:
                e.avatarUrl != null ? NetworkImage(e.avatarUrl!) : null,
            child: e.avatarUrl == null
                ? const Icon(LucideIcons.user,
                    color: AppColors.textMuted)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.name, style: AppTextStyles.bodyStrong()),
                Text(e.line1, style: AppTextStyles.caption()),
                if (e.line2 != null)
                  Text(e.line2!, style: AppTextStyles.caption()),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.badgeCheck,
                color: AppColors.primary),
            onPressed: () => context.push('/player/jordan_mbala'),
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2,
                color: AppColors.textMuted),
            onPressed: () => setState(() => _items.removeAt(index)),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 140,
          height: 140,
          decoration: const BoxDecoration(
              color: AppColors.primaryTint, shape: BoxShape.circle),
          child: const Icon(LucideIcons.bookmark,
              size: 56, color: AppColors.primary),
        ),
        const SizedBox(height: 24),
        Text('Votre liste vous attend',
            style: AppTextStyles.h1(), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(
            'Enregistrez les profils qui retiennent votre attention pour les retrouver et ajouter vos notes privées.',
            style: AppTextStyles.body(),
            textAlign: TextAlign.center),
        const SizedBox(height: 24),
        PrimaryButton(
            label: 'Découvrir les talents',
            onTap: () => context.go('/discover')),
        const SizedBox(height: 24),
        Text('Vos sélections et vos notes restent privées.',
            style: AppTextStyles.caption()),
      ],
    );
  }

  /// « Ma note privée » bottom sheet.
  Future<void> _editNote(int index) async {
    final e = _items[index];
    final controller = TextEditingController(text: e.note ?? '');
    final saved = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.appBg,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppDimens.radiusSheet)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                  child: Text('Ma note privée', style: AppTextStyles.h1())),
              IconButton(
                  icon: const Icon(LucideIcons.moreHorizontal), onPressed: () {}),
            ]),
            Text('En revue · Maquette statique · Données fictives',
                style: AppTextStyles.caption()),
            const SizedBox(height: 12),
            ProfileCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.name, style: AppTextStyles.h2()),
                  const SizedBox(height: 4),
                  Text(e.line1, style: AppTextStyles.body()),
                  const SizedBox(height: 10),
                  const BadgePill(
                      label: 'Dans ma liste',
                      bg: Color(0xFFDFF3EA),
                      fg: AppColors.clubGreen),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Note privée', style: AppTextStyles.bodyStrong()),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusInput),
                  borderSide:
                      const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusInput),
                  borderSide:
                      const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (_, v, __) => Text(
                  '${v.text.length} / 500 caractères · Visible uniquement par vous.',
                  style: AppTextStyles.caption()),
            ),
            const SizedBox(height: 12),
            const InfoBanner(
              icon: LucideIcons.info,
              title: 'Votre note n’est pas partagée',
              body:
                  'Ni le joueur ni les autres recruteurs ne peuvent consulter cette note.',
            ),
            const SizedBox(height: 16),
            PrimaryButton(
                label: 'Enregistrer la note',
                onTap: () => Navigator.of(ctx).pop(controller.text)),
            const SizedBox(height: 8),
            OutlineButton(
                label: 'Annuler les modifications',
                onTap: () => Navigator.of(ctx).pop()),
          ],
        ),
      ),
    );
    if (saved != null && saved.trim().isNotEmpty) {
      setState(() => _items[index] = e.copyWith(note: saved.trim()));
    }
  }
}
