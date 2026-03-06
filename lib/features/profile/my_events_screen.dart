import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// MY EVENTS SCREEN
//
// List of events the user has registered for, with status badges.
// ──────────────────────────────────────────────────────────────────────────────

class MyEventsScreen extends StatelessWidget {
  const MyEventsScreen({super.key});

  static const _events = [
    _MyEvent('Worship Conference 2026', 'Sun, Feb 23 \u00b7 10:00 AM',
        'Grace Cathedral', 'Upcoming', '3'),
    _MyEvent('Youth Night', 'Sat, Feb 8 \u00b7 6:00 PM', 'Main Auditorium',
        'Completed', '1'),
    _MyEvent('Prayer Walk', 'Sat, Jan 25 \u00b7 7:00 AM', 'City Park',
        'Completed', '5'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'My Events',
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
        ),
      ),
      body: _events.isEmpty
          ? const AppEmptyState(
              icon: Icons.event_busy,
              title: 'No events yet',
              subtitle: 'Register for events to see them here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.sp4),
              itemCount: _events.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sp3),
              itemBuilder: (_, i) =>
                  _EventTile(event: _events[i], isDark: isDark),
            ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.isDark});
  final _MyEvent event;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isUpcoming = event.status == 'Upcoming';

    return AppTapAnimation(
      onTap: () => context.push('/events/${event.id}'),
      liftEffect: true,
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isUpcoming
                    ? (isDark
                        ? AppColors.primaryLight.withValues(alpha: 0.15)
                        : AppColors.skyLight)
                    : (isDark
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.success.withValues(alpha: 0.1)),
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: Icon(
                Icons.event,
                size: 24,
                color: isUpcoming
                    ? (isDark ? AppColors.primaryLight : AppColors.primary)
                    : AppColors.success,
              ),
            ),
            const SizedBox(width: AppSpacing.sp3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: AppTextStyles.bodyLargeSemiBold.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${event.date}\n${event.location}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isUpcoming
                    ? (isDark
                        ? AppColors.primaryLight.withValues(alpha: 0.15)
                        : AppColors.skyLight)
                    : (isDark
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.success.withValues(alpha: 0.1)),
                borderRadius: AppRadius.borderRadiusFull,
              ),
              child: Text(
                event.status,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isUpcoming
                      ? (isDark ? AppColors.primaryLight : AppColors.primary)
                      : AppColors.success,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyEvent {
  const _MyEvent(
      this.title, this.date, this.location, this.status, this.id);
  final String title;
  final String date;
  final String location;
  final String status;
  final String id;
}
