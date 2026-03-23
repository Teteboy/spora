class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String receiverId;
  final String content;
  final DateTime sentAt;
  final bool isRead;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.receiverId,
    required this.content,
    required this.sentAt,
    this.isRead = false,
  });
}

class ConversationModel {
  final String id;
  final String participantId;
  final String participantName;
  final String? participantAvatar;
  final String participantRole;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  const ConversationModel({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.participantAvatar,
    required this.participantRole,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });
}

enum NotificationType {
  message,
  profileView,
  videoLike,
  newFollower,
  subscriptionExpiry,
  system,
}
