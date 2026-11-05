import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'profile_mock_data.dart';
import 'profile_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Public club profile — /club/:id (frame « Club »).
class ClubProfileScreen extends StatefulWidget {
  final String? clubId;
  const ClubProfileScreen({super.key, this.clubId});

  @override
  State<ClubProfileScreen> createState() => _ClubProfileScreenState();
}

class _ClubProfileScreenState extends State<ClubProfileScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    const c = ProfileMockData.club;
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: const ProfileAppBar(title: 'Profil du club'),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenMargin),
        children: [
          const SizedBox(height: 8),
          _hero(c),
          const SizedBox(height: 16),
          _tabs(),
          const SizedBox(height: 16),
          _section(c),
          const SizedBox(height: 16),
          const InfoBanner(
            icon: LucideIcons.shield,
            title: 'Échanges encadrés',
            body:
                'Contact réservé aux recruteurs vérifiés. Les joueurs peuvent répondre à un message reçu ou échanger après une candidature.',
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Vue d’un recruteur vérifié', style: AppTextStyles.caption()),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: PrimaryButton(
                  label: 'Contacter le recruteur',
                  icon: LucideIcons.messageCircle,
                  onTap: () => context.push('/chat/${widget.clubId ?? 'c1'}',
                      extra: {'name': c.name, 'role': 'Club'})),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero(ClubProfileData c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppColors.clubGreen, AppColors.navy900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(AppDimens.radiusHero),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crest
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFDFF3EA),
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.shield,
                    color: AppColors.clubGreen, size: 28),
                Text(c.initials,
                    style:
                        AppTextStyles.micro(color: AppColors.clubGreen)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(c.name, style: AppTextStyles.h1(color: Colors.white)),
          const SizedBox(height: 4),
          Text('${c.type} · ${c.city}',
              style: AppTextStyles.body(color: Colors.white70)),
          const SizedBox(height: 10),
          const BadgePill(
              label: 'Club vérifié',
              bg: AppColors.primaryTint,
              fg: AppColors.primary),
          const SizedBox(height: 10),
          Text('${c.country} · ${c.levels}',
              style: AppTextStyles.caption(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _tabs() {
    const labels = ['Le club', 'Recherche en cours', 'Opportunités'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            PillChip(
                label: labels[i],
                selected: _tab == i,
                onTap: () => setState(() => _tab = i)),
            if (i < labels.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _section(ClubProfileData c) {
    switch (_tab) {
      case 1:
        return _sought(c);
      case 2:
        return _opportunities(c);
      default:
        return Column(
          children: [
            ProfileCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Le club', style: AppTextStyles.h3()),
                  const SizedBox(height: 8),
                  Text(c.about, style: AppTextStyles.body()),
                  const SizedBox(height: 8),
                  Text(
                      'Profil fictif de démonstration · Aucune coordonnée publique',
                      style: AppTextStyles.caption()),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _sought(c),
            const SizedBox(height: 16),
            _opportunities(c),
          ],
        );
    }
  }

  Widget _sought(ClubProfileData c) {
    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recherche en cours', style: AppTextStyles.h3()),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (var i = 0; i < c.sought.length; i++)
                PillChip(label: c.sought[i], selected: i == 0),
            ],
          ),
          const SizedBox(height: 8),
          Text(c.soughtDetail, style: AppTextStyles.body()),
        ],
      ),
    );
  }

  Widget _opportunities(ClubProfileData c) {
    final o = c.opportunity;
    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Opportunités actives', style: AppTextStyles.h3()),
          const SizedBox(height: 8),
          const BadgePill(
              label: 'Détection',
              bg: Color(0xFFDFF3EA),
              fg: AppColors.clubGreen),
          const SizedBox(height: 8),
          Text(o.title, style: AppTextStyles.bodyStrong()),
          const SizedBox(height: 4),
          Text(o.dates, style: AppTextStyles.body()),
          Text(o.meta, style: AppTextStyles.caption()),
          const SizedBox(height: 12),
          OutlineButton(
              label: 'Voir l’opportunité',
              onTap: () => context.push('/opportunity/o1')),
        ],
      ),
    );
  }
}
