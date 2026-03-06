import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// PRAYER REQUESTS SCREEN
//
// List of user's submitted prayer requests with visibility badges,
// prayer counts, and status.
// ──────────────────────────────────────────────────────────────────────────────

class PrayerRequestsScreen extends StatelessWidget {
  const PrayerRequestsScreen({super.key});

  static const _requests = [
    _PrayerItem('Healing for my mother', 'Please pray for her recovery.',
        'Public', 12, '2 hours ago'),
    _PrayerItem('Job provision', 'Trusting God for open doors.', 'Private', 0,
        'Yesterday'),
    _PrayerItem('Family peace', 'Praying for unity and love.', 'Public', 8,
        '3 days ago'),
    _PrayerItem('Guidance for decision', '', 'Private', 0, '1 week ago'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Prayer Requests',
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
        ),
      ),
      body: _requests.isEmpty
          ? const AppEmptyState(
              icon: Icons.favorite_border,
              title: 'No prayer requests yet',
              subtitle:
                  'Share your heart \u2014 your church is here for you.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.sp4),
              itemCount: _requests.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sp3),
              itemBuilder: (_, i) =>
                  _PrayerTile(item: _requests[i], isDark: isDark),
            ),
    );
  }
}

class _PrayerTile extends StatelessWidget {
  const _PrayerTile({required this.item, required this.isDark});
  final _PrayerItem item;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isPublic = item.visibility == 'Public';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.gold.withValues(alpha: 0.15)
                      : AppColors.gold.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite,
                    size: 18, color: AppColors.gold),
              ),
              const SizedBox(width: AppSpacing.sp3),
              Expanded(
                child: Text(
                  item.title,
                  style: AppTextStyles.bodyLargeSemiBold.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPublic
                      ? (isDark
                          ? AppColors.primaryLight.withValues(alpha: 0.15)
                          : AppColors.skyLight)
                      : (isDark
                          ? AppColors.borderDark
                          : const Color(0xFFF3F4F6)),
                  borderRadius: AppRadius.borderRadiusFull,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPublic ? Icons.lock_open : Icons.lock,
                      size: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.visibility,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (item.details.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sp2),
            Text(
              item.details,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.sp3),

          // Footer
          Row(
            children: [
              if (item.prayerCount > 0) ...[
                Icon(Icons.people_outline,
                    size: 14,
                    color: isDark
                        ? AppColors.primaryLight
                        : AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  '${item.prayerCount} praying',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.primaryLight
                        : AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sp4),
              ],
              Text(
                item.timeAgo,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrayerItem {
  const _PrayerItem(
    this.title,
    this.details,
    this.visibility,
    this.prayerCount,
    this.timeAgo,
  );
  final String title;
  final String details;
  final String visibility;
  final int prayerCount;
  final String timeAgo;
}
