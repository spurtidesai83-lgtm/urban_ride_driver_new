import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbandriver/shared/utils/responsive_utils.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../providers/notification_provider.dart';
import '../models/notification_models.dart';

class NotificationsScreen extends ConsumerWidget {
  final String phoneOrEmail;
  final VoidCallback? onMenuTap;

  const NotificationsScreen({
    super.key,
    required this.phoneOrEmail,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          CustomAppBar(
            title: 'My Notification',
            onMenuTap: onMenuTap,
          ),
          Expanded(
            child: notificationState.notifications.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: ResponsiveUtils.customPadding(context, top: 4, bottom: 100),
                    itemCount: notificationState.notifications.length,
                    itemBuilder: (context, index) {
                      final displayModel = notificationState.notifications[index];
                      return _buildNotificationItem(
                        context,
                        displayModel,
                        ref,
                        index == 0,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 60,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You will receive notifications here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationDisplayModel displayModel,
    WidgetRef ref,
    bool isFirst,
  ) {
    final notification = displayModel.notification;

    return GestureDetector(
      onTap: () {
        if (!displayModel.isRead) {
          ref.read(notificationProvider.notifier).markAsRead(displayModel.id);
        }
      },
      child: Column(
        children: [
          if (isFirst)
            Padding(
              padding: ResponsiveUtils.customPadding(context, left: 24, top: 20, right: 24, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'LATEST',
                  style: TextStyle(
                    color: const Color(0xFF6B7280),
                    fontSize: ResponsiveUtils.fontSize(context, 12),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          Container(
            padding: ResponsiveUtils.customPadding(context, left: 20, right: 20, top: 16, bottom: 16),
            decoration: BoxDecoration(
              color: displayModel.isRead ? Colors.white : const Color(0xFFFFF8E1),
              border: Border(
                left: BorderSide(
                  color: displayModel.isRead ? Colors.transparent : const Color(0xFFFFC200),
                  width: 4,
                ),
                bottom: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getTopicColor(notification.topic),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      notification.topicEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.topicDisplayName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTimeAgo(notification.receivedAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                // Unread indicator
                if (!displayModel.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFC200),
                      shape: BoxShape.circle,
                    ),
                  ),
                // Delete button
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Delete'),
                      onTap: () {
                        ref.read(notificationProvider.notifier).removeNotification(displayModel.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTopicColor(NotificationTopic topic) {
    switch (topic) {
      case NotificationTopic.schedule:
        return const Color(0xFFDEF6FF);
      case NotificationTopic.vehicle:
        return const Color(0xFFFFE8D6);
      case NotificationTopic.trip:
        return const Color(0xFFD1F2EB);
      case NotificationTopic.unknown:
        return const Color(0xFFF0F0F0);
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);

    if (duration.inSeconds < 60) {
      return 'Just now';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h ago';
    } else if (duration.inDays < 7) {
      return '${duration.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

