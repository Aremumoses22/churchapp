import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/media.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// PODCAST FEED SCREEN
//
// Episodes loaded from GET /media/podcasts.
// ──────────────────────────────────────────────────────────────────────────────

class PodcastFeedScreen extends ConsumerWidget {
  const PodcastFeedScreen({super.key});

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final podcastsAsync = ref.watch(podcastsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(title: 'Podcast', showBack: true),
      body: podcastsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48),
              const SizedBox(height: AppSpacing.sp3),
              Text('Failed to load podcasts',
                  style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.sp3),
              AppSecondaryButton(
                label: 'Retry',
                onPressed: () => ref.invalidate(podcastsProvider),
              ),
            ],
          ),
        ),
        data: (episodes) => episodes.isEmpty
            ? const AppEmptyState(
                icon: Icons.podcasts_outlined,
                title: 'No episodes yet',
                subtitle: 'Check back soon for new podcast episodes.',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.sp4),
                itemCount: episodes.length,
                itemBuilder: (context, i) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppSpacing.cardGap),
                  child: _EpisodeTile(
                    episode: episodes[i],
                    isDark: isDark,
                    formattedDate: _formatDate(episodes[i].publishedAt),
                  ),
                ),
              ),
      ),
    );
  }
}

// ── Episode tile ──────────────────────────────────────────────────────────────

class _EpisodeTile extends StatelessWidget {
  const _EpisodeTile({
    required this.episode,
    required this.isDark,
    required this.formattedDate,
  });

  final PodcastEpisode episode;
  final bool isDark;
  final String formattedDate;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sp4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: AppRadius.borderRadiusLg,
          boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primaryLight.withValues(alpha: 0.15)
                    : AppColors.skyLight,
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: episode.thumbnailUrl != null
                  ? ClipRRect(
                      borderRadius: AppRadius.borderRadiusMd,
                      child: Image.network(episode.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (c, err, st) => Icon(
                              Icons.podcasts_outlined,
                              size: 28,
                              color: isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary)),
                    )
                  : Icon(Icons.podcasts_outlined,
                      size: 28,
                      color: isDark
                          ? AppColors.primaryLight
                          : AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.sp3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (episode.series != null)
                    Text(episode.series!,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.primaryLight
                                : AppColors.primary,
                            fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(episode.title,
                      style: AppTextStyles.bodyLargeSemiBold.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (episode.speaker != null) ...[
                        Text(episode.speaker!,
                            style: AppTextStyles.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                                fontSize: 11)),
                        if (episode.durationFormatted.isNotEmpty) ...[
                          const SizedBox(width: AppSpacing.sp2),
                          Text('·',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary)),
                          const SizedBox(width: AppSpacing.sp2),
                        ],
                      ],
                      if (episode.durationFormatted.isNotEmpty)
                        Text(episode.durationFormatted,
                            style: AppTextStyles.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                                fontSize: 11)),
                    ],
                  ),
                  if (formattedDate.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(formattedDate,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textDisabled,
                            fontSize: 10)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sp2),
            Icon(
              episode.isCompleted
                  ? Icons.check_circle
                  : Icons.play_circle_outline,
              size: 28,
              color: episode.isCompleted
                  ? AppColors.success
                  : (isDark ? AppColors.primaryLight : AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
