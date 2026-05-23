import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/prayer.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// PRAYER REQUESTS SCREEN
//
// User's submitted prayer requests loaded from GET /prayer-requests/my.
// ──────────────────────────────────────────────────────────────────────────────

class PrayerRequestsScreen extends ConsumerWidget {
  const PrayerRequestsScreen({super.key});

  String _timeAgo(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inDays >= 7) return '${diff.inDays ~/ 7}w ago';
      if (diff.inDays >= 1) return '${diff.inDays}d ago';
      if (diff.inHours >= 1) return '${diff.inHours}h ago';
      return '${diff.inMinutes}m ago';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final requests = ref.watch(prayerRequestsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Prayer Requests',
        showBack: true,
      ),
      body: requests.isEmpty
          ? const AppEmptyState(
              icon: Icons.favorite_border,
              title: 'No prayer requests yet',
              subtitle: 'Share your heart — your church is here for you.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.sp4),
              itemCount: requests.length,
              separatorBuilder: (_, i) =>
                  const SizedBox(height: AppSpacing.sp3),
              itemBuilder: (_, i) => _PrayerTile(
                request: requests[i],
                isDark: isDark,
                timeAgo: _timeAgo(requests[i].createdAt),
                onPray: () => ref
                    .read(prayerRequestsProvider.notifier)
                    .prayFor(requests[i].id),
              ),
            ),
    );
  }
}

// ── Tile ──────────────────────────────────────────────────────────────────────

class _PrayerTile extends StatelessWidget {
  const _PrayerTile({
    required this.request,
    required this.isDark,
    required this.timeAgo,
    required this.onPray,
  });

  final PrayerRequest request;
  final bool isDark;
  final String timeAgo;
  final VoidCallback onPray;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite, size: 18, color: AppColors.gold),
              ),
              const SizedBox(width: AppSpacing.sp3),
              Expanded(
                child: Text(
                  request.title,
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
                  color: request.isPublic
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
                      request.isPublic ? Icons.lock_open : Icons.lock,
                      size: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      request.isPublic ? 'Public' : 'Private',
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
          if (request.details != null && request.details!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sp2),
            Text(
              request.details!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sp3),
          Row(
            children: [
              if (request.prayerCount > 0) ...[
                Icon(Icons.people_outline,
                    size: 14,
                    color: isDark
                        ? AppColors.primaryLight
                        : AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  '${request.prayerCount} praying',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.primaryLight
                        : AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sp4),
              ],
              if (timeAgo.isNotEmpty)
                Text(
                  timeAgo,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textDisabled,
                  ),
                ),
              const Spacer(),
              if (!request.hasPrayed)
                GestureDetector(
                  onTap: onPray,
                  child: Row(
                    children: [
                      Icon(Icons.favorite_border,
                          size: 16,
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Pray',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
