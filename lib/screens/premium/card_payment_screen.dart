import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'premium_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Frame "Carte bancaire" (/premium/card).
class CardPaymentScreen extends StatefulWidget {
  final PremiumPlan? plan;
  const CardPaymentScreen({super.key, this.plan});

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvcCtrl = TextEditingController();
  final _nameCtrl = TextEditingController(text: 'Jordan Mbala');

  PremiumPlan get _plan {
    if (widget.plan != null) return widget.plan!;
    final extra = GoRouterState.of(context).extra;
    if (extra is PremiumPlan) return extra;
    return const PremiumPlan();
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvcCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label, [String? hint]) =>
      InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyLarge(),
        hintText: hint,
        hintStyle: AppTextStyles.h3(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.all(AppDimens.lg),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.screenMargin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PaymentHeader(title: 'Carte bancaire'),
                    const SizedBox(height: AppDimens.md),
                    const Icon(LucideIcons.lock,
                        color: AppColors.primary, size: 28),
                    const SizedBox(height: AppDimens.sm),
                    Text('Paiement sécurisé',
                        style: AppTextStyles.display()),
                    const SizedBox(height: AppDimens.section),
                    TextField(
                      controller: _numberCtrl,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.h3(),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _CardNumberFormatter(),
                      ],
                      decoration:
                          _decoration('Numéro de carte', '•••• •••• •••• ••••'),
                    ),
                    const SizedBox(height: AppDimens.md),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _expiryCtrl,
                            keyboardType: TextInputType.number,
                            style: AppTextStyles.h3(),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              _ExpiryFormatter(),
                            ],
                            decoration: _decoration('Expiration', 'MM / AA'),
                          ),
                        ),
                        const SizedBox(width: AppDimens.md),
                        Expanded(
                          child: TextField(
                            controller: _cvcCtrl,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            style: AppTextStyles.h3(),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            decoration: _decoration('CVC', '•••'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.md),
                    TextField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      style: AppTextStyles.h3(),
                      decoration: _decoration('Nom sur la carte'),
                    ),
                    const SizedBox(height: AppDimens.section),
                    RecapCard(plan: _plan),
                    const SizedBox(height: AppDimens.lg),
                    Text(
                      'Les données de carte sont traitées par le prestataire de paiement. SPORA ne conserve pas votre CVC.',
                      style: AppTextStyles.body(),
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
                label: 'Payer ${_plan.price}',
                onPressed: () =>
                    context.push('/premium/3ds', extra: _plan),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Groups card digits by 4 (•••• •••• •••• ••••).
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > 16 ? digits.substring(0, 16) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < clipped.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(clipped[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Formats expiry as MM / AA.
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > 4 ? digits.substring(0, 4) : digits;
    var text = clipped;
    if (clipped.length > 2) {
      text = '${clipped.substring(0, 2)} / ${clipped.substring(2)}';
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
