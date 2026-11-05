import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/notification_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Notifications centre — frames "Notifications" & "Notifications — Vide".
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final List<AppNotification> _notifs = [
    AppNotification(
      id: 'n1',
      title: 'Nouveau message',
      body: 'Académie des Rives · Il y a 5 min',
      type: AppNotificationType.newMessage,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      targetRoute: '/chat/c1',
    ),
    AppNotification(
      id: 'n2',
      title: 'Votre vidéo est validée',
      body: 'Votre highlight est maintenant en ligne · 09:00',
      type: AppNotificationType.videoValidated,
      createdAt: DateTime.now().subtract(const Duration(minutes: 41)),
      targetRoute: '/highlights/mine',
    ),
    AppNotification(
      id: 'n3',
      title: 'Votre profil a été consulté',
      body: 'Horizon Talent · Il y a 2 h',
      type: AppNotificationType.profileView,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      targetRoute: '/profile-views',
    ),
    AppNotification(
      id: 'n4',
      title: 'Kevin aime votre vidéo',
      body: 'Frappe depuis l’extérieur · Il y a 3 h',
      type: AppNotificationType.videoLike,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      targetRoute: '/highlights',
    ),
    AppNotification(
      id: 'n5',
      title: 'Une opportunité correspond à votre profil',
      body: 'Détection U21 · Douala · Exemple fictif',
      type: AppNotificationType.opportunityMatch,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      targetRoute: '/opportunities',
    ),
    AppNotification(
      id: 'n6',
      title: 'Une vidéo nécessite une correction',
      body: 'Image trop sombre · Voir le motif',
      type: AppNotificationType.videoRejected,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      targetRoute: '/highlights/mine',
    ),
    AppNotification(
      id: 'n7',
      title: 'Découvrez SPORA Premium',
      body: 'Highlights illimités et statistiques détaillées',
      type: AppNotificationType.premiumPromo,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
      targetRoute: '/premium',
    ),
  ];

  int get _unread => _notifs.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      for (var i = 0; i < _notifs.length; i++) {
        _notifs[i] = _notifs[i].copyWith(isRead: true);
      }
    });
  }

  void _open(AppNotification n) {
    setState(() {
      final i = _notifs.indexWhere((e) => e.id == n.id);
      if (i != -1) _notifs[i] = _notifs[i].copyWith(isRead: true);
    });
    if (n.targetRoute != null) context.push(n.targetRoute!);
  }

  @override
  Widget build(BuildContext context) {
    final today = _notifs
        .where((n) => DateTime.now().difference(n.createdAt).inHours < 24)
        .toList();
    final week = _notifs
        .where((n) => DateTime.now().difference(n.createdAt).inHours >= 24)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.screenMargin, vertical: AppDimens.lg),
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: AppDimens.minTouch,
                    height: AppDimens.minTouch,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusInput),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(LucideIcons.arrowLeft,
                        size: 22, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: AppDimens.md),
                Text('Notifications', style: AppTextStyles.h1()),
              ],
            ),
            const SizedBox(height: AppDimens.section),

            if (_notifs.isEmpty)
              _emptyState()
            else ...[
              // Mark all read
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _unread > 0 ? _markAllRead : null,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusCard)),
                  ),
                  child: Text('Tout marquer comme lu',
                      style: AppTextStyles.button(color: AppColors.primary)),
                ),
              ),
              const SizedBox(height: AppDimens.lg),

              // Enable notifications banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimens.cardPadding),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusCard),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Activer les notifications',
                        style:
                            AppTextStyles.bodyStrong(color: AppColors.primary)),
                    const SizedBox(height: AppDimens.xs),
                    Text(
                        'Recevez les nouvelles importantes pour votre parcours.',
                        style:
                            AppTextStyles.body(color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusCard)),
                  ),
                  child: Text('Autoriser les notifications',
                      style: AppTextStyles.button(
                          color: AppColors.textPrimary)),
                ),
              ),
              const SizedBox(height: AppDimens.section),

              if (today.isNotEmpty) ...[
                Text('Aujourd’hui', style: AppTextStyles.h1()),
                const SizedBox(height: AppDimens.md),
                _groupCard(today),
                const SizedBox(height: AppDimens.section),
              ],
              if (week.isNotEmpty) ...[
                Text('Cette semaine', style: AppTextStyles.h1()),
                const SizedBox(height: AppDimens.md),
                _groupCard(week),
              ],
            ],
            const SizedBox(height: AppDimens.section),
          ],
        ),
      ),
    );
  }

  Widget _groupCard(List<AppNotification> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _row(items[i]),
            if (i != items.length - 1)
              const Divider(
                  height: 1, color: AppColors.divider, indent: 16, endIndent: 16),
          ],
        ],
      ),
    );
  }

  Widget _row(AppNotification n) {
    return InkWell(
      onTap: () => _open(n),
      borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.cardPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_icon(n.type), size: 24, color: AppColors.primary),
            const SizedBox(width: AppDimens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n.title,
                      style: n.isRead
                          ? AppTextStyles.body(color: AppColors.textPrimary)
                          : AppTextStyles.bodyStrong()),
                  const SizedBox(height: AppDimens.xxs),
                  Text(n.body, style: AppTextStyles.body()),
                ],
              ),
            ),
            if (!n.isRead)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusPill),
                ),
                child: Text('Non lu',
                    style: AppTextStyles.caption(color: AppColors.primary)),
              ),
          ],
        ),
      ),
    );
  }

  IconData _icon(AppNotificationType t) {
    switch (t) {
      case AppNotificationType.newMessage:
        return LucideIcons.messageCircle;
      case AppNotificationType.profileView:
        return LucideIcons.eye;
      case AppNotificationType.videoLike:
        return LucideIcons.heart;
      case AppNotificationType.videoValidated:
        return LucideIcons.checkCircle;
      case AppNotificationType.videoRejected:
        return LucideIcons.alertCircle;
      case AppNotificationType.opportunityMatch:
        return LucideIcons.briefcase;
      case AppNotificationType.applicationStatus:
        return LucideIcons.clipboardCheck;
      case AppNotificationType.newFollower:
        return LucideIcons.userPlus;
      case AppNotificationType.premiumPromo:
        return LucideIcons.crown;
      case AppNotificationType.system:
        return LucideIcons.info;
    }
  }

  Widget _emptyState() {
    return Column(
      children: [
        const SizedBox(height: AppDimens.huge),
        Container(
          width: 160,
          height: 160,
          decoration: const BoxDecoration(
            color: AppColors.primaryTint,
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.bell,
              size: 72, color: AppColors.primary),
        ),
        const SizedBox(height: AppDimens.xxl),
        Text('Tout est à jour', style: AppTextStyles.h1()),
        const SizedBox(height: AppDimens.md),
        Text(
          'Vos messages, les vues de votre profil et les nouvelles opportunités apparaîtront ici.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppDimens.huge),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimens.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusCard),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Activer les notifications', style: AppTextStyles.h2()),
              const SizedBox(height: AppDimens.sm),
              Text(
                'Recevez les nouvelles importantes pour votre parcours, sans manquer un message d’un recruteur.',
                style: AppTextStyles.body(),
              ),
              const SizedBox(height: AppDimens.lg),
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: AppColors.primaryGradient),
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusCard),
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusCard)),
                    ),
                    child: Text('Autoriser les notifications',
                        style: AppTextStyles.button()),
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.md),
              Center(
                child: Text('Plus tard',
                    style:
                        AppTextStyles.bodyStrong(color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
