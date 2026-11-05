import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'auth_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// A separate explicit choice is required; the provider defaults to player.
UserType? registrationRole;

class RoleChoiceScreen extends StatefulWidget {
  const RoleChoiceScreen({super.key});
  @override
  State<RoleChoiceScreen> createState() => _RoleChoiceScreenState();
}
class _RoleChoiceScreenState extends State<RoleChoiceScreen> {
  UserType? _selected;
  @override
  Widget build(BuildContext context) => AuthPage(title: 'Votre place sur le terrain', back: '/welcome', bottom: AuthButton('Continuer', onPressed: _selected == null ? null : () {
    registrationRole = _selected;
    context.read<AuthProvider>().setUserType(_selected!);
    context.push(_selected == UserType.guest ? '/invite' : '/register');
  }), children: [
    const SizedBox(height: 16), Text('BIENVENUE SUR SPORA', style: AppTextStyles.eyebrow(color: AppColors.primary)), const SizedBox(height: 16),
    Text('Vous êtes...', style: AppTextStyles.display()), const SizedBox(height: 16), Text('Un réseau, trois façons de faire avancer le football.', style: AppTextStyles.bodyLarge()), const SizedBox(height: 24),
    _card(UserType.player, 'Joueur', 'Je veux être vu par les clubs et les agents', LucideIcons.user),
    _card(UserType.agent, 'Agent', 'Je représente et accompagne des joueurs', LucideIcons.heartHandshake),
    _card(UserType.recruiter, 'Club', 'Je recrute des talents pour mon club', LucideIcons.shield),
    _card(UserType.guest, 'Invité', 'J’ai un code d’invitation pour explorer les talents', LucideIcons.ticket),
    const SizedBox(height: 12), Row(children: [const Icon(LucideIcons.lock, color: AppColors.textMuted, size: 18), const SizedBox(width: 8), Expanded(child: Text('Vos coordonnées restent sous votre contrôle.', style: AppTextStyles.caption()))]),
  ]);
  Widget _card(UserType role, String title, String description, IconData icon) {
    final selected = _selected == role;
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Material(color: selected ? AppColors.primaryTint.withValues(alpha: 0.4) : AppColors.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2 : 1)), child: InkWell(borderRadius: BorderRadius.circular(16), onTap: () => setState(() => _selected = role), child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
      Container(width: 48, height: 56, decoration: BoxDecoration(color: selected ? AppColors.primary : AppColors.appBg, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: selected ? AppColors.surface : AppColors.textMuted)), const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTextStyles.h2()), const SizedBox(height: 4), Text(description, style: AppTextStyles.caption(color: AppColors.textSecondary))])), const SizedBox(width: 8), Icon(selected ? LucideIcons.circle : LucideIcons.circle, color: selected ? AppColors.primary : AppColors.border, size: 20),
    ])))));
  }
}
