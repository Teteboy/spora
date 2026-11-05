import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'account_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// "/help" — frame "Aide et FAQ".
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  static const _faq = <(String, String)>[
    (
      'Quelle est la limite des vidéos ?',
      'Chaque vidéo peut durer jusqu’à 60 secondes et peser jusqu’à 200 Mo. Une présentation de 30 secondes est recommandée. Le compte gratuit permet 1 highlight publié, Premium un nombre illimité.'
    ),
    (
      'Qui peut me contacter ?',
      'Seuls les agents et clubs vérifiés peuvent vous écrire. Vous pouvez bloquer un utilisateur à tout moment depuis la conversation ou les paramètres de confidentialité.'
    ),
    (
      'Comment faire vérifier mon profil ?',
      'Depuis Mon profil › Vérification, ajoutez une pièce d’identité puis une preuve de rôle (licence, document du club). L’équipe SPORA examine votre demande avant d’accorder le badge Vérifié.'
    ),
    (
      'Comment protéger un joueur mineur ?',
      'Le consentement du représentant légal est requis avant toute apparition dans la découverte. Les coordonnées restent masquées et les échanges sont encadrés.'
    ),
    (
      'Comment suivre une candidature ?',
      'Retrouvez toutes vos candidatures dans Mon profil › Mes candidatures. Chaque changement de statut vous est notifié.'
    ),
    (
      'Comment annuler Premium ?',
      'Rendez-vous dans Mon profil › Premium › Gérer l’abonnement. La résiliation prend effet à la fin de la période en cours.'
    ),
  ];

  final _search = TextEditingController();
  int? _open = 0;

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _contactSupport() {
    final p = AccountPalette.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: p.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusSheet))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, AppDimens.lg, 0, AppDimens.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.xl),
                child: Text('Contacter le support', style: AppTextStyles.h2(color: p.text)),
              ),
              const SizedBox(height: AppDimens.sm),
              IconRow(
                icon: LucideIcons.mail,
                title: 'Par e-mail',
                subtitle: 'support@spora.app · réponse sous 48 h',
                onTap: () {
                  Navigator.pop(ctx);
                  showAccountSnack(context, 'Ouverture de votre messagerie (démo)');
                },
              ),
              IconRow(
                icon: LucideIcons.messageCircle,
                title: 'Par message',
                subtitle: 'Discuter avec l’équipe SPORA',
                onTap: () {
                  Navigator.pop(ctx);
                  showAccountSnack(context, 'Conversation avec le support ouverte (démo)');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    final q = _search.text.trim().toLowerCase();
    final items = [
      for (var i = 0; i < _faq.length; i++)
        if (q.isEmpty || _faq[i].$1.toLowerCase().contains(q) || _faq[i].$2.toLowerCase().contains(q)) i
    ];

    return AccountScaffold(
      title: 'Aide et FAQ',
      boxedBack: true,
      children: [
        const PageHeading('Comment vous aider ?'),
        LabeledField(
          label: 'Rechercher dans l’aide',
          controller: _search,
          hint: 'Profil, vidéos, candidature…',
          trailing: Icon(LucideIcons.search, color: p.text3),
        ),
        const SectionTitle('Questions fréquentes'),
        if (items.isEmpty)
          AccountCard(
            child: Text('Aucun résultat. Essayez un autre mot-clé ou contactez le support.',
                style: AppTextStyles.body(color: p.text2)),
          ),
        ...items.map((i) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.md),
              child: _FaqTile(
                question: _faq[i].$1,
                answer: _faq[i].$2,
                expanded: _open == i || q.isNotEmpty && items.length == 1,
                onTap: () => setState(() => _open = _open == i ? null : i),
              ),
            )),
        const SizedBox(height: AppDimens.sm),
        GradientButton(label: 'Contacter le support', onPressed: _contactSupport),
        const SizedBox(height: AppDimens.md),
        SecondaryButton(label: 'Signaler un problème', onPressed: () => context.push('/report')),
        const SizedBox(height: AppDimens.lg),
        Text('Ne partagez jamais votre mot de passe, votre code PIN ou vos informations bancaires dans un message.',
            style: AppTextStyles.caption(color: p.text3)),
      ],
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  final bool expanded;
  final VoidCallback onTap;
  const _FaqTile({required this.question, required this.answer, required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = AccountPalette.of(context);
    return Material(
      color: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        side: BorderSide(color: p.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppDimens.lg, AppDimens.lg, AppDimens.md, AppDimens.lg),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  button: true,
                  expanded: expanded,
                  child: Row(
                    children: [
                      Expanded(child: Text(question, style: AppTextStyles.bodyStrong(color: p.text))),
                      const SizedBox(width: AppDimens.sm),
                      Icon(expanded ? LucideIcons.minus : LucideIcons.plus, color: AppColors.primary, size: 26),
                    ],
                  ),
                ),
                if (expanded) ...[
                  const SizedBox(height: AppDimens.md),
                  Padding(
                    padding: const EdgeInsets.only(right: AppDimens.sm),
                    child: Text(answer, style: AppTextStyles.body(color: p.text2)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
