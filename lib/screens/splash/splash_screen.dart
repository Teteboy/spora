import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../auth/auth_ui.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  @override
  void initState() { super.initState(); _timer = Timer(const Duration(seconds: 2), () { if (mounted) context.go('/welcome'); }); }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(body: Container(
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.navy900, AppColors.navy700])),
    child: SafeArea(child: Stack(children: [
      Center(child: Padding(padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, children: [
        ClipRRect(borderRadius: BorderRadius.circular(28), child: Image.asset('assets/images/spora_icon.png', height: 128, width: 128, fit: BoxFit.cover)), const SizedBox(height: 32), const AuthBrand(light: true), const SizedBox(height: 28),
        Text('La plateforme des talents du football', textAlign: TextAlign.center, style: AppTextStyles.body(color: AppColors.textLight)),
      ]))),
      Positioned(bottom: 80, left: 0, right: 0, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i) => Container(width: 8, height: 8, margin: const EdgeInsets.all(4), decoration: BoxDecoration(shape: BoxShape.circle, color: i == 0 ? AppColors.primary : AppColors.navy700))))),
    ])),
  ));
}
