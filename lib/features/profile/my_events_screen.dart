import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/event.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// MY EVENTS SCREEN
//
// Events the user registered for, loaded from GET /events/my.
// ──────────────────────────────────────────────────────────────────────────────

class MyEventsScreen extends ConsumerWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final eventState = ref.watch(eventNotifierProvider);

    // Trigger load if myEvents is empty
    if (eventState.myEvents.isEmpty && !eventState.isLoading) {
      Future.microtask(
          () => ref.read(eventNotifierProvider.notifier).loadMyEvents());
    }

    if (eventState.isLoading && eventState.myEvents.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
        appBar: AppFilledAppBar(title: 'My Events', showBack: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(title: 'My Events', showBack: true),
      body: eventState.myEvents.isEmpty
          ? const AppEmptyState(
              icon: Icons.event_busy,
              title: 'No events yet',
              subtitle: 'Register for events to see them here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.sp4),
              itemCount: eventState.myEvents.length,
              separatorBuilder: (_, i) =>
                  const SizedBox(height: AppSpacing.sp3),
              itemBuilder: (_, i) => _EventTile(
                event: eventState.myEvents[i],
                isDark: isDark,
              ),
            ),
    );
  }
}

// ── Tile ──────────────────────────────────────────────────────────────────────

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.isDark});
  final Event event;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isUpcoming = event.startDate.isAfter(DateTime.now());

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
                    '${event.dateFormatted} · ${event.timeFormatted}'
                    '${event.location != null ? '\n${event.location}' : ''}',
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
                isUpcoming ? 'Upcoming' : 'Completed',
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
