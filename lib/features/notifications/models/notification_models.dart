enum NotificationTopic { schedule, vehicle, trip, unknown }

class WebSocketNotification {
  final NotificationTopic topic;
  final String message;
  final DateTime receivedAt;

  WebSocketNotification({
    required this.topic,
    required this.message,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  factory WebSocketNotification.fromJson(Map<String, dynamic> json) {
    final topicStr = (json['topic'] as String?)?.toLowerCase() ?? 'unknown';
    final topic = _parseNotificationTopic(topicStr);

    print('📬 [Notification] Parsed: topic=$topicStr ($topic), message=${json['message']}');

    return WebSocketNotification(
      topic: topic,
      message: json['message'] as String? ?? '',
    );
  }

  static NotificationTopic _parseNotificationTopic(String topic) {
    switch (topic) {
      case 'schedule':
        return NotificationTopic.schedule;
      case 'vehicle':
        return NotificationTopic.vehicle;
      case 'trip':
        return NotificationTopic.trip;
      default:
        return NotificationTopic.unknown;
    }
  }

  String get topicDisplayName {
    switch (topic) {
      case NotificationTopic.schedule:
        return 'Schedule';
      case NotificationTopic.vehicle:
        return 'Vehicle';
      case NotificationTopic.trip:
        return 'Trip';
      case NotificationTopic.unknown:
        return 'Notification';
    }
  }

  String get topicEmoji {
    switch (topic) {
      case NotificationTopic.schedule:
        return '📅';
      case NotificationTopic.vehicle:
        return '🚌';
      case NotificationTopic.trip:
        return '🚗';
      case NotificationTopic.unknown:
        return '📬';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'topic': topicDisplayName,
      'message': message,
      'receivedAt': receivedAt.toIso8601String(),
    };
  }
}

class NotificationDisplayModel {
  final String id;
  final WebSocketNotification notification;
  final bool isRead;

  NotificationDisplayModel({
    required this.id,
    required this.notification,
    this.isRead = false,
  });

  NotificationDisplayModel copyWith({
    bool? isRead,
  }) {
    return NotificationDisplayModel(
      id: id,
      notification: notification,
      isRead: isRead ?? this.isRead,
    );
  }
}
