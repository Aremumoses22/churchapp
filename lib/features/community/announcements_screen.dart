import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/community.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// ANNOUNCEMENTS SCREEN
//
// Church-wide announcements with priority banners (urgent = red top bar),
// images, date stamps, "New" badge.
// ──────────────────────────────────────────────────────────────────────────────

class AnnouncementsScreen extends ConsumerWidget {
  const AnnouncementsScreen({super.key});

  static _Announcement _fromApi(Announcement a) => _Announcement(
        id: a.id,
        title: a.title,
        body: a.content,
        date: a.publishedAt ?? '',
        timeAgo: a.publishedAt ?? '',
        priority: a.isUrgent
            ? _Priority.urgent
            : (a.isPinned ? _Priority.high : _Priority.normal),
        isNew: !a.isRead,
        hasImage: a.imageUrl != null,
        category: a.category ?? 'General',
      );

  static const _announcements = [
    _Announcement(
      id: '1',
      title: 'Church Building Fund Update',
      body:
          'We are thrilled to announce that we have reached 75% of our building fund goal! Thank you for your generous contributions. The new fellowship hall construction will begin in March.',
      date: 'Feb 22, 2026',
      timeAgo: '1 day ago',
      priority: _Priority.urgent,
      isNew: true,
      hasImage: true,
      category: 'Building Fund',
    ),
    _Announcement(
      id: '2',
      title: 'Easter Service Schedule',
      body:
          'Mark your calendars! Our Easter celebrations will include a sunrise service at 6:00 AM, followed by regular services at 9:00 AM and 11:00 AM. Children\'s Easter egg hunt at 10:00 AM.',
      date: 'Feb 20, 2026',
      timeAgo: '3 days ago',
      priority: _Priority.high,
      isNew: true,
      hasImage: false,
      category: 'Events',
    ),
    _Announcement(
      id: '3',
      title: 'New Connect Group Starting',
      body:
          'A new Young Adults connect group is starting this Wednesday at 7 PM. Join us at the church cafe for fellowship, worship, and discussion. All young adults ages 18-30 are welcome!',
      date: 'Feb 18, 2026',
      timeAgo: '5 days ago',
      priority: _Priority.normal,
      isNew: false,
      hasImage: false,
      category: 'Groups',
    ),
    _Announcement(
      id: '4',
      title: 'Volunteer Appreciation Dinner',
      body:
          'To all our amazing volunteers — you are invited to a special appreciation dinner on March 5th at 6:30 PM in the fellowship hall. RSVP by February 28th.',
      date: 'Feb 15, 2026',
      timeAgo: '1 week ago',
      priority: _Priority.normal,
      isNew: false,
      hasImage: true,
      category: 'Volunteers',
    ),
    _Announcement(
      id: '5',
      title: 'Updated Parking Guidelines',
      body:
          'Please note that the east parking lot will be under maintenance starting next week. Use the west entrance and overflow parking at the community center.',
      date: 'Feb 12, 2026',
      timeAgo: '11 days ago',
      priority: _Priority.normal,
      isNew: false,
      hasImage: false,
      category: 'General',
    ),
    _Announcement(
      id: '6',
      title: 'Mission Trip to Guatemala',
      body:
          'Applications are now open for our summer mission trip to Guatemala, July 10-20. Cost is \$1,800 per person. Financial assistance available. Info meeting this Sunday after second service.',
      date: 'Feb 10, 2026',
      timeAgo: '13 days ago',
      priority: _Priority.high,
      isNew: false,
      hasImage: true,
      category: 'Missions',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final apiData = ref.watch(announcementsFutureProvider).value;
    final announcements = (apiData != null && apiData.isNotEmpty)
        ? apiData.map(_fromApi).toList()
        : _announcements;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Announcements',
        showBack: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              size: 22,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: AppSpacing.sp2),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontalPadding,
          vertical: AppSpacing.sp4,
        ),
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
            child: _AnnouncementCard(
              announcement: announcements[index],
              isDark: isDark,
            ),
          );
        },
      ),
    );
  }
}

// ── Data ─────────────────────────────────────────────────────────────────────

enum _Priority { urgent, high, normal }

class _Announcement {
  const _Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.timeAgo,
    required this.priority,
    required this.isNew,
    required this.hasImage,
    required this.category,
  });

  final String id;
  final String title;
  final String body;
  final String date;
  final String timeAgo;
  final _Priority priority;
  final bool isNew;
  final bool hasImage;
  final String category;
}

// ── Widgets ─────────────────────────────────────────────────────────────────

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    required this.announcement,
    required this.isDark,
  });

  final _Announcement announcement;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: () {},
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: AppRadius.borderRadiusLg,
          boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Urgent red bar
            if (announcement.priority == _Priority.urgent)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sp4,
                  vertical: AppSpacing.sp2,
                ),
                color: AppColors.error,
                child: Row(
                  children: [
                    const Icon(
                      Icons.priority_high,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.sp1),
                    Text(
                      'URGENT',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

            // Image placeholder
            if (announcement.hasImage)
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  gradient: isDark
                      ? AppGradients.heroDark
                      : AppGradients.hero,
                ),
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 40,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sp4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + New badge row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sp2,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : AppColors.skyLight,
                          borderRadius: AppRadius.borderRadiusXs,
                        ),
                        child: Text(
                          announcement.category,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.primaryLight
                                : AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (announcement.isNew) ...[
                        const SizedBox(width: AppSpacing.sp2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sp2,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: AppRadius.borderRadiusXs,
                          ),
                          child: Text(
                            'NEW',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (announcement.priority == _Priority.high)
                        Icon(
                          Icons.push_pin_outlined,
                          size: 16,
                          color: AppColors.gold,
                        ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sp3),

                  // Title
                  Text(
                    announcement.title,
                    style: AppTextStyles.bodyLargeSemiBold.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sp2),

                  // Body preview
                  Text(
                    announcement.body,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSpacing.sp3),

                  // Date
                  Text(
                    '${announcement.date} \u00B7 ${announcement.timeAgo}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
