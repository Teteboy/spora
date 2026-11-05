import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'premium_widgets.dart';
import 'payment_failed_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Frame "Authentification 3-D Secure" / "Paiement sécurisé" (/premium/3ds).
class ThreeDsScreen extends StatefulWidget {
  final PremiumPlan? plan;
  const ThreeDsScreen({super.key, this.plan});

  @override
  State<ThreeDsScreen> createState() => _ThreeDsScreenState();
}

class _ThreeDsScreenState extends State<ThreeDsScreen> {
  final _codeCtrl = TextEditingController();
  bool _checking = false;

  PremiumPlan get _plan {
    if (widget.plan != null) return widget.plan!;
    final extra = GoRouterState.of(context).extra;
    if (extra is PremiumPlan) return extra;
    return const PremiumPlan();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _validate() async {
    setState(() => _checking = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    // Mock: any 6-digit code works except '000000' which fails.
    if (_codeCtrl.text.trim() == '000000') {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) =>
            PaymentFailedScreen(plan: _plan, method: 'Carte bancaire'),
      ));
    } else {
      context.pushReplacement('/premium/welcome', extra: _plan);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimens.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PaymentHeader(title: 'Paiement sécurisé'),
              const SizedBox(height: AppDimens.md),
              const StatusPill(
                  label: 'Carte bancaire',
                  bg: AppColors.primaryTint,
                  fg: AppColors.primary),
              const SizedBox(height: AppDimens.lg),
              Text('Confirmez auprès de votre banque',
                  style: AppTextStyles.display()),
              const SizedBox(height: AppDimens.section),
              // Amount card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimens.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusCard),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.lock,
                            color: AppColors.primary, size: 24),
                        const SizedBox(width: AppDimens.md),
                        Text(_plan.recapLine,
                            style: AppTextStyles.bodyStrong()),
                      ],
                    ),
                    const SizedBox(height: AppDimens.md),
                    Text(_plan.price, style: AppTextStyles.h1()),
                    const SizedBox(height: AppDimens.md),
                    Text('Montant fictif · Carte •••• 4242',
                        style: AppTextStyles.body()),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.section),
              // 3-D Secure mock
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimens.section),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusCard),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Icon(LucideIcons.shieldCheck,
                        color: AppColors.primary, size: 44),
                    const SizedBox(height: AppDimens.md),
                    Text('Authentification 3-D Secure',
                        style: AppTextStyles.h2()),
                    const SizedBox(height: AppDimens.sm),
                    Text(
                      'L’écran sécurisé de votre banque s’affichera ici via le prestataire de paiement.',
                      style: AppTextStyles.body(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimens.lg),
                    TextField(
                      controller: _codeCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h3(),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Code de démonstration',
                        hintStyle:
                            AppTextStyles.body(color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.muted,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimens.radiusPill),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimens.md),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _checking ? null : _validate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimens.radiusPill),
                          ),
                        ),
                        child: _checking
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white))
                            : Text('Valider le code',
                                style: AppTextStyles.button()),
                      ),
                    ),
                    const SizedBox(height: AppDimens.md),
                    Text(
                      'Aucune banque ni transaction réelle n’est connectée.',
                      style: AppTextStyles.caption(),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.section),
              const InfoBanner(
                title: 'Vos informations restent protégées',
                body:
                    'SPORA ne demande jamais votre code PIN. Les instructions réelles seront fournies uniquement par votre banque.',
              ),
              const SizedBox(height: AppDimens.section),
              OutlineActionButton(
                label: 'Revenir au paiement',
                onPressed: () => context.pop(),
              ),
              const SizedBox(height: AppDimens.md),
              Center(
                child: Text(
                  'Aucun paiement n’est confirmé à cette étape.',
                  style: AppTextStyles.caption(),
                ),
              ),
              const SizedBox(height: AppDimens.section),
            ],
          ),
        ),
      ),
    );
  }
}
