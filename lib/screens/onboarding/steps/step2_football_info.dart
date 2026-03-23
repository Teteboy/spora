import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../widgets/custom_text_field.dart';

class Step2FootballInfo extends StatefulWidget {
  const Step2FootballInfo({super.key});

  @override
  State<Step2FootballInfo> createState() => _Step2FootballInfoState();
}

class _Step2FootballInfoState extends State<Step2FootballInfo> {
  String? _primaryPosition;
  String? _selectedAge;
  String? _selectedClub;
  String? _selectedYear;
  final _matchesCtrl = TextEditingController();

  final _clubs = ['Olympique FC', 'Dynamo FC', 'Belfort SC', 'FC Mistral', 'Athletic Nantes', 'Paris Youth', 'Autre'];
  final _years = List.generate(20, (i) => '${2024 - i}');
  final _ages = List.generate(30, (i) => '${i + 14} ans');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMD),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spacingMD),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                  boxShadow: [
                    BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Infos football',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Remplis les informations ci-dessous.',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 90,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt_outlined, color: AppColors.primaryLight, size: 28),
                                SizedBox(height: 4),
                                Text(
                                  'Photo de profil\n(optionnel)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: 9, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            children: [
                              CustomTextField(hint: 'Poste principal'),
                              const SizedBox(height: 8),
                              CustomDropdown(
                                hint: 'Âge',
                                value: _selectedAge,
                                items: _ages,
                                onChanged: (v) => setState(() => _selectedAge = v),
                              ),
                              const SizedBox(height: 8),
                              CustomTextField(hint: 'Email'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Club actuel',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    CustomDropdown(
                      hint: 'Nom du Club',
                      value: _selectedClub,
                      items: _clubs,
                      prefixIcon: const Icon(Icons.shield_outlined, color: AppColors.textSecondary, size: 18),
                      onChanged: (v) => setState(() => _selectedClub = v),
                    ),
                    const SizedBox(height: 10),
                    CustomDropdown(
                      hint: "Année d'arrivée",
                      value: _selectedYear,
                      items: _years,
                      onChanged: (v) => setState(() => _selectedYear = v),
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      hint: 'Matchs joués',
                      controller: _matchesCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05, duration: 400.ms),
            ),
          ),
          const SizedBox(height: 16),
          _buildBottomSection(context),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    final onboarding = context.read<OnboardingProvider>();
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              onboarding.updateStep2(
                primaryPosition: _primaryPosition ?? '',
                currentClub: _selectedClub ?? '',
              );
              onboarding.nextStep();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Continuer',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
            children: [
              TextSpan(text: 'En créant un profil joueur, tu acceptes nos '),
              TextSpan(text: 'Conditions générales', style: TextStyle(color: AppColors.primaryLight, decoration: TextDecoration.underline)),
              TextSpan(text: ' et notre '),
              TextSpan(text: 'Politique de confidentialité', style: TextStyle(color: AppColors.primaryLight, decoration: TextDecoration.underline)),
              TextSpan(text: '.'),
            ],
          ),
        ),
      ],
    );
  }
}
