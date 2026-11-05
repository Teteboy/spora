/// Richer notification model for the redesigned Notifications centre.
///
/// The legacy [NotificationModel] in message_model.dart is kept untouched;
/// this model adds the extra types (video moderation, opportunity match,
/// application status) and a navigation target used by the new screen.
enum AppNotificationType {
  newMessage,
  profileView,
  videoLike,
  videoValidated,
  videoRejected,
  opportunityMatch,
  applicationStatus,
  newFollower,
  premiumPromo,
  system,
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final AppNotificationType type;
  final DateTime createdAt;
  final bool isRead;

  /// go_router location to push when the notification is tapped (optional).
  final String? targetRoute;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.targetRoute,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        body: body,
        type: type,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
        targetRoute: targetRoute,
      );
}
