import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import 'account_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// "/edit-profile" — frames "Modifier le profil" + "Modifications non
/// enregistrées" (dialog on back when there are unsaved changes).
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final UserType _role;
  final Map<String, TextEditingController> _c = {};
  final Map<String, String> _initialText = {};

  // Choice state (player)
  String _position = 'ATT';
  String _foot = 'Droit';
  bool _available = true;
  // Agent
  String _agentStatus = 'Indépendant';
  // Club
  final Set<String> _categories = {'U21'};

  late final Map<String, Object> _initialChoices;

  bool _dirty = false;
  bool _saving = false;
  bool _saved = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final auth = context.read<AuthProvider>();
    _role = auth.selectedUserType == UserType.guest ? UserType.player : auth.selectedUserType;
    final email = auth.currentUser?.email;
    final name = auth.currentUser?.name.split(' - ').first;

    final Map<String, String> values;
    switch (_role) {
      case UserType.agent:
        values = {
          'name': name ?? 'Nadia Mensah',
          'agency': 'Horizon Talent',
          'country': 'Côte d’Ivoire',
          'city': 'Abidjan',
          'email': email ?? 'nadia.mensah@horizon.com',
          'phone': '+225 07 00 00 00',
          'experience': '8',
          'licence': '',
          'zones': 'Afrique de l’Ouest, France',
          'bio': 'J’accompagne les jeunes talents vers des projets durables.',
        };
        break;
      case UserType.recruiter:
        values = {
          'club': 'Académie des Rives',
          'city': 'Douala',
          'country': 'Cameroun',
          'contact': name ?? 'Éric N.',
          'contactRole': 'Responsable recrutement',
          'email': email ?? 'recrutement@rives.cm',
          'phone': '+237 6 00 00 00 00',
          'website': 'www.academiedesrives.cm',
          'bio': 'Centre de formation reconnu, accompagnement scolaire et sportif.',
        };
        break;
      default:
        values = {
          'name': name ?? 'Jordan Mbala',
          'birth': '12 juin 2007',
          'nationality': 'France',
          'city': 'Paris',
          'email': email ?? 'jordan.mbala@email.com',
          'secondary': 'Ailier droit',
          'height': '182',
          'weight': '74',
          'club': 'Paris FC U21',
          'level': 'U21 · 4 ans',
          'goal': 'Rejoindre un projet ambitieux et franchir un cap au niveau professionnel.',
        };
    }
    values.forEach((k, v) {
      final ctl = TextEditingController(text: v);
      ctl.addListener(_recomputeDirty);
      _c[k] = ctl;
      _initialText[k] = v;
    });
    _initialChoices = _choicesSnapshot();
  }

  Map<String, Object> _choicesSnapshot() => {
        'position': _position,
        'foot': _foot,
        'available': _available,
        'agentStatus': _agentStatus,
        'categories': (_categories.toList()..sort()).join(','),
      };

  void _recomputeDirty() {
    final textChanged = _c.entries.any((e) => e.value.text != _initialText[e.key]);
    final snap = _choicesSnapshot();
    final choiceChanged = snap.entries.any((e) => _initialChoices[e.key] != e.value);
    final d = textChanged || choiceChanged;
    setState(() {
      _dirty = d;
      if (d) _saved = false;
    });
  }

  void _setChoice(VoidCallback fn) {
    setState(fn);
    _recomputeDirty();
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final nameKey = _role == UserType.recruiter ? 'club' : 'name';
    if (_c[nameKey]!.text.trim().isEmpty) {
      showAccountSnack(context, 'Le nom est obligatoire.');
      return;
    }
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    _c.forEach((k, v) => _initialText[k] = v.text);
    _initialChoices
      ..clear()
      ..addAll(_choicesSnapshot());
    setState(() {
      _saving = false;
      _dirty = false;
      _saved = true;
    });
  }

  Future<void> _handleBack() async {
    if (!_dirty) {
      accountBack(context);
      return;
    }
    final leave = await showAccountDialog<bool>(
      context: context,
      title: 'Modifications non enregistrées',
      message:
          'Vous avez modifié votre profil. Enregistrez vos changements ou quittez sans les conserver.',
      primaryLabel: 'Continuer la modification',
      secondaryLabel: 'Quitter sans enregistrer',
      primaryValue: false,
      secondaryValue: true,
    );
    if (leave == true && mounted) {
      setState(() => _dirty = false);
      accountBack(context);
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2007, 6, 12),
      firstDate: DateTime(now.year - 45),
      lastDate: DateTime(now.year - 8),
      helpText: 'Date de naissance',
    );
    if (picked == null) return;
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    _c['birth']!.text = '${picked.day} ${months[picked.month - 1]} ${picked.year}';
  }

  String get _roleLabel => switch (_role) {
        UserType.agent => 'Agent',
        UserType.recruiter => 'Club',
        _ => 'Joueur',
      };

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    final auth = context.watch<AuthProvider>();
    final displayName = _role == UserType.recruiter ? _c['club']!.text : _c['name']!.text;

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: AccountScaffold(
        title: 'Modifier le profil',
        onBack: _handleBack,
        bottom: GradientButton(
          label: 'Enregistrer',
          loading: _saving,
          onPressed: _dirty ? _save : null,
        ),
        children: [
          Row(
            children: [
              _role == UserType.player
                  ? CircleAvatar(
                      radius: 42,
                      backgroundColor: p.muted,
                      backgroundImage:
                          NetworkImage(auth.currentUser?.avatarUrl ?? 'https://i.pravatar.cc/200?u=jordan'),
                    )
                  : Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: _role == UserType.agent ? AppColors.navy800 : AppColors.clubGreen,
                        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                      ),
                      child: Icon(
                        _role == UserType.agent ? LucideIcons.briefcase : LucideIcons.shield,
                        color: AppColors.textLight,
                        size: 32,
                      ),
                    ),
              const SizedBox(width: AppDimens.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName.isEmpty ? '—' : displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.h2(color: p.text)),
                    const SizedBox(height: AppDimens.sm),
                    SecondaryButton(
                      label: _role == UserType.player ? 'Changer la photo' : 'Changer le logo',
                      height: 44,
                      onPressed: () => showAccountSnack(context, 'Sélection d’image (démo)'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          InfoBanner(
            title: 'Vos informations restent modifiables',
            body: 'Le rôle $_roleLabel, choisi à l’inscription, ne peut pas être changé.',
            boldBody: true,
          ),
          ..._fieldsForRole(),
          if (_saved) ...[
            const SizedBox(height: AppDimens.lg),
            InfoBanner(
              icon: LucideIcons.checkCircle,
              title: 'Profil enregistré',
              body: 'Vos modifications sont visibles sur votre profil.',
              color: AppColors.clubGreen,
              background: p.successTint,
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _fieldsForRole() {
    switch (_role) {
      case UserType.agent:
        return _agentFields();
      case UserType.recruiter:
        return _clubFields();
      default:
        return _playerFields();
    }
  }

  Widget _pills(List<String> options, bool Function(String) isSel, void Function(String) onTap) =>
      Padding(
        padding: const EdgeInsets.only(bottom: AppDimens.md),
        child: Wrap(
          spacing: AppDimens.sm,
          runSpacing: AppDimens.sm,
          children: options
              .map((o) => ChoicePill(label: o, selected: isSel(o), onTap: () => onTap(o)))
              .toList(),
        ),
      );

  Widget _emailField() => LabeledField(label: 'Adresse e-mail', controller: _c['email'], readOnly: true);

  List<Widget> _playerFields() {
    return [
      const SectionTitle('Informations générales'),
      LabeledField(label: 'Prénom et nom', controller: _c['name']),
      LabeledField(
        label: 'Date de naissance',
        controller: _c['birth'],
        readOnly: true,
        onTap: _pickBirthDate,
        trailing: Icon(LucideIcons.calendarDays, size: 18, color: AccountPalette.of(context).text3),
      ),
      LabeledField(label: 'Nationalité', controller: _c['nationality']),
      LabeledField(label: 'Ville', controller: _c['city']),
      _emailField(),
      const SectionTitle('Informations football'),
      _pills(const ['ATT', 'MIL', 'DEF', 'GAR'], (o) => o == _position,
          (o) => _setChoice(() => _position = o)),
      LabeledField(label: 'Postes secondaires', controller: _c['secondary']),
      Row(
        children: [
          Expanded(
              child: LabeledField(
                  label: 'Taille (cm)', controller: _c['height'], keyboardType: TextInputType.number)),
          const SizedBox(width: AppDimens.md),
          Expanded(
              child: LabeledField(
                  label: 'Poids (kg)', controller: _c['weight'], keyboardType: TextInputType.number)),
        ],
      ),
      _pills(const ['Droit', 'Gauche', 'Ambidextre'], (o) => o == _foot,
          (o) => _setChoice(() => _foot = o)),
      LabeledField(label: 'Club actuel', controller: _c['club']),
      LabeledField(label: 'Niveau / Expérience', controller: _c['level']),
      SwitchRow(
        title: 'Disponible pour une opportunité',
        value: _available,
        onChanged: (v) => _setChoice(() => _available = v),
      ),
      const SectionTitle('À propos et parcours'),
      LabeledField(label: 'Objectif sportif', controller: _c['goal'], maxLines: 4, maxLength: 300),
      IconRow(
        icon: LucideIcons.pencil,
        title: 'Modifier le parcours',
        subtitle: '3 étapes de formation',
        chevron: true,
        onTap: () => showAccountSnack(context, 'Édition du parcours (démo)'),
      ),
    ];
  }

  List<Widget> _agentFields() {
    return [
      const SectionTitle('Informations générales'),
      LabeledField(label: 'Prénom et nom', controller: _c['name']),
      LabeledField(label: 'Agence / Organisation', controller: _c['agency']),
      LabeledField(label: 'Pays', controller: _c['country']),
      LabeledField(label: 'Ville', controller: _c['city']),
      _emailField(),
      LabeledField(label: 'Téléphone (privé)', controller: _c['phone'], keyboardType: TextInputType.phone),
      const SectionTitle('Activité professionnelle'),
      _pills(const ['Indépendant', 'Agence', 'Intermédiaire'], (o) => o == _agentStatus,
          (o) => _setChoice(() => _agentStatus = o)),
      LabeledField(
          label: 'Années d’expérience', controller: _c['experience'], keyboardType: TextInputType.number),
      LabeledField(label: 'Numéro de licence', controller: _c['licence'], hint: 'Facultatif'),
      LabeledField(label: 'Zones couvertes', controller: _c['zones']),
      const SectionTitle('À propos'),
      LabeledField(label: 'Présentation', controller: _c['bio'], maxLines: 4, maxLength: 400),
    ];
  }

  List<Widget> _clubFields() {
    return [
      const SectionTitle('Informations du club'),
      LabeledField(label: 'Nom du club / académie', controller: _c['club']),
      LabeledField(label: 'Ville', controller: _c['city']),
      LabeledField(label: 'Pays', controller: _c['country']),
      LabeledField(label: 'Site web', controller: _c['website'], keyboardType: TextInputType.url),
      const SectionTitle('Catégories recrutées'),
      _pills(const ['U15', 'U17', 'U19', 'U21', 'Seniors'], _categories.contains, (o) {
        _setChoice(() {
          if (_categories.contains(o)) {
            if (_categories.length > 1) _categories.remove(o);
          } else {
            _categories.add(o);
          }
        });
      }),
      const SectionTitle('Contact recrutement'),
      LabeledField(label: 'Nom du responsable', controller: _c['contact']),
      LabeledField(label: 'Fonction', controller: _c['contactRole']),
      _emailField(),
      LabeledField(label: 'Téléphone (privé)', controller: _c['phone'], keyboardType: TextInputType.phone),
      const SectionTitle('À propos'),
      LabeledField(label: 'Présentation du club', controller: _c['bio'], maxLines: 4, maxLength: 400),
    ];
  }
}
