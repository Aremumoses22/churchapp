import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/community.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// ANNOUNCEMENTS SCREEN
//
// Church-wide announcements loaded from /community/announcements.
// ──────────────────────────────────────────────────────────────────────────────

class AnnouncementsScreen extends ConsumerWidget {
  const AnnouncementsScreen({super.key});

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final announcements = ref.watch(announcementsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(title: 'Announcements', showBack: true),
      body: announcements.isEmpty
          ? const AppEmptyState(
              icon: Icons.campaign_outlined,
              title: 'No announcements',
              subtitle: 'Check back later for updates from the church.',
            )
          : ListView.builder(
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
                    formattedDate: _formatDate(announcements[index].publishedAt),
                    onTap: () => ref
                        .read(announcementsProvider.notifier)
                        .markRead(announcements[index].id),
                  ),
                );
              },
            ),
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    required this.announcement,
    required this.isDark,
    required this.formattedDate,
    required this.onTap,
  });

  final Announcement announcement;
  final bool isDark;
  final String formattedDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: onTap,
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
            if (announcement.isUrgent)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sp4,
                  vertical: AppSpacing.sp2,
                ),
                color: AppColors.error,
                child: Row(
                  children: [
                    const Icon(Icons.priority_high, color: Colors.white, size: 16),
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
            if (announcement.imageUrl != null)
              SizedBox(
                width: double.infinity,
                height: 160,
                child: Image.network(
                  announcement.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context2, err, stack) => Container(
                    decoration: BoxDecoration(gradient: AppGradients.hero),
                    child: Center(
                      child: Icon(Icons.image_outlined,
                          size: 40,
                          color: Colors.white.withValues(alpha: 0.4)),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sp4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sp2, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : AppColors.skyLight,
                          borderRadius: AppRadius.borderRadiusXs,
                        ),
                        child: Text(
                          announcement.category ?? 'General',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.primaryLight
                                : AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (!announcement.isRead) ...[
                        const SizedBox(width: AppSpacing.sp2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sp2, vertical: 2),
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
                      if (announcement.isPinned)
                        const Icon(Icons.push_pin_outlined,
                            size: 16, color: AppColors.gold),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sp3),
                  Text(
                    announcement.title,
                    style: AppTextStyles.bodyLargeSemiBold.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sp2),
                  Text(
                    announcement.content,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (formattedDate.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sp3),
                    Text(
                      formattedDate,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textDisabled,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
