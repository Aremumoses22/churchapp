import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SERIES DETAIL SCREEN
//
// Shows all sermons in a particular series with a hero header and list.
// ──────────────────────────────────────────────────────────────────────────────

class SeriesDetailScreen extends StatelessWidget {
  const SeriesDetailScreen({super.key, required this.seriesId});

  final String seriesId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      body: CustomScrollView(
        slivers: [
          // ── Hero ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl:
                          'https://picsum.photos/seed/series_$seriesId/800/400',
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                          decoration: BoxDecoration(
                              gradient: isDark
                                  ? AppGradients.heroDark
                                  : AppGradients.hero)),
                      errorWidget: (_, __, ___) => Container(
                          decoration: BoxDecoration(
                              gradient: isDark
                                  ? AppGradients.heroDark
                                  : AppGradients.hero)),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.2),
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                    SafeArea(
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
                                  'Faith Series',
                                  style: AppTextStyles.headingLarge
                                      .copyWith(color: AppColors.textInverse),
                                ),
                                const SizedBox(height: AppSpacing.sp1),
                                Text(
                                  '3 sermons \u00b7 Pastor James',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textInverse
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
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

          // ── Sermons list ────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.sp4),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                AppFeatureCard(
                  title: 'The Power of Faith',
                  subtitle: 'Feb 23 \u00b7 42 min',
                  trailing: _playIcon(isDark),
                  onTap: () => context.push('/sermons/1'),
                ),
                const SizedBox(height: AppSpacing.sp3),
                AppFeatureCard(
                  title: 'Love Without Limits',
                  subtitle: 'Jan 26 \u00b7 39 min',
                  trailing: _playIcon(isDark),
                  onTap: () => context.push('/sermons/5'),
                ),
                const SizedBox(height: AppSpacing.sp3),
                AppFeatureCard(
                  title: 'Faith That Moves Mountains',
                  subtitle: 'Jan 12 \u00b7 41 min',
                  trailing: _playIcon(isDark),
                  onTap: () => context.push('/sermons/6'),
                ),
              ]),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp8)),
        ],
      ),
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
