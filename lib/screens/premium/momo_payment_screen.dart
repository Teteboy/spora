import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'premium_widgets.dart';
import 'payment_failed_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Frames "Mobile Money — Numéro" + "Mobile Money — Attente" (/premium/momo).
class MomoPaymentScreen extends StatefulWidget {
  final PremiumPlan? plan;
  final String? operatorName;
  const MomoPaymentScreen({super.key, this.plan, this.operatorName});

  @override
  State<MomoPaymentScreen> createState() => _MomoPaymentScreenState();
}

class _MomoPaymentScreenState extends State<MomoPaymentScreen> {
  final _phoneCtrl = TextEditingController();
  bool _waiting = false;
  int _secondsLeft = 102; // 01:42
  Timer? _timer;
  Timer? _autoResolve;

  PremiumPlan get _plan {
    if (widget.plan != null) return widget.plan!;
    final extra = GoRouterState.of(context).extra;
    if (extra is Map && extra['plan'] is PremiumPlan) {
      return extra['plan'] as PremiumPlan;
    }
    return const PremiumPlan();
  }

  String get _operator {
    if (widget.operatorName != null) return widget.operatorName!;
    final extra = GoRouterState.of(context).extra;
    if (extra is Map && extra['operator'] is String) {
      return extra['operator'] as String;
    }
    return 'Orange Money';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _autoResolve?.cancel();
    _phoneCtrl.dispose();
    super.dispose();
  }

  String get _maskedNumber {
    final digits = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 2) {
      return '+237 ${digits[0]}•• •• •• ${digits.substring(digits.length - 2)}';
    }
    return '+237 6•• •• •• 42';
  }

  void _pay() {
    setState(() {
      _waiting = true;
      _secondsLeft = 102;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) _secondsLeft--;
      });
    });
    // Mock: auto-resolves after a few seconds. Numbers ending in '0' fail.
    _autoResolve = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      _timer?.cancel();
      final digits = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
      if (digits.endsWith('0')) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => PaymentFailedScreen(
              plan: _plan, method: _operator),
        ));
      } else {
        context.pushReplacement('/premium/welcome', extra: _plan);
      }
    });
  }

  void _cancel() {
    _timer?.cancel();
    _autoResolve?.cancel();
    setState(() => _waiting = false);
  }

  String get _countdown {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s restantes';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: _waiting ? _buildWaiting() : _buildNumber(),
      ),
    );
  }

  Widget _buildNumber() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: AppDimens.screenMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PaymentHeader(title: 'Mobile Money — Numéro'),
                const SizedBox(height: AppDimens.md),
                StatusPill(
                    label: _operator,
                    bg: AppColors.primaryTint,
                    fg: AppColors.primary),
                const SizedBox(height: AppDimens.lg),
                Text('Votre numéro Mobile Money',
                    style: AppTextStyles.display()),
                const SizedBox(height: AppDimens.section),
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: AppTextStyles.h3(),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Numéro de téléphone',
                    labelStyle: AppTextStyles.bodyLarge(),
                    prefixText: '+237  ',
                    prefixStyle: AppTextStyles.h3(),
                    hintText: '6•• •• •• 42',
                    hintStyle:
                        AppTextStyles.h3(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusCard),
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusCard),
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.section),
                Text(
                  'Vous recevrez une demande de confirmation sur votre téléphone.',
                  style: AppTextStyles.bodyLarge(
                      color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppDimens.section),
                RecapCard(plan: _plan),
                const SizedBox(height: AppDimens.section),
                const InfoBanner(
                  title: 'Votre code reste secret',
                  body:
                      'Confirmez uniquement dans l’interface officielle de votre opérateur. Ne partagez jamais votre PIN.',
                ),
                const SizedBox(height: AppDimens.section),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppDimens.screenMargin, 0,
              AppDimens.screenMargin, AppDimens.md),
          child: GradientButton(
              label: 'Payer ${_plan.price}', onPressed: _pay),
        ),
      ],
    );
  }

  Widget _buildWaiting() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: AppDimens.screenMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PaymentHeader(title: 'Mobile Money — Attente'),
                const SizedBox(height: AppDimens.section),
                const Center(
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(LucideIcons.smartphone,
                            size: 64, color: AppColors.primary),
                        Positioned(
                          bottom: 4,
                          child: SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.section),
                Text('Confirmez sur votre téléphone',
                    style: AppTextStyles.display()),
                const SizedBox(height: AppDimens.lg),
                StatusPill(
                    label: _countdown,
                    bg: AppColors.primaryTint,
                    fg: AppColors.primary),
                const SizedBox(height: AppDimens.section),
                Container(
                  padding: const EdgeInsets.all(AppDimens.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusCard),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _StepRow(
                        icon: LucideIcons.checkCircle,
                        title: 'Demande envoyée',
                        subtitle: '$_operator · $_maskedNumber',
                      ),
                      const Divider(height: 32, color: AppColors.divider),
                      const _StepRow(
                        icon: LucideIcons.smartphone,
                        title: 'Validez auprès de votre opérateur',
                        subtitle:
                            'Ouvrez la notification reçue sur votre téléphone.',
                      ),
                      const Divider(height: 32, color: AppColors.divider),
                      const _StepRow(
                        icon: LucideIcons.clock,
                        title: 'Attendez la confirmation',
                        subtitle:
                            'Votre abonnement sera activé après validation du prestataire.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.section),
                const InfoBanner(
                  title: 'Ne quittez pas la demande opérateur',
                  body:
                      'Aucun code PIN ou code USSD ne vous sera demandé dans SPORA.',
                ),
                const SizedBox(height: AppDimens.section),
                OutlineActionButton(
                  label: 'Vérifier le statut',
                  onPressed: () {},
                ),
                const SizedBox(height: AppDimens.md),
                Center(
                  child: TextButton(
                    onPressed: _cancel,
                    child: Text('Annuler le paiement',
                        style:
                            AppTextStyles.h3(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: AppDimens.md),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _StepRow(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: AppDimens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyStrong()),
              const SizedBox(height: AppDimens.xs),
              Text(subtitle, style: AppTextStyles.body()),
            ],
          ),
        ),
      ],
    );
  }
}
