import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/notification.dart';
import '../repositories/notification_repository.dart';

// ──────────────────────────────────────────────────────────────────────────────
// NOTIFICATION PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

final notificationRepositoryProvider =
    Provider<NotificationRepository>((_) {
  return MockNotificationRepository();
});

// ── State ────────────────────────────────────────────────────────────────────

class NotificationState {
  const NotificationState({
    this.notifications = const [],
    this.filterIndex = 0,
    this.filterLabels = const [],
    this.groupOrder = const [],
  });

  final List<AppNotification> notifications;
  final int filterIndex;
  final List<String> filterLabels;
  final List<String> groupOrder;

  NotificationState copyWith({
    List<AppNotification>? notifications,
    int? filterIndex,
    List<String>? filterLabels,
    List<String>? groupOrder,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      filterIndex: filterIndex ?? this.filterIndex,
      filterLabels: filterLabels ?? this.filterLabels,
      groupOrder: groupOrder ?? this.groupOrder,
    );
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  List<AppNotification> get filtered {
    switch (filterIndex) {
      case 1:
        return notifications.where((n) => !n.isRead).toList();
      case 2:
        return notifications
            .where((n) => n.type == NotificationType.event)
            .toList();
      case 3:
        return notifications
            .where((n) => n.type == NotificationType.sermon)
            .toList();
      case 4:
        return notifications
            .where((n) => n.type == NotificationType.prayer)
            .toList();
      case 5:
        return notifications
            .where((n) => n.type == NotificationType.giving)
            .toList();
      default:
        return notifications;
    }
  }

  Map<String, List<AppNotification>> get grouped {
    final map = <String, List<AppNotification>>{};
    for (final g in groupOrder) {
      final items = filtered.where((n) => n.group == g).toList();
      if (items.isNotEmpty) map[g] = items;
    }
    return map;
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier(this._repo) : super(const NotificationState()) {
    _init();
  }
  final NotificationRepository _repo;

  void _init() {
    state = state.copyWith(
      notifications: _repo.getNotifications(),
      filterLabels: _repo.filterLabels,
      groupOrder: _repo.groupOrder,
    );
  }

  void setFilter(int index) => state = state.copyWith(filterIndex: index);

  void markAsRead(String id) {
    final updated = state.notifications.map((n) {
      if (n.id == id) return n.copyWith(isRead: true);
      return n;
    }).toList();
    state = state.copyWith(notifications: updated);
  }

  void markAllAsRead() {
    final updated = state.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    state = state.copyWith(notifications: updated);
  }

  void dismiss(String id) {
    state = state.copyWith(
      notifications: state.notifications.where((n) => n.id != id).toList(),
    );
  }

  void undoDismiss(AppNotification notification, int index) {
    final list = List<AppNotification>.from(state.notifications);
    if (index >= list.length) {
      list.add(notification);
    } else {
      list.insert(index, notification);
    }
    state = state.copyWith(notifications: list);
  }
}

final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref.watch(notificationRepositoryProvider));
});
