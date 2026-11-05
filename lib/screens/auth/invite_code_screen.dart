import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import 'auth_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Invitation-code gate for the invitee (guest) role.
///
/// Mock validation: any code of 4+ characters is accepted — demo code
/// `SPORA-2024` is suggested on screen. A valid code signs the user in
/// with the restricted guest session.
class InviteCodeScreen extends StatefulWidget {
  const InviteCodeScreen({super.key});

  @override
  State<InviteCodeScreen> createState() => _InviteCodeScreenState();
}

class _InviteCodeScreenState extends State<InviteCodeScreen> {
  final _code = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    auth.setUserType(UserType.guest);
    await auth.loginWithDemoCredentials();
    if (mounted) context.go('/invitee/discover');
  }

  @override
  Widget build(BuildContext context) => AuthPage(
        title: 'Code d’invitation',
        back: '/role',
        bottom: AuthButton(
          'Accéder à SPORA',
          loading: _loading,
          onPressed: _submit,
        ),
        children: [
          const SizedBox(height: 16),
          Text('ACCÈS INVITÉ',
              style: AppTextStyles.eyebrow(color: AppColors.primary)),
          const SizedBox(height: 16),
          Text('Vous avez été invité', style: AppTextStyles.display()),
          const SizedBox(height: 16),
          Text(
            'Saisissez le code reçu d’un club, d’un agent ou d’un joueur pour découvrir les talents et les highlights.',
            style: AppTextStyles.bodyLarge(),
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: AuthField(
              label: 'Code d’invitation',
              hint: 'ex. SPORA-2024',
              controller: _code,
              icon: LucideIcons.ticket,
              validator: (v) => (v ?? '').trim().length >= 4
                  ? null
                  : 'Saisissez un code d’invitation valide.',
            ),
          ),
          const AuthNotice(
              'Le compte invité donne un accès en lecture seule : découverte des talents, profils et highlights.'),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(LucideIcons.info, color: AppColors.textMuted, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Démo : utilisez le code SPORA-2024.',
                  style: AppTextStyles.caption()),
            ),
          ]),
        ],
      );
}
