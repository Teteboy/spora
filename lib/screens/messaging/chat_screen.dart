import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/messaging_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String participantName;
  final String? participantAvatar;
  final String participantRole;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.participantName,
    this.participantAvatar,
    required this.participantRole,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessagingProvider>().loadMessages(widget.conversationId);
    });
  }

  void _send() {
    if (_messageCtrl.text.trim().isEmpty) return;
    final auth = context.read<AuthProvider>();
    context.read<MessagingProvider>().sendMessage(
      widget.conversationId,
      _messageCtrl.text.trim(),
      auth.currentUser?.id ?? 'user_1',
      auth.currentUser?.name ?? 'Moi',
    );
    _messageCtrl.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(widget.participantAvatar ?? 'https://i.pravatar.cc/60?u=${widget.conversationId}'),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.participantName, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text(widget.participantRole, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.primary)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert, color: AppColors.textPrimary), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MessagingProvider>(
              builder: (context, provider, _) {
                final auth = context.read<AuthProvider>();
                final myId = auth.currentUser?.id ?? 'user_1';
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.currentMessages.length,
                  itemBuilder: (context, i) {
                    final msg = provider.currentMessages[i];
                    final isMe = msg.senderId == myId;
                    return _MessageBubble(
                      content: msg.content,
                      isMe: isMe,
                      senderName: msg.senderName,
                      time: msg.sentAt,
                    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, duration: 200.ms);
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, -2))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(24)),
                      child: TextField(
                        controller: _messageCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Écrivez un message...',
                          hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textHint),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: AppColors.primaryGradient),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String content;
  final bool isMe;
  final String senderName;
  final DateTime time;

  const _MessageBubble({required this.content, required this.isMe, required this.senderName, required this.time});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4, offset: const Offset(0, 1))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(content, style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: isMe ? Colors.white : AppColors.textPrimary, height: 1.4)),
            const SizedBox(height: 4),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: isMe ? Colors.white60 : AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}
