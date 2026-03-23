import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/spora_logo.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final auth = context.read<AuthProvider>();
      await auth.login(_emailCtrl.text, _passwordCtrl.text);
      if (mounted && auth.isAuthenticated) {
        _navigateBasedOnUserType(auth);
      } else if (mounted && auth.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.errorMessage!), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _navigateBasedOnUserType(AuthProvider auth) {
    switch (auth.selectedUserType) {
      case UserType.player:
      case UserType.guest:
        context.go('/home');
        break;
      case UserType.agent:
        context.go('/agent');
        break;
      case UserType.recruiter:
        context.go('/recruiter');
        break;
    }
  }

  String _getUserTypeLabel(UserType type) {
    switch (type) {
      case UserType.player:
        return '(Joueur)';
      case UserType.agent:
        return '(Agent)';
      case UserType.recruiter:
        return '(Recruteur)';
      case UserType.guest:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.primaryGradient,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const SporaLogo(height: 50)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.2, duration: 400.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Bienvenue sur SPORA',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                  const SizedBox(height: 32),
                  // Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.spacingLG),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Connexion',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Connectez-vous à votre compte SPORA',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // User Type Selection
                              const Text(
                                'Je suis un:',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Consumer<AuthProvider>(
                                builder: (context, auth, _) {
                                  return Row(
                                    children: [
                                      _UserTypeButton(
                                        icon: Icons.sports_soccer,
                                        label: 'Joueur',
                                        isSelected: auth.selectedUserType == UserType.player,
                                        onTap: () => auth.setUserType(UserType.player),
                                      ),
                                      const SizedBox(width: 8),
                                      _UserTypeButton(
                                        icon: Icons.badge,
                                        label: 'Agent',
                                        isSelected: auth.selectedUserType == UserType.agent,
                                        onTap: () => auth.setUserType(UserType.agent),
                                      ),
                                      const SizedBox(width: 8),
                                      _UserTypeButton(
                                        icon: Icons.business_center,
                                        label: 'Recruteur',
                                        isSelected: auth.selectedUserType == UserType.recruiter,
                                        onTap: () => auth.setUserType(UserType.recruiter),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
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
                                hint: 'votre@email.com',
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary, size: 20),
                                validator: (v) => v!.isEmpty ? 'Email requis' : null,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Mot de passe',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              CustomTextField(
                                hint: '••••••••',
                                controller: _passwordCtrl,
                                isPassword: true,
                                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 20),
                                validator: (v) => v!.length < 6 ? 'Min. 6 caractères' : null,
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'Mot de passe oublié?',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      color: AppColors.primaryLight,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Consumer<AuthProvider>(
                                builder: (context, auth, _) {
                                  return SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: auth.isLoading ? null : _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: auth.isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text(
                                              'Se connecter',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  const Expanded(child: Divider(color: AppColors.border)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      'ou',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  const Expanded(child: Divider(color: AppColors.border)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Pas encore de compte? ',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.go('/register'),
                                    child: const Text(
                                      "S'inscrire",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        color: AppColors.primaryLight,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Demo Login Buttons
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Connexion rapide (Demo)',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Consumer<AuthProvider>(
                                      builder: (context, auth, _) {
                                        return SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: auth.isLoading ? null : () async {
                                              await auth.loginWithDemoCredentials();
                                              if (mounted && auth.isAuthenticated) {
                                                _navigateBasedOnUserType(auth);
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.gold,
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: auth.isLoading
                                                ? const SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child: CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : Text(
                                                    'Connexion Demo ${_getUserTypeLabel(auth.selectedUserType)}',
                                                    style: const TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    Consumer<AuthProvider>(
                                      builder: (context, auth, _) {
                                        return SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton(
                                            onPressed: auth.isLoading ? null : () async {
                                              auth.setUserType(UserType.guest);
                                              await auth.loginWithDemoCredentials();
                                              if (mounted && auth.isAuthenticated) {
                                                _navigateBasedOnUserType(auth);
                                              }
                                            },
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text(
                                              'Continuer en tant qu\'invité',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.1, duration: 500.ms, delay: 200.ms),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserTypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _UserTypeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

