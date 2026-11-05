import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Premier message — pushed when starting a conversation from a profile.
class FirstMessageScreen extends StatefulWidget {
  final String participantName;
  final String participantSubtitle;
  final bool participantVerified;
  final String? conversationId;

  const FirstMessageScreen({
    super.key,
    required this.participantName,
    this.participantSubtitle = '',
    this.participantVerified = true,
    this.conversationId,
  });

  @override
  State<FirstMessageScreen> createState() => _FirstMessageScreenState();
}

class _FirstMessageScreenState extends State<FirstMessageScreen> {
  final _ctrl = TextEditingController(
      text: 'Bonjour Jordan, j’ai vu votre vidéo et votre profil m’intéresse.');

  static const _suggestions = [
    'Bonjour, j’ai vu votre vidéo et votre profil m’intéresse.',
    'Souhaitez-vous participer à notre détection ?',
    'Pouvez-vous m’en dire plus sur votre parcours ?',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _send() {
    if (_ctrl.text.trim().isEmpty) return;
    // The first message creates the conversation, then opens it.
    final id = widget.conversationId ?? 'new_${widget.participantName}';
    context.pushReplacement('/chat/$id', extra: {
      'name': widget.participantName,
      'avatar': null,
      'role': widget.participantSubtitle,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.screenMargin, vertical: AppDimens.lg),
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
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
                Text('Premier message', style: AppTextStyles.h1()),
              ],
            ),
            const SizedBox(height: AppDimens.xl),

            // Recipient card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimens.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(AppDimens.radiusCard),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.participantName, style: AppTextStyles.h2()),
                  const SizedBox(height: AppDimens.xs),
                  Text(widget.participantSubtitle,
                      style: AppTextStyles.body()),
                  const SizedBox(height: AppDimens.md),
                  if (widget.participantVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusPill),
                      ),
                      child: Text('Vérifié',
                          style: AppTextStyles.bodyStrong(
                              color: AppColors.primary)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.lg),

            // Composer card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimens.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(AppDimens.radiusSheet),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Engagez la conversation', style: AppTextStyles.h1()),
                  const SizedBox(height: AppDimens.xs),
                  Text('À l’initiative d’un agent ou d’un club vérifié',
                      style: AppTextStyles.body()),
                  const SizedBox(height: AppDimens.lg),
                  for (final s in _suggestions) ...[
                    GestureDetector(
                      onTap: () => setState(() => _ctrl.text = s),
                      child: Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(AppDimens.cardPadding),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(
                              AppDimens.radiusCard),
                        ),
                        child: Text(s,
                            style: AppTextStyles.bodyStrong(
                                color: AppColors.primary)),
                      ),
                    ),
                    const SizedBox(height: AppDimens.lg),
                  ],
                  Container(
                    padding:
                        const EdgeInsets.all(AppDimens.cardPadding),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusCard),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Votre message',
                            style: AppTextStyles.body()),
                        const SizedBox(height: AppDimens.xs),
                        TextField(
                          controller: _ctrl,
                          maxLength: 2000,
                          maxLines: null,
                          style: AppTextStyles.body(
                              color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            counterText: '',
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.lg),
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: AppColors.primaryGradient),
                        borderRadius: BorderRadius.circular(
                            AppDimens.radiusCard),
                      ),
                      child: ElevatedButton(
                        onPressed: _send,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding:
                              const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimens.radiusCard)),
                        ),
                        child:
                            Text('Envoyer', style: AppTextStyles.button()),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.lg),
                  Text(
                    'Votre e-mail doit être vérifié pour envoyer ce message.',
                    style: AppTextStyles.body(
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.section),
          ],
        ),
      ),
    );
  }
}
