import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../providers/messaging_provider.dart';
import '../../models/message_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        title: const Text('Notifications', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<MessagingProvider>(
        builder: (context, provider, _) {
          final notifications = provider.notifications;
          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 60, color: AppColors.textHint),
                  SizedBox(height: 12),
                  Text('Aucune notification', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppConstants.spacingMD),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final notif = notifications[i];
              return GestureDetector(
                onTap: () => provider.markNotificationRead(notif.id),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: notif.isRead ? Colors.white : AppColors.primary.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                    border: Border.all(color: notif.isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _notifColor(notif.type).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_notifIcon(notif.type), color: _notifColor(notif.type), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notif.title, style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700, color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text(notif.body, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Text(timeago.format(notif.createdAt, locale: 'fr'), style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.textHint)),
                          ],
                        ),
                      ),
                      if (!notif.isRead)
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle)),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: i * 50)),
              );
            },
          );
        },
      ),
    );
  }

  IconData _notifIcon(NotificationType type) {
    switch (type) {
      case NotificationType.message: return Icons.message_outlined;
      case NotificationType.profileView: return Icons.visibility_outlined;
      case NotificationType.videoLike: return Icons.favorite_outline;
      case NotificationType.newFollower: return Icons.person_add_outlined;
      case NotificationType.subscriptionExpiry: return Icons.card_membership;
      case NotificationType.system: return Icons.info_outline;
    }
  }

  Color _notifColor(NotificationType type) {
    switch (type) {
      case NotificationType.message: return AppColors.primaryLight;
      case NotificationType.profileView: return AppColors.success;
      case NotificationType.videoLike: return AppColors.error;
      case NotificationType.newFollower: return AppColors.gold;
      case NotificationType.subscriptionExpiry: return AppColors.warning;
      case NotificationType.system: return AppColors.textSecondary;
    }
  }
}

