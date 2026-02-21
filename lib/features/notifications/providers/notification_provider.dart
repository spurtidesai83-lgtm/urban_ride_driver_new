import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_models.dart';
import '../services/notification_websocket_service.dart';

enum NotificationType { car, bell, star }

class LegacyNotificationModel {
  final NotificationType type;
  final String title;
  final String subtitle;
  final String time;
  final String date;

  LegacyNotificationModel({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.date,
  });
}

class NotificationState {
  final List<NotificationDisplayModel> notifications;
  final bool isConnected;
  final int unreadCount;

  NotificationState({
    this.notifications = const [],
    this.isConnected = false,
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    List<NotificationDisplayModel>? notifications,
    bool? isConnected,
    int? unreadCount,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isConnected: isConnected ?? this.isConnected,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationWebSocketService _wsService = notificationWebSocketService;
  static const _uuid = Uuid();

  NotificationNotifier() : super(NotificationState()) {
    _initializeWebSocket();
  }

  void _initializeWebSocket() async {
    print('📬 [NotificationProvider] Initializing WebSocket');

    // Connect to WebSocket
    await _wsService.connect();

    // Listen to notification stream
    _wsService.notificationStream.listen(
      _onNotificationReceived,
      onError: (error) {
        print('❌ [NotificationProvider] Stream error: $error');
      },
      onDone: () {
        print('📴 [NotificationProvider] Stream closed');
      },
    );

    // Update connection status
    _updateConnectionStatus();
  }

  void _updateConnectionStatus() {
    state = state.copyWith(isConnected: _wsService.isConnected);
  }

  void _onNotificationReceived(WebSocketNotification notification) {
    print('📨 [NotificationProvider] Received notification: ${notification.topicDisplayName}');

    final displayModel = NotificationDisplayModel(
      id: _uuid.v4(),
      notification: notification,
      isRead: false,
    );

    // Add to list (prepend to show latest first)
    final updatedNotifications = [displayModel, ...state.notifications];

    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: state.unreadCount + 1,
    );

    print('✅ [NotificationProvider] Notification added. Total: ${updatedNotifications.length}, Unread: ${state.unreadCount}');
  }

  void markAsRead(String notificationId) {
    print('👁️  [NotificationProvider] Marking as read: $notificationId');

    final updatedNotifications = state.notifications.map((n) {
      if (n.id == notificationId && !n.isRead) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    final newUnreadCount = updatedNotifications.where((n) => !n.isRead).length;

    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: newUnreadCount,
    );
  }

  void markAllAsRead() {
    print('👁️  [NotificationProvider] Marking all as read');

    final updatedNotifications = state.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();

    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: 0,
    );
  }

  void clearNotifications() {
    print('🗑️  [NotificationProvider] Clearing all notifications');
    state = state.copyWith(
      notifications: [],
      unreadCount: 0,
    );
  }

  void removeNotification(String notificationId) {
    print('❌ [NotificationProvider] Removing notification: $notificationId');

    final notification = state.notifications.firstWhere(
      (n) => n.id == notificationId,
      orElse: () => NotificationDisplayModel(
        id: '',
        notification: WebSocketNotification(topic: NotificationTopic.unknown, message: ''),
      ),
    );

    final updatedNotifications = state.notifications.where((n) => n.id != notificationId).toList();
    final newUnreadCount = notification.isRead ? state.unreadCount : state.unreadCount - 1;

    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: newUnreadCount,
    );
  }

  Future<void> reconnect() async {
    print('🔄 [NotificationProvider] Manual reconnection attempt');
    _wsService.disconnect();
    await Future.delayed(const Duration(seconds: 1));
    await _wsService.connect();
    _updateConnectionStatus();
  }

  @override
  void dispose() {
    print('🧹 [NotificationProvider] Disposing');
    _wsService.dispose();
    super.dispose();
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});

