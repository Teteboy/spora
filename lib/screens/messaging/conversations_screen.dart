import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../providers/messaging_provider.dart';
import '../../core/theme/app_colors.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessagingProvider>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        title: const Text('Messages', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<MessagingProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (provider.conversations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 60, color: AppColors.textHint),
                  SizedBox(height: 12),
                  Text('Aucun message', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.conversations.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider, indent: 76),
            itemBuilder: (context, i) {
              final conv = provider.conversations[i];
              return ListTile(
                onTap: () => context.push('/chat/${conv.id}', extra: {
                  'name': conv.participantName,
                  'avatar': conv.participantAvatar,
                  'role': conv.participantRole,
                }),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundImage: NetworkImage(conv.participantAvatar ?? 'https://i.pravatar.cc/60?u=${conv.participantId}'),
                    ),
                    if (conv.unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text('${conv.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                        ),
                      ),
                  ],
                ),
                title: Text(
                  conv.participantName,
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: conv.unreadCount > 0 ? FontWeight.w700 : FontWeight.w500, color: AppColors.textPrimary),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(conv.participantRole, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.primary)),
                    const SizedBox(height: 2),
                    Text(conv.lastMessage, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: conv.unreadCount > 0 ? AppColors.textPrimary : AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
                trailing: Text(
                  timeago.format(conv.lastMessageTime, locale: 'fr'),
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: i * 50));
            },
          );
        },
      ),
    );
  }
}
