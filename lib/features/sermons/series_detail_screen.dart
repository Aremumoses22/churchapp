import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/sermon.dart';
import '../../core/providers/sermon_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SERIES DETAIL SCREEN — shows all sermons in a particular series
// ──────────────────────────────────────────────────────────────────────────────

class SeriesDetailScreen extends ConsumerWidget {
  const SeriesDetailScreen({super.key, required this.seriesId});
  final String seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final seriesAsync = ref.watch(seriesDetailProvider(seriesId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      body: seriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: AppEmptyState(
            icon: Icons.error_outline,
            title: 'Failed to load series',
            subtitle: e.toString(),
            buttonLabel: 'Retry',
            onButtonPressed: () =>
                ref.invalidate(seriesDetailProvider(seriesId)),
          ),
        ),
        data: (series) => _buildBody(context, series, isDark),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SermonSeries series, bool isDark) {
    return CustomScrollView(
      slivers: [
        // ── Hero ──────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: isDark ? AppGradients.heroDark : AppGradients.hero,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    left: AppSpacing.sp4,
                    child: AppIconButton(
                      icon: Icons.arrow_back,
                      onPressed: () => context.pop(),
                      semanticLabel: 'Go back',
                    ),
                  ),
                  Positioned(
                    bottom: AppSpacing.sp6,
                    left: AppSpacing.sp6,
                    right: AppSpacing.sp6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: AppRadius.borderRadiusFull,
                          ),
                          child: Text('Series',
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.textPrimary)),
                        ),
                        const SizedBox(height: AppSpacing.sp2),
                        Text(
                          series.title,
                          style: AppTextStyles.headingLarge
                              .copyWith(color: AppColors.textInverse),
                        ),
                        const SizedBox(height: AppSpacing.sp1),
                        Text(
                          '${series.sermonCount} sermons',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color:
                                AppColors.textInverse.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Description ───────────────────────────────────────────────
        if (series.description != null && series.description!.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sp4, AppSpacing.sp4, AppSpacing.sp4, 0),
              child: Text(
                series.description!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),

        // ── Sermons list ──────────────────────────────────────────────
        if (series.sermons.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: AppEmptyState(
                icon: Icons.headphones,
                title: 'No sermons yet',
                subtitle: 'Sermons will appear here as they are added.',
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.sp4),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final sermon = series.sermons[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sp3),
                    child: AppFeatureCard(
                      title: sermon.title,
                      subtitle:
                          '${sermon.dateFormatted} · ${sermon.durationFormatted}',
                      trailing: _playIcon(isDark),
                      onTap: () => context.push('/sermons/${sermon.id}'),
                    ),
                  );
                },
                childCount: series.sermons.length,
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp8)),
      ],
    );
  }

  Widget _playIcon(bool isDark) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? AppColors.primaryLight : AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.play_arrow,
            color: AppColors.textInverse, size: 18),
      );
}
