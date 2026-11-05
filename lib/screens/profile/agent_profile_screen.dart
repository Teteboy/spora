import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'profile_mock_data.dart';
import 'profile_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Public agent profile — /agent-profile/:id (frame « Agent »).
class AgentPublicProfileScreen extends StatefulWidget {
  final String? agentId;
  const AgentPublicProfileScreen({super.key, this.agentId});

  @override
  State<AgentPublicProfileScreen> createState() =>
      _AgentPublicProfileScreenState();
}

class _AgentPublicProfileScreenState extends State<AgentPublicProfileScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    const a = ProfileMockData.agent;
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: const ProfileAppBar(title: 'Profil de l’agent'),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenMargin),
        children: [
          const SizedBox(height: 8),
          _hero(a),
          const SizedBox(height: 16),
          ProfileCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Licence professionnelle', style: AppTextStyles.h3()),
                const SizedBox(height: 8),
                Text(a.license, style: AppTextStyles.body()),
                const SizedBox(height: 4),
                Text(
                    'Vérification du rôle accordée séparément de l’abonnement.',
                    style: AppTextStyles.caption()),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _tabs(),
          const SizedBox(height: 16),
          _section(a),
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
                  label: 'Contacter',
                  icon: LucideIcons.messageCircle,
                  onTap: () => context.push('/chat/${widget.agentId ?? 'a1'}',
                      extra: {'name': a.name, 'role': 'Agent FIFA'})),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero(AgentProfileData a) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(AppDimens.radiusHero),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(a.initials,
                style: AppTextStyles.h2(color: AppColors.primary)),
          ),
          const SizedBox(height: 12),
          Text(a.name, style: AppTextStyles.h1(color: Colors.white)),
          const SizedBox(height: 4),
          Text('${a.agency} · ${a.activity}',
              style: AppTextStyles.body(color: Colors.white70)),
          const SizedBox(height: 10),
          const BadgePill(
              label: 'Agent vérifié',
              bg: AppColors.primaryTint,
              fg: AppColors.primary),
          const SizedBox(height: 10),
          Text('${a.country} · ${a.yearsExperience} ans d’expérience',
              style: AppTextStyles.caption(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _tabs() {
    const labels = ['À propos', 'Joueurs représentés', 'Opportunités'];
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

  Widget _section(AgentProfileData a) {
    switch (_tab) {
      case 1:
        return _players(a);
      case 2:
        return _opportunity(a.opportunity);
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('À propos', style: AppTextStyles.h3()),
                  const SizedBox(height: 8),
                  Text(a.about, style: AppTextStyles.body()),
                  const SizedBox(height: 8),
                  Text(
                      'Profil fictif de démonstration · Aucune coordonnée publique',
                      style: AppTextStyles.caption()),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Joueurs représentés · ${a.playersCount}',
                style: AppTextStyles.h3()),
            const SizedBox(height: 8),
            for (final p in a.players) ...[
              _playerTile(p),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
            _opportunity(a.opportunity),
          ],
        );
    }
  }

  Widget _players(AgentProfileData a) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Joueurs représentés · ${a.playersCount}',
            style: AppTextStyles.h3()),
        const SizedBox(height: 8),
        for (final p in a.players) ...[
          _playerTile(p),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _playerTile(RepresentedPlayer p) {
    return ProfileCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.muted,
            backgroundImage:
                p.avatarUrl != null ? NetworkImage(p.avatarUrl!) : null,
            child: p.avatarUrl == null
                ? const Icon(LucideIcons.user, color: AppColors.textMuted)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: AppTextStyles.bodyStrong()),
                Text(p.line1, style: AppTextStyles.caption()),
                Text(p.line2, style: AppTextStyles.caption()),
              ],
            ),
          ),
          const Icon(LucideIcons.badgeCheck, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _opportunity(OpportunitySummary o) {
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
