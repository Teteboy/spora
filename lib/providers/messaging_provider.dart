import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../data/mock_data.dart';

class MessagingProvider extends ChangeNotifier {
  List<ConversationModel> _conversations = [];
  List<NotificationModel> _notifications = [];
  List<MessageModel> _currentMessages = [];
  bool _isLoading = false;

  List<ConversationModel> get conversations => _conversations;
  List<NotificationModel> get notifications => _notifications;
  List<MessageModel> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;

  int get unreadCount => _conversations.fold(0, (sum, c) => sum + c.unreadCount);
  int get unreadNotifications => _notifications.where((n) => !n.isRead).length;

  Future<void> loadConversations() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    _conversations = MockData.conversations;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadNotifications() async {
    _notifications = MockData.notifications;
    notifyListeners();
  }

  Future<void> loadMessages(String conversationId) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));
    _currentMessages = [
      MessageModel(
        id: 'm1',
        senderId: 'a1',
        senderName: 'Marc Dupont',
        receiverId: 'user_1',
        content: 'Bonjour, j\'ai vu votre profil et je suis très impressionné par vos performances!',
        sentAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
      ),
      MessageModel(
        id: 'm2',
        senderId: 'user_1',
        senderName: 'Louka Dubois',
        receiverId: 'a1',
        content: 'Bonjour Marc, merci! Je suis intéressé d\'en savoir plus.',
        sentAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      MessageModel(
        id: 'm3',
        senderId: 'a1',
        senderName: 'Marc Dupont',
        receiverId: 'user_1',
        content: 'J\'aimerais vous proposer une opportunité avec un club de Division 1. Êtes-vous disponible pour un appel cette semaine?',
        sentAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      ),
    ];
    _isLoading = false;
    notifyListeners();
  }

  void sendMessage(String conversationId, String content, String senderId, String senderName) {
    final message = MessageModel(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      senderName: senderName,
      receiverId: conversationId,
      content: content,
      sentAt: DateTime.now(),
      isRead: false,
    );
    _currentMessages.add(message);
    notifyListeners();
  }

  void markNotificationRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = NotificationModel(
        id: _notifications[idx].id,
        title: _notifications[idx].title,
        body: _notifications[idx].body,
        type: _notifications[idx].type,
        createdAt: _notifications[idx].createdAt,
        isRead: true,
      );
      notifyListeners();
    }
  }
}
