import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/notification.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/providers/notification_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_bars.dart';
import '../../shared/widgets/app_tap_animation.dart';
import '../../shared/widgets/common.dart';

/// ══════════════════════════════════════════════════════════════════════════════
/// NOTIFICATION CENTER SCREEN (Enhanced)
///
/// Features:
///   - Grouped by Today / Yesterday / This Week / Earlier
///   - Swipe to dismiss (Dismissible) with undo
///   - Unread dot + bold title for unread items
///   - Contextual action buttons per notification type
///   - Filter chips: All / Unread / Events / Sermons / Prayer / Giving
///   - Mark all read + clear all actions
///   - Notification count badge in header
///   - Empty state when no notifications
/// ══════════════════════════════════════════════════════════════════════════════

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends ConsumerState<NotificationCenterScreen> {

  void _markRead(AppNotification n) {
    ref.read(notificationNotifierProvider.notifier).markAsRead(n.id);
    switch (n.type) {
      case NotificationType.live:
        context.push(AppRoutes.live);
      case NotificationType.event:
        context.push('/events/1');
      case NotificationType.prayer:
        context.push(AppRoutes.prayerRequests);
      case NotificationType.sermon:
        context.push('/sermons/1');
      case NotificationType.giving:
        context.push(AppRoutes.givingHistory);
      case NotificationType.community:
        context.push(AppRoutes.forum);
      case NotificationType.group:
        context.push('/connect-groups/1');
      case NotificationType.volunteer:
        context.push(AppRoutes.volunteer);
      case NotificationType.general:
        break;
    }
  }

  void _markAllRead() {
    ref.read(notificationNotifierProvider.notifier).markAllAsRead();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _dismiss(AppNotification n) {
    final nState = ref.read(notificationNotifierProvider);
    final idx = nState.notifications.indexOf(n);
    ref.read(notificationNotifierProvider.notifier).dismiss(n.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification dismissed'),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.primaryLight,
          onPressed: () {
            ref.read(notificationNotifierProvider.notifier).undoDismiss(n, idx);
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nState = ref.watch(notificationNotifierProvider);
    final groups = nState.grouped;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Notifications',
        showBack: true,
        actions: [
          if (nState.unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'Mark all read',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Unread badge + filter chips ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sp4, AppSpacing.sp3, AppSpacing.sp4, 0,
            ),
            child: Column(
              children: [
                if (nState.unreadCount > 0)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: AppSpacing.sp3),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sp4,
                      vertical: AppSpacing.sp2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary
                          .withValues(alpha: isDark ? 0.15 : 0.08),
                      borderRadius: AppRadius.borderRadiusMd,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: AppRadius.borderRadiusSm,
                          ),
                          child: Center(
                            child: Text(
                              '${nState.unreadCount}',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sp3),
                        Text(
                          'unread notification${nState.unreadCount == 1 ? '' : 's'}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: nState.filterLabels.length,
                    separatorBuilder: (_, i) =>
                        const SizedBox(width: AppSpacing.sp2),
                    itemBuilder: (context, i) {
                      final isActive = nState.filterIndex == i;
                      return AppTapAnimation(
                        onTap: () => ref.read(notificationNotifierProvider.notifier).setFilter(i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : const Color(0xFFF1F5F9)),
                            borderRadius: AppRadius.borderRadiusFull,
                          ),
                          child: Text(
                            nState.filterLabels[i],
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isActive
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sp2),

          // ── Notification list ──────────────────────────────────────
          Expanded(
            child: nState.filtered.isEmpty
                ? AppEmptyState(
                    icon: Icons.notifications_none_rounded,
                    title: nState.filterIndex == 0
                        ? 'You are all caught up!'
                        : 'No ${nState.filterLabels[nState.filterIndex].toLowerCase()} notifications',
                    subtitle: nState.filterIndex == 0
                        ? 'No new notifications at this time.'
                        : 'Check back later for updates.',
                  )
                : ListView(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sp6),
                    children: [
                      for (final group in nState.groupOrder)
                        if (groups.containsKey(group)) ...[
                          _GroupHeader(label: group, isDark: isDark),
                          ...groups[group]!.map((n) => _NotifTile(
                                key: ValueKey(n.id),
                                data: n,
                                isDark: isDark,
                                onTap: () => _markRead(n),
                                onDismiss: () => _dismiss(n),
                              )),
                        ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP HEADER
// ═══════════════════════════════════════════════════════════════════════════════

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sp4, AppSpacing.sp3, AppSpacing.sp4, AppSpacing.sp1,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelAllCaps.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// NOTIFICATION TILE — swipeable, tap-navigable
// ═══════════════════════════════════════════════════════════════════════════════

class _NotifTile extends StatelessWidget {
  const _NotifTile({
    super.key,
    required this.data,
    required this.isDark,
    required this.onTap,
    required this.onDismiss,
  });

  final AppNotification data;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(data.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.sp5),
        color: const Color(0xFFEF4444),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
            SizedBox(height: 2),
            Text('Dismiss',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      child: Material(
        color: data.isRead
            ? Colors.transparent
            : (isDark
                ? AppColors.primary.withValues(alpha: 0.06)
                : AppColors.primary.withValues(alpha: 0.03)),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sp4,
              vertical: AppSpacing.sp3,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: data.color.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  child: Icon(data.icon, size: 22, color: data.color),
                ),
                const SizedBox(width: AppSpacing.sp3),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight:
                              data.isRead ? FontWeight.w400 : FontWeight.w700,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        data.body,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textDisabled,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            data.time,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textDisabled,
                              fontSize: 11,
                            ),
                          ),
                          if (data.actionLabel != null) ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: data.color
                                    .withValues(alpha: isDark ? 0.15 : 0.1),
                                borderRadius: AppRadius.borderRadiusFull,
                              ),
                              child: Text(
                                data.actionLabel!,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: data.color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Unread dot
                if (!data.isRead) ...[
                  const SizedBox(width: AppSpacing.sp2),
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

