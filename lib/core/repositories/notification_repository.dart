import 'dart:ui';
import 'package:flutter/material.dart';

import '../models/notification.dart';
import '../theme/app_colors.dart';

// ──────────────────────────────────────────────────────────────────────────────
// NOTIFICATION REPOSITORY
// ──────────────────────────────────────────────────────────────────────────────

abstract class NotificationRepository {
  List<AppNotification> getNotifications();
  List<String> get filterLabels;
  List<String> get groupOrder;
}

class MockNotificationRepository implements NotificationRepository {
  @override
  List<String> get filterLabels =>
      const ['All', 'Unread', 'Events', 'Sermons', 'Prayer', 'Giving'];

  @override
  List<String> get groupOrder =>
      const ['Today', 'Yesterday', 'This Week', 'Earlier'];

  @override
  List<AppNotification> getNotifications() => [
        AppNotification(
          id: 'n1',
          type: NotificationType.live,
          icon: Icons.live_tv_rounded,
          color: const Color(0xFFEF4444),
          title: 'Sunday Service is Live!',
          body:
              'Join the live stream now. Worship has started with the praise team.',
          time: '2 min ago',
          group: 'Today',
          actionLabel: 'Watch Now',
        ),
        AppNotification(
          id: 'n2',
          type: NotificationType.event,
          icon: Icons.event_outlined,
          color: AppColors.primary,
          title: 'Worship Conference Tomorrow',
          body:
              'The annual worship conference starts at 10:00 AM. Do not forget your ticket!',
          time: '1 hour ago',
          group: 'Today',
          actionLabel: 'View Event',
        ),
        const AppNotification(
          id: 'n3',
          type: NotificationType.prayer,
          icon: Icons.favorite_rounded,
          color: Color(0xFFEC4899),
          title: '12 people prayed for you',
          body:
              'Your prayer request "Healing for my mother" received 12 new prayers from the community.',
          time: '3 hours ago',
          group: 'Today',
          actionLabel: 'View Prayers',
        ),
        const AppNotification(
          id: 'n4',
          type: NotificationType.community,
          icon: Icons.forum_outlined,
          color: Color(0xFF6366F1),
          title: 'New reply on your thread',
          body:
              'Pastor James replied to "Please pray for healing" in the Forum.',
          time: '4 hours ago',
          group: 'Today',
        ),
        const AppNotification(
          id: 'n5',
          type: NotificationType.group,
          icon: Icons.groups_outlined,
          color: Color(0xFFF59E0B),
          title: 'Small group meeting moved',
          body:
              'Young Adults group meeting changed to Thursday at 7 PM this week.',
          time: '5 hours ago',
          group: 'Today',
        ),
        const AppNotification(
          id: 'n6',
          type: NotificationType.sermon,
          icon: Icons.headphones_outlined,
          color: Color(0xFF3B82F6),
          title: 'New Sermon Available',
          body:
              '"The Power of Faith" by Pastor James is now available to watch and listen.',
          time: 'Yesterday',
          group: 'Yesterday',
          actionLabel: 'Listen',
          isRead: true,
        ),
        const AppNotification(
          id: 'n7',
          type: NotificationType.giving,
          icon: Icons.volunteer_activism_outlined,
          color: Color(0xFF059669),
          title: 'Thank you for your generosity!',
          body:
              'Your tithe of \$250.00 was received and processed. A receipt has been emailed.',
          time: 'Yesterday',
          group: 'Yesterday',
          actionLabel: 'View Receipt',
          isRead: true,
        ),
        const AppNotification(
          id: 'n8',
          type: NotificationType.volunteer,
          icon: Icons.handshake_outlined,
          color: Color(0xFF8B5CF6),
          title: 'You are scheduled to serve',
          body:
              'Reminder: You are on the Welcome Team this Sunday at 9:00 AM.',
          time: 'Yesterday',
          group: 'Yesterday',
        ),
        const AppNotification(
          id: 'n9',
          type: NotificationType.event,
          icon: Icons.celebration_outlined,
          color: Color(0xFFF59E0B),
          title: 'Marriage Retreat registration open',
          body:
              'Sign up for the couples retreat Mar 21-22 at Mountain Lodge. Limited spots!',
          time: '3 days ago',
          group: 'This Week',
          actionLabel: 'Register',
          isRead: true,
        ),
        const AppNotification(
          id: 'n10',
          type: NotificationType.prayer,
          icon: Icons.favorite_border_rounded,
          color: Color(0xFFEC4899),
          title: 'Prayer answered!',
          body:
              'David K. updated his prayer request as answered. Rejoice with the community!',
          time: '4 days ago',
          group: 'This Week',
          isRead: true,
        ),
        const AppNotification(
          id: 'n11',
          type: NotificationType.sermon,
          icon: Icons.playlist_play_outlined,
          color: Color(0xFF3B82F6),
          title: 'New Series: Unshakeable Faith',
          body:
              'A new 6-part sermon series has started. Catch up on episode 1.',
          time: '1 week ago',
          group: 'Earlier',
          isRead: true,
        ),
        const AppNotification(
          id: 'n12',
          type: NotificationType.general,
          icon: Icons.campaign_outlined,
          color: Color(0xFF64748B),
          title: 'Church app update available',
          body:
              'Version 1.1 includes new features: Forum, Chat, and improved search.',
          time: '2 weeks ago',
          group: 'Earlier',
          isRead: true,
        ),
      ];
}
