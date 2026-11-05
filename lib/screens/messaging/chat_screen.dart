import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Chat — frames "Conversation", "Conversation — Mineur", "Conversation — Échec envoi".
class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String participantName;
  final String? participantAvatar;
  final String participantRole;

  /// Protection des mineurs: shows the safety banners (frame "Conversation — Mineur").
  final bool isMinor;

  /// Non-verified counterparts cannot receive messages.
  final bool participantVerified;

  /// Demo hook to render the "Échec de l'envoi" state on next send.
  final bool simulateFailure;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.participantName,
    this.participantAvatar,
    required this.participantRole,
    this.isMinor = false,
    this.participantVerified = true,
    this.simulateFailure = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _blocked = false;

  late final List<_ChatMsg> _messages = [
    _ChatMsg(
      text:
          'Bonjour Jordan, votre dernier highlight a retenu notre attention. Votre profil nous intéresse pour notre détection U21 à Douala.',
      isMe: false,
      time: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    _ChatMsg(
      text:
          'Bonjour, merci pour votre message ! Je suis intéressé. Quelles sont les dates et les modalités ?',
      isMe: true,
      time: DateTime.now().subtract(const Duration(minutes: 26)),
      status: _MsgStatus.read,
    ),
    _ChatMsg(opportunity: true, isMe: false,
        time: DateTime.now().subtract(const Duration(minutes: 24))),
    _ChatMsg(
      text:
          'Les 14 et 15 novembre. Vous pouvez consulter les critères et postuler depuis cette fiche. Nous restons à votre écoute.',
      isMe: false,
      time: DateTime.now().subtract(const Duration(minutes: 23)),
    ),
    _ChatMsg(
      text: 'Parfait, je vais préparer ma candidature. Merci !',
      isMe: true,
      time: DateTime.now().subtract(const Duration(minutes: 21)),
      status: _MsgStatus.read,
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty || text.length > 2000) return;
    setState(() {
      _messages.add(_ChatMsg(
        text: text,
        isMe: true,
        time: DateTime.now(),
        status: widget.simulateFailure ? _MsgStatus.failed : _MsgStatus.sent,
      ));
    });
    _ctrl.clear();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
    // Simulate delivery → read progression for demo.
    if (!widget.simulateFailure) {
      final msg = _messages.last;
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && msg.status == _MsgStatus.sent) {
          setState(() => msg.status = _MsgStatus.delivered);
        }
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && msg.status == _MsgStatus.delivered) {
          setState(() => msg.status = _MsgStatus.read);
        }
      });
    }
  }

  void _retry(_ChatMsg m) {
    setState(() => m.status = _MsgStatus.sent);
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.participantRole;
    final isClub = role.toLowerCase().contains('club');

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.screenMargin, vertical: AppDimens.sm),
              child: Row(
                children: [
                  _circleButton(LucideIcons.arrowLeft, () => context.pop()),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: Text(widget.participantName,
                        style: AppTextStyles.h1(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(LucideIcons.moreVertical,
                        color: AppColors.textPrimary),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusCard)),
                    onSelected: (v) {
                      switch (v) {
                        case 'profile':
                          break;
                        case 'report':
                          context.push('/report');
                          break;
                        case 'block':
                          setState(() => _blocked = true);
                          break;
                      }
                    },
                    itemBuilder: (_) => [
                      _menuItem('profile', LucideIcons.user, 'Voir le profil'),
                      _menuItem('report', LucideIcons.flag, 'Signaler'),
                      _menuItem('block', LucideIcons.ban, 'Bloquer'),
                    ],
                  ),
                ],
              ),
            ),

            // Participant info card
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.screenMargin),
              child: Row(
                children: [
                  _participantAvatar(isClub),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            isClub
                                ? 'Éric N. · Responsable recrutement'
                                : widget.participantName,
                            style: AppTextStyles.bodyStrong(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(
                          widget.participantVerified
                              ? 'En ligne · $role vérifié'
                              : role,
                          style: AppTextStyles.caption(
                              color: widget.participantVerified
                                  ? AppColors.clubGreen
                                  : AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  if (widget.participantVerified)
                    const Icon(LucideIcons.badgeCheck,
                        color: AppColors.primary, size: 24),
                ],
              ),
            ),

            // Minor-protection banner
            if (widget.isMinor)
              _infoBanner(
                'Pour votre sécurité, ne partagez pas vos coordonnées personnelles.\nÉchange réservé aux recruteurs vérifiés. Votre tuteur reste votre référent.',
              ),

            const SizedBox(height: AppDimens.sm),

            // Messages
            Expanded(
              child: ListView(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.screenMargin),
                children: [
                  Center(
                    child: Text('Aujourd’hui · 16 octobre 2026',
                        style: AppTextStyles.caption()),
                  ),
                  const SizedBox(height: AppDimens.lg),
                  for (final m in _messages) ...[
                    if (m.opportunity)
                      _opportunityCard()
                    else
                      _bubble(m),
                    if (m.status == _MsgStatus.failed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppDimens.md),
                        child: GestureDetector(
                          onTap: () => _retry(m),
                          child: Text('Échec de l’envoi · Réessayer',
                              style:
                                  AppTextStyles.caption(color: AppColors.error)),
                        ),
                      ),
                  ],
                  if (widget.isMinor)
                    _infoBanner(
                      'Échange d’information uniquement\nCe joueur mineur n’est pas éligible à la détection U21 (18–21 ans). Tout projet doit être évalué avec son représentant légal.',
                    ),
                  const SizedBox(height: AppDimens.sm),
                ],
              ),
            ),

            // Composer / blocked state
            if (!widget.participantVerified)
              Padding(
                padding: const EdgeInsets.all(AppDimens.screenMargin),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimens.cardPadding),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusCard),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'Cet utilisateur ne peut pas recevoir de messages',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyStrong(),
                  ),
                ),
              )
            else if (_blocked)
              Padding(
                padding: const EdgeInsets.all(AppDimens.screenMargin),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimens.cardPadding),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusCard),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text('Utilisateur bloqué',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyStrong()),
                ),
              )
            else
              _composer(),

            // Footer links
            Padding(
              padding: const EdgeInsets.only(
                  bottom: AppDimens.sm, top: AppDimens.xs),
              child: Wrap(
                spacing: AppDimens.sm,
                children: [
                  _footerLink('Voir le profil', () {}),
                  Text('·', style: AppTextStyles.caption()),
                  _footerLink('Signaler', () => context.push('/report')),
                  Text('·', style: AppTextStyles.caption()),
                  _footerLink('Bloquer',
                      () => setState(() => _blocked = !_blocked)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String v, IconData icon, String label) {
    return PopupMenuItem(
      value: v,
      child: Row(children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: AppDimens.sm),
        Text(label, style: AppTextStyles.body()),
      ]),
    );
  }

  Widget _footerLink(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Text(label, style: AppTextStyles.caption()),
      );

  Widget _circleButton(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: AppDimens.minTouch,
          height: AppDimens.minTouch,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusInput),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      );

  String get _initials {
    final parts = widget.participantName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts[1][0]).toUpperCase();
  }

  /// Header avatar — green rounded-square shield for clubs,
  /// network photo with initials fallback otherwise.
  Widget _participantAvatar(bool isClub) {
    if (isClub) {
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.clubGreen.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppDimens.radiusInput),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.shield,
                color: AppColors.clubGreen, size: 20),
            Text(_initials,
                style: AppTextStyles.micro(color: AppColors.clubGreen)),
          ],
        ),
      );
    }
    final url = widget.participantAvatar ??
        'https://i.pravatar.cc/150?u=${widget.conversationId}';
    return ClipOval(
      child: Image.network(
        url,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _initialsCircle(),
        errorBuilder: (context, error, stack) => _initialsCircle(),
      ),
    );
  }

  Widget _initialsCircle() => Container(
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.primaryTint,
          shape: BoxShape.circle,
        ),
        child: Text(_initials,
            style: AppTextStyles.h3(color: AppColors.primary)),
      );

  Widget _infoBanner(String text) => Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(
            horizontal: AppDimens.screenMargin, vertical: AppDimens.sm),
        padding: const EdgeInsets.all(AppDimens.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.primaryTint,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        ),
        child: Text(text, style: AppTextStyles.bodyStrong(color: AppColors.primary)),
      );

  Widget _bubble(_ChatMsg m) {
    final failed = m.status == _MsgStatus.failed;
    return Align(
      alignment: m.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimens.md),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.all(AppDimens.cardPadding),
        decoration: BoxDecoration(
          color: m.isMe ? null : AppColors.surface,
          gradient: m.isMe
              ? const LinearGradient(colors: AppColors.primaryGradient)
              : null,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          border: m.isMe ? null : Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: m.isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(m.text ?? '',
                style: AppTextStyles.body(
                    color: m.isMe ? AppColors.textLight : AppColors.textPrimary)),
            const SizedBox(height: AppDimens.xs),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _fmt(m.time) + _statusLabel(m),
                  style: AppTextStyles.micro(
                      color: m.isMe
                          ? AppColors.textLight.withValues(alpha: 0.8)
                          : AppColors.textMuted),
                ),
                if (m.isMe && !failed) ...[
                  const SizedBox(width: AppDimens.xs),
                  Icon(
                    m.status == _MsgStatus.read
                        ? LucideIcons.checkCheck
                        : m.status == _MsgStatus.delivered
                            ? LucideIcons.checkCheck
                            : LucideIcons.check,
                    size: 14,
                    color: AppColors.textLight.withValues(alpha: 0.8),
                  ),
                ],
                if (failed) ...[
                  const SizedBox(width: AppDimens.xs),
                  GestureDetector(
                    onTap: () => _retry(m),
                    child: Text('Réessayer',
                        style: AppTextStyles.micro(
                            color: AppColors.textLight.withValues(alpha: 0.9))),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(_ChatMsg m) {
    if (!m.isMe) return ' ·';
    switch (m.status) {
      case _MsgStatus.sent:
        return ' · Envoyé';
      case _MsgStatus.delivered:
        return ' · Reçu';
      case _MsgStatus.read:
        return ' · Lu';
      case _MsgStatus.failed:
        return ' · Non envoyé · ';
      case _MsgStatus.none:
        return '';
    }
  }

  Widget _opportunityCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=800&h=320&fit=crop&auto=format&q=80',
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : _opportunityImageFallback(),
            errorBuilder: (context, error, stack) =>
                _opportunityImageFallback(),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimens.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Académie des Rives · Détection',
                    style: AppTextStyles.caption(color: AppColors.clubGreen)),
                const SizedBox(height: AppDimens.xs),
                Text('Détection U21 · Douala', style: AppTextStyles.h2()),
                const SizedBox(height: AppDimens.xs),
                Text('14–15 novembre 2026 · 18–21 ans',
                    style: AppTextStyles.body()),
                const SizedBox(height: AppDimens.sm),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Text('Voir l’opportunité',
                          style: AppTextStyles.bodyStrong(
                              color: AppColors.primary)),
                      const Spacer(),
                      const Icon(LucideIcons.arrowUpRight,
                          size: 18, color: AppColors.primary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _opportunityImageFallback() => Container(
        height: 120,
        width: double.infinity,
        color: AppColors.clubGreen.withValues(alpha: 0.15),
        child: const Icon(LucideIcons.users,
            size: 48, color: AppColors.clubGreen),
      );

  Widget _composer() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.screenMargin, vertical: AppDimens.sm),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.paperclip,
                color: AppColors.textSecondary, size: 24),
          ),
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppDimens.lg),
              decoration: BoxDecoration(
                color: AppColors.appBg,
                borderRadius:
                    BorderRadius.circular(AppDimens.radiusPill),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _ctrl,
                maxLength: 2000,
                maxLines: null,
                style: AppTextStyles.body(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Votre réponse…',
                  hintStyle: AppTextStyles.body(color: AppColors.textMuted),
                  border: InputBorder.none,
                  counterText: '',
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: AppDimens.sm),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primaryGradient),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.send,
                  color: AppColors.textLight, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

enum _MsgStatus { none, sent, delivered, read, failed }

class _ChatMsg {
  final String? text;
  final bool isMe;
  final DateTime time;
  _MsgStatus status;
  final bool opportunity;

  _ChatMsg({
    this.text,
    required this.isMe,
    required this.time,
    this.status = _MsgStatus.none,
    this.opportunity = false,
  });
}
