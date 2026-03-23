import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../widgets/custom_text_field.dart';

class Step1GeneralInfo extends StatefulWidget {
  const Step1GeneralInfo({super.key});

  @override
  State<Step1GeneralInfo> createState() => _Step1GeneralInfoState();
}

class _Step1GeneralInfoState extends State<Step1GeneralInfo> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String? _selectedPosition;
  String? _selectedAge;

  final List<String> _ages = List.generate(30, (i) => '${i + 14} ans');

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
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Infos générales',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Remplis les informations ci-dessous.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile photo
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: 90,
                              height: 100,
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
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 9,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Form fields
                          Expanded(
                            child: Column(
                              children: [
                                CustomTextField(
                                  hint: 'Nom et prénom',
                                  controller: _nameCtrl,
                                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomDropdown(
                                        hint: 'Âge',
                                        value: _selectedAge,
                                        items: _ages,
                                        onChanged: (v) => setState(() => _selectedAge = v),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: CustomDropdown(
                                        hint: 'Poste',
                                        value: _selectedPosition,
                                        items: AppConstants.positions,
                                        onChanged: (v) => setState(() => _selectedPosition = v),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                CustomTextField(
                                  hint: 'Email',
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hint: 'Email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        hint: 'Mot de passe',
                        isPassword: true,
                      ),
                    ],
                  ),
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
              onboarding.updateStep1(
                firstName: _nameCtrl.text.split(' ').first,
                lastName: _nameCtrl.text.split(' ').length > 1 ? _nameCtrl.text.split(' ').last : '',
                email: _emailCtrl.text,
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
              TextSpan(
                text: 'Conditions générales',
                style: TextStyle(
                  color: AppColors.primaryLight,
                  decoration: TextDecoration.underline,
                ),
              ),
              TextSpan(text: ' et notre '),
              TextSpan(
                text: 'Politique de confidentialité',
                style: TextStyle(
                  color: AppColors.primaryLight,
                  decoration: TextDecoration.underline,
                ),
              ),
              TextSpan(text: '.'),
            ],
          ),
        ),
      ],
    );
  }
}
