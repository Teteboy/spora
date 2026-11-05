import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../onboarding_draft.dart';
import '../onboarding_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// "Profil prêt" — completion summary, then Explorer SPORA → /home.
class ProfileReadyStep extends StatelessWidget {
  const ProfileReadyStep({
    super.key,
    required this.draft,
    required this.onBack,
    required this.onExplore,
    required this.onViewProfile,
    this.loading = false,
  });

  final PlayerDraft draft;
  final VoidCallback onBack;
  final VoidCallback onExplore;
  final VoidCallback onViewProfile;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final pct = draft.completion;
    final basicsDone = draft.photo != null && draft.footballComplete;
    return OnbScaffold(
      title: 'Profil prêt',
      onBack: loading ? null : onBack,
      eyebrow: 'Bienvenue dans l’équipe',
      progress: pct / 100,
      bottom: OnbPrimaryButton(label: 'Explorer SPORA', loading: loading, onPressed: onExplore),
      children: [
        const SizedBox(height: 8),
        const OnbDoneHeader(
          headline: 'Votre profil est prêt !',
          subtitle: 'Faites le prochain pas, à votre rythme.',
        ),
        const SizedBox(height: 24),
        OnbCard(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profil complété à $pct %', style: AppTextStyles.h2()),
              const SizedBox(height: 12),
              OnbInfoRow(
                icon: basicsDone ? LucideIcons.checkCircle : LucideIcons.circle,
                title: 'Photo et informations football',
                subtitle: basicsDone
                    ? 'Complétées'
                    : draft.photo == null
                        ? 'Ajoutez une photo de profil'
                        : 'À compléter',
              ),
              OnbInfoRow(
                icon: draft.videoAdded ? LucideIcons.clock : LucideIcons.video,
                title: 'Votre vidéo',
                subtitle: draft.videoAdded
                    ? 'En validation par la modération'
                    : 'À ajouter depuis votre profil',
              ),
              const OnbInfoRow(
                icon: LucideIcons.plus,
                title: 'Ajouter votre parcours',
                subtitle: 'Votre prochaine étape',
              ),
              if (draft.isMinor)
                const OnbInfoRow(
                  icon: LucideIcons.shieldCheck,
                  title: 'Accord du tuteur',
                  subtitle: 'Profil masqué jusqu’au consentement',
                ),
              const SizedBox(height: 16),
              OnbSecondaryButton(
                label: 'Voir mon profil',
                onPressed: loading ? null : onViewProfile,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
