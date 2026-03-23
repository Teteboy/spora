import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/spora_logo.dart';
import '../../widgets/step_indicator.dart';
import 'steps/step1_general_info.dart';
import 'steps/step2_football_info.dart';
import 'steps/step3_highlights.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingProvider(),
      child: const _OnboardingContent(),
    );
  }
}

class _OnboardingContent extends StatelessWidget {
  const _OnboardingContent();

  static const List<String> _steps = ['Infos générales', 'Infos football', 'Highlights'];

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Bottom wave decoration
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xFFBFD7FF),
                    Color(0xFF2563EB),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingMD,
                    vertical: AppConstants.spacingSM,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
                        onPressed: () {
                          if (onboarding.currentStep > 0) {
                            onboarding.previousStep();
                          } else {
                            context.go('/register');
                          }
                        },
                      ),
                      const Expanded(child: Center(child: SporaLogo(height: 32))),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text(
                          'Connexion',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMD),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Crée ton profil joueur ',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 22,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            TextSpan(
                              text: 'SPORA',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Rejoins les clubs et recruteurs.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StepIndicator(
                        currentStep: onboarding.currentStep,
                        steps: _steps,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Step Content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: switch (onboarding.currentStep) {
                      0 => const Step1GeneralInfo(key: ValueKey('step1')),
                      1 => const Step2FootballInfo(key: ValueKey('step2')),
                      _ => const Step3Highlights(key: ValueKey('step3')),
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
