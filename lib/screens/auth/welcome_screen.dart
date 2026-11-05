import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'auth_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}
class _WelcomeScreenState extends State<WelcomeScreen> {
  final _pages = PageController();
  int _index = 0;
  static const _titles = ['Montrez\nvotre talent', 'Trouvez le prochain talent', 'Soyez repéré'];
  static const _descriptions = ['Créez votre profil et publiez vos meilleures actions en vidéo.', 'Recherchez, comparez et contactez des joueurs vérifiés.', 'Les agents et les clubs découvrent votre profil partout dans le monde.'];
  @override
  void dispose() { _pages.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: AppColors.navy900, body: SafeArea(child: Column(children: [
    Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const AuthBrand(light: true), TextButton(onPressed: () => context.push('/role'), child: Text('Passer', style: AppTextStyles.body(color: AppColors.textLight)))])),
    Expanded(child: PageView.builder(controller: _pages, itemCount: 3, onPageChanged: (i) => setState(() => _index = i), itemBuilder: (context, i) => LayoutBuilder(builder: (context, constraints) => SingleChildScrollView(child: ConstrainedBox(constraints: BoxConstraints(minHeight: constraints.maxHeight), child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
      Padding(padding: const EdgeInsets.only(bottom: 32), child: Center(child: i == 0
        ? ClipRRect(borderRadius: BorderRadius.circular(32), child: Image.asset('assets/images/spora_icon.png', height: 140, width: 140, fit: BoxFit.cover))
        : const Icon(LucideIcons.goal, size: 120, color: AppColors.navy700))),
      Text('LE TALENT N’A PAS DE FRONTIÈRES.', style: AppTextStyles.eyebrow(color: AppColors.primaryTint)), const SizedBox(height: 20),
      Text(_titles[i], style: AppTextStyles.display(color: AppColors.textLight).copyWith(fontSize: i == 0 ? 34 : 28)), const SizedBox(height: 20),
      Text(_descriptions[i], style: AppTextStyles.bodyLarge(color: AppColors.darkTextSecondary)),
    ]))))))),
    Padding(padding: const EdgeInsets.fromLTRB(24, 4, 24, 24), child: Column(children: [
      Row(children: List.generate(3, (i) => AnimatedContainer(duration: const Duration(milliseconds: 200), width: i == _index ? 24 : 6, height: 6, margin: const EdgeInsets.only(right: 6), decoration: BoxDecoration(color: i == _index ? AppColors.primary : AppColors.surface, borderRadius: BorderRadius.circular(999))))), const SizedBox(height: 24),
      AuthButton(_index == 2 ? 'Commencer' : 'Suivant', onPressed: () { if (_index == 2) { context.push('/role'); } else { _pages.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOut); } }),
      const SizedBox(height: 16), Text('Première exploration — écrans clés', style: AppTextStyles.caption(color: AppColors.darkTextSecondary)),
      TextButton(onPressed: () => context.push('/invite'), child: Text('Vous avez un code d’invitation ?', style: AppTextStyles.body(color: AppColors.primaryTint))),
    ])),
  ])));
}
