import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/user_model.dart';

class Step3Highlights extends StatelessWidget {
  const Step3Highlights({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMD),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Premium upsell card
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingMD),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                      boxShadow: [
                        BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: AppColors.goldGradient),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.lock_outline, color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Highlights',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Débloquez vos highlights pour vous mettre en avant:',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ...[
                          'Highlights illimités',
                          'Mise en avant',
                          'Badge Premium',
                        ].map((feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFECFDF5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check, color: AppColors.success, size: 14),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                feature,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        )),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.go('/premium'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              'Passer en Premium',
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 16),
                  // Video preview
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                      boxShadow: [
                        BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.network(
                            'https://picsum.photos/400/220?random=10',
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            height: 180,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black.withValues(alpha: 0.3), Colors.transparent],
                              ),
                            ),
                          ),
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.play_arrow, color: AppColors.primary, size: 32),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
                  const SizedBox(height: 8),
                  const Text(
                    'Vos meilleures actions en vidéo.',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _finishOnboarding(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Ignorer pour l\'instant',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _finishOnboarding(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final router = GoRouter.of(context);
    auth.register(
      name: 'Nouveau Joueur',
      email: 'player@spora.com',
      password: 'password123',
      role: UserRole.player,
    ).then((_) => router.go('/home'));
  }
}

