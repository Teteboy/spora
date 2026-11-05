import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/spora_images.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/spora_logo.dart';
import '../../providers/messaging_provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Bordered icon tile used in the top bar (Figma header pattern, 44 px).
Widget _headerTile(IconData icon, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: AppDimens.minTouch,
      height: AppDimens.minTouch,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusInput),
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon, size: 26, color: AppColors.textPrimary),
    ),
  );
}

class RecruiterMessagesScreen extends StatelessWidget {
  const RecruiterMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.backgroundLight,
            floating: true,
            pinned: false,
            elevation: 0,
            title: Row(
              children: [
                const SporaLogo(height: 24, flat: true),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'CLUB',
                    style: TextStyle(
                      fontFamily: 'TikTok Sans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Consumer<MessagingProvider>(
                builder: (context, msg, _) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: badges.Badge(
                      showBadge: msg.unreadNotifications > 0,
                      badgeContent: Text(
                        '${msg.unreadNotifications}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 9),
                      ),
                      badgeStyle:
                          const badges.BadgeStyle(badgeColor: AppColors.danger),
                      child: _headerTile(LucideIcons.bell,
                          () => context.push('/notifications')),
                    ),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row
                  Consumer<MessagingProvider>(
                    builder: (context, msg, _) => Row(
                      children: [
                        Expanded(
                            child: _buildQuickStat(
                                '${msg.conversations.length}',
                                'Messages',
                                LucideIcons.messageSquare,
                                AppColors.primary)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildQuickStat(
                                '${msg.unreadCount}',
                                'Non lus',
                                LucideIcons.mail,
                                AppColors.primary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Conversations',
                    style: TextStyle(
                      fontFamily: 'TikTok Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          Consumer<MessagingProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final conversations = provider.conversations;

              if (conversations.isEmpty) {
                return SliverFillRemaining(child: _buildEmptyState());
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final conversation = conversations[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingMD, vertical: 6),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundImage: NetworkImage(
                                    conversation.participantAvatar ??
                                        sporaImage(conversation.id,
                                            w: 128, h: 128)),
                              ),
                              if (conversation.unreadCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${conversation.unreadCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(
                            conversation.participantName,
                            style: TextStyle(
                              fontFamily: 'TikTok Sans',
                              fontWeight: conversation.unreadCount > 0
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                conversation.lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'TikTok Sans',
                                  fontSize: 13,
                                  color: conversation.unreadCount > 0
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  conversation.participantRole,
                                  style: const TextStyle(
                                    fontFamily: 'TikTok Sans',
                                    fontSize: 10,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatTime(conversation.lastMessageTime),
                                style: const TextStyle(
                                  fontFamily: 'TikTok Sans',
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => context.push(
                            '/chat/${conversation.id}',
                            extra: {
                              'name': conversation.participantName,
                              'avatar': conversation.participantAvatar ??
                                  sporaImage(conversation.id, w: 128, h: 128),
                              'role': conversation.participantRole,
                            },
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: (index * 50).ms);
                  },
                  childCount: conversations.length,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.screenMargin, vertical: AppDimens.huge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: const BoxDecoration(
              color: AppColors.primaryTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.messageCircleOff,
                size: 64, color: AppColors.primary),
          ),
          const SizedBox(height: AppDimens.xxl),
          Text('Aucun message', style: AppTextStyles.h1()),
          const SizedBox(height: AppDimens.md),
          Text(
            'Vos conversations apparaîtront ici.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(
      String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'TikTok Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'TikTok Sans',
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 0) return '${diff.inDays}j';
    if (diff.inHours > 0) return '${diff.inHours}h';
    return '${diff.inMinutes}m';
  }
}
