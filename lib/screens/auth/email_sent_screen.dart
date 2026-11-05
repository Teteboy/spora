import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'auth_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EmailSentScreen extends StatefulWidget {
  const EmailSentScreen({super.key, this.email});
  final String? email;
  @override
  State<EmailSentScreen> createState() => _EmailSentScreenState();
}
class _EmailSentScreenState extends State<EmailSentScreen> {
  int _seconds = 30;
  Timer? _timer;
  @override
  void initState() { super.initState(); _timer = Timer.periodic(const Duration(seconds: 1), (_) { if (_seconds > 0) setState(() => _seconds--); }); }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    final email = widget.email ?? (extra is String ? extra : 'jordan.mbala@email.com');
    return AuthPage(title: 'Votre compte', bottom: AuthButton('Ouvrir ma messagerie', onPressed: () => showDialog<void>(context: context, builder: (context) => AlertDialog(title: const Text('Consultez votre messagerie'), content: const Text('Ouvrez votre application e-mail et suivez le lien reçu. Pour cette démonstration, vous pouvez continuer ici.'), actions: [TextButton(onPressed: () { Navigator.of(context).pop(); this.context.push('/reset-password'); }, child: const Text('Continuer'))]))), children: [
      AuthHero(icon: LucideIcons.mailCheck, title: 'Vérifiez votre boîte mail', description: 'Un lien a été envoyé à $email. Pensez à vérifier les courriers indésirables.'),
      if (_seconds > 0) AuthNotice('Renvoyer l’e-mail dans 00:${_seconds.toString().padLeft(2, '0')}\nVous pourrez demander un nouveau lien après ce délai.') else AuthButton('Renvoyer l’e-mail', secondary: true, onPressed: () => setState(() => _seconds = 30)),
    ]);
  }
}
