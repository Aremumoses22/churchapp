import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/sermon.dart';
import '../../core/providers/sermon_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SERMONS SCREEN — § 8  (Enhanced)
//
// Layout (top → bottom):
//   1. App bar ("Messages" title, filter icon)
//   2. Series covers — Netflix-style horizontal scroll with artwork cards
//   3. Search bar with debounce
//   4. Filter chips (All, Sunday Service, Series, Guest Speaker, Recent)
//   5. Sermon list with waveform visualizer & download indicator
//   6. Now Playing mini-bar (persistent, above nav bar)
// ──────────────────────────────────────────────────────────────────────────────

class SermonsScreen extends ConsumerStatefulWidget {
  const SermonsScreen({super.key});

  @override
  ConsumerState<SermonsScreen> createState() => _SermonsScreenState();
}

class _SermonsScreenState extends ConsumerState<SermonsScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();

  static const _filters = [
    'All',
    'Sunday Service',
    'Series',
    'Guest Speaker',
    'Recent',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sState = ref.watch(sermonNotifierProvider);
    final sermons = sState.filteredSermons;
    final seriesList = sState.series;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Messages',
        actions: [
          AppIconButton(
            icon: Icons.tune_outlined,
            onPressed: () {},
            semanticLabel: 'Filter sermons',
          ),
          const SizedBox(width: AppSpacing.sp2),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // ── Series Covers (Netflix row) ───────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: AppSpacing.sp4, bottom: AppSpacing.sp2),
                    child: AppSectionHeader(
                      title: 'Sermon Series',
                      actionLabel: 'See all',
                      onAction: () {},
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sp4),
                      itemCount: seriesList.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppSpacing.sp3),
                      itemBuilder: (_, index) {
                        final series = seriesList[index];
                        return _SeriesCoverCard(
                          series: series,
                          isDark: isDark,
                          onTap: () =>
                              context.push('/series/${series.id}'),
                        );
                      },
                    ),
                  ),
                ),

                // ── Search bar ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.sp4,
                      AppSpacing.sp5,
                      AppSpacing.sp4,
                      0,
                    ),
                    child: AppSearchBar(
                      controller: _searchController,
                      hint: 'Search sermons, series, speakers...',
                      onChanged: (value) => ref
                          .read(sermonNotifierProvider.notifier)
                          .setSearchQuery(value),
                      onClear: () => ref
                          .read(sermonNotifierProvider.notifier)
                          .setSearchQuery(''),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.sp3)),

                // ── Filter chips ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: AppFilterChips(
                    labels: _filters,
                    selectedIndex: sState.selectedFilter,
                    onSelected: (i) => ref
                        .read(sermonNotifierProvider.notifier)
                        .setFilter(i),
                  ),
                ),
                const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.sp3)),

                // ── Sermon list ───────────────────────────────────────
                if (sermons.isEmpty)
                  const SliverFillRemaining(
                    child: AppEmptyState(
                      icon: Icons.church_outlined,
                      title: 'No sermons found',
                      subtitle: 'Try a different search or filter.',
                      buttonLabel: 'Clear filters',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sp4,
                      vertical: AppSpacing.sp2,
                    ),
                    sliver: SliverList.separated(
                      itemCount: sermons.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sp3),
                      itemBuilder: (context, index) {
                        final sermon = sermons[index];
                        return _SermonCard(
                          sermon: sermon,
                          isDark: isDark,
                          onTap: () =>
                              context.push('/sermons/${sermon.id}'),
                        );
                      },
                    ),
                  ),

                // Bottom clearance for mini-bar
                SliverToBoxAdapter(
                  child: SizedBox(
                      height: sState.isPlaying ? 80 : AppSpacing.sp8),
                ),
              ],
            ),
          ),

          // ── Now Playing Mini-bar ────────────────────────────────────
          if (sState.isPlaying)
            _NowPlayingBar(
              title: sState.nowPlayingTitle,
              speaker: sState.nowPlayingSpeaker,
              progress: sState.nowPlayingProgress,
              isPlaying: sState.isPlaying,
              isDark: isDark,
              onPlayPause: () => ref
                  .read(sermonNotifierProvider.notifier)
                  .togglePlaying(),
              onTap: () => context.push('/sermons/1'),
              onClose: () => ref
                  .read(sermonNotifierProvider.notifier)
                  .togglePlaying(),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SERIES COVER CARD — Netflix-style artwork card
// ═══════════════════════════════════════════════════════════════════════════════

class _SeriesCoverCard extends StatelessWidget {
  const _SeriesCoverCard({
    required this.series,
    required this.isDark,
    required this.onTap,
  });

  final SermonSeries series;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: onTap,
      liftEffect: true,
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              series.color,
              series.color.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: AppRadius.borderRadiusLg,
          boxShadow: [
            BoxShadow(
              color: series.color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern (subtle circles)
            Positioned(
              right: -20,
              bottom: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              left: -10,
              top: -10,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sp4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(series.emoji,
                      style: const TextStyle(fontSize: 32)),
                  const Spacer(),
                  Text(
                    series.title,
                    style: AppTextStyles.labelMedium
                        .copyWith(color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    series.subtitle,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: Colors.white70, fontSize: 10),
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

// ═══════════════════════════════════════════════════════════════════════════════
// SERMON CARD — with waveform visualizer & download indicator
// ═══════════════════════════════════════════════════════════════════════════════

class _SermonCard extends StatefulWidget {
  const _SermonCard({
    required this.sermon,
    required this.isDark,
    required this.onTap,
  });

  final Sermon sermon;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_SermonCard> createState() => _SermonCardState();
}

class _SermonCardState extends State<_SermonCard> {
  bool _isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: widget.onTap,
      liftEffect: true,
      child: Container(
        height: 108,
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: AppRadius.borderRadiusXl,
          boxShadow: widget.isDark ? AppShadows.smDark : AppShadows.sm,
        ),
        child: Row(
          children: [
            // Thumbnail with waveform
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sp3),
              child: ClipRRect(
                borderRadius: AppRadius.borderRadiusLg,
                child: Container(
                  width: 80,
                  height: 84,
                  color:
                      widget.isDark ? AppColors.skyDark : AppColors.skyLight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Waveform bars
                      CustomPaint(
                        size: const Size(80, 84),
                        painter: _WaveformPainter(
                          color: (widget.isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary)
                              .withValues(alpha: 0.2),
                          barCount: 20,
                          seed: widget.sermon.id.hashCode,
                        ),
                      ),
                      // Play icon overlay
                      Icon(
                        Icons.headphones_outlined,
                        size: 28,
                        color: widget.isDark
                            ? AppColors.primaryLight
                            : AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.sp2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Series tag
                    if (widget.sermon.series != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color:
                              AppColors.goldLight.withValues(alpha: 0.3),
                          borderRadius: AppRadius.borderRadiusXs,
                        ),
                        child: Text(
                          widget.sermon.series!,
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.gold),
                        ),
                      ),
                    Text(
                      widget.sermon.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLargeSemiBold.copyWith(
                        color: widget.isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.person_outlined,
                            size: 14,
                            color: widget.isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            widget.sermon.speaker,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: widget.isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sp2),
                        // Mini waveform for duration
                        _MiniWaveform(
                          isDark: widget.isDark,
                          seed: widget.sermon.id.hashCode,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.sermon.duration,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: widget.isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Actions column
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sp1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bookmark
                  Padding(
                    padding: const EdgeInsets.only(
                        top: AppSpacing.sp2, right: AppSpacing.sp2),
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _isBookmarked = !_isBookmarked),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          key: ValueKey(_isBookmarked),
                          size: 20,
                          color: _isBookmarked
                              ? AppColors.gold
                              : (widget.isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                  // Download indicator + play button row
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppSpacing.sp3, right: AppSpacing.sp2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _DownloadIndicator(
                          state: widget.sermon.downloadState,
                          progress: widget.sermon.downloadProgress,
                          isDark: widget.isDark,
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: widget.isDark
                                ? AppColors.primaryLight
                                : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: AppColors.textInverse,
                            size: 18,
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
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// WAVEFORM PAINTER — random bars for sermon thumbnail
// ═══════════════════════════════════════════════════════════════════════════════

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.color,
    required this.barCount,
    required this.seed,
  });

  final Color color;
  final int barCount;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    final barWidth = size.width / (barCount * 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (var i = 0; i < barCount; i++) {
      final height =
          size.height * (0.15 + rng.nextDouble() * 0.55);
      final x = i * barWidth * 2 + barWidth * 0.5;
      final y = (size.height - height) / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, height),
          const Radius.circular(1),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) =>
      oldDelegate.seed != seed;
}

// ═══════════════════════════════════════════════════════════════════════════════
// MINI WAVEFORM — tiny waveform bars replacing the clock icon for duration
// ═══════════════════════════════════════════════════════════════════════════════

class _MiniWaveform extends StatelessWidget {
  const _MiniWaveform({required this.isDark, required this.seed});

  final bool isDark;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final rng = math.Random(seed);
    final color = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(5, (i) {
        final h = 4.0 + rng.nextDouble() * 8.0;
        return Container(
          width: 2,
          height: h,
          margin: const EdgeInsets.symmetric(horizontal: 0.5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DOWNLOAD INDICATOR — cloud icon with states
// ═══════════════════════════════════════════════════════════════════════════════

class _DownloadIndicator extends StatelessWidget {
  const _DownloadIndicator({
    required this.state,
    required this.progress,
    required this.isDark,
  });

  final DownloadState state;
  final double progress;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case DownloadState.downloaded:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.cloud_done_outlined,
              size: 14, color: AppColors.success),
        );

      case DownloadState.downloading:
        return SizedBox(
          width: 24,
          height: 24,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 2,
                  backgroundColor: isDark
                      ? AppColors.borderDark
                      : AppColors.inputFill,
                  color: AppColors.primary,
                ),
              ),
              Icon(Icons.cloud_download_outlined,
                  size: 10,
                  color:
                      isDark ? AppColors.primaryLight : AppColors.primary),
            ],
          ),
        );

      case DownloadState.none:
        return GestureDetector(
          onTap: () {},
          child: Icon(Icons.cloud_download_outlined,
              size: 20,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textDisabled),
        );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// NOW PLAYING MINI-BAR — persistent mini-player above nav bar
// ═══════════════════════════════════════════════════════════════════════════════

class _NowPlayingBar extends StatelessWidget {
  const _NowPlayingBar({
    required this.title,
    required this.speaker,
    required this.progress,
    required this.isPlaying,
    required this.isDark,
    required this.onPlayPause,
    required this.onTap,
    required this.onClose,
  });

  final String title;
  final String speaker;
  final double progress;
  final bool isPlaying;
  final bool isDark;
  final VoidCallback onPlayPause;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          boxShadow: isDark ? AppShadows.lgDark : AppShadows.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar (thin line at top)
            LinearProgressIndicator(
              value: progress,
              minHeight: 2,
              backgroundColor:
                  isDark ? AppColors.borderDark : AppColors.inputFill,
              color: AppColors.primary,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sp4, vertical: AppSpacing.sp2),
              child: Row(
                children: [
                  // Album art / icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.skyDark
                          : AppColors.skyLight,
                      borderRadius: AppRadius.borderRadiusSm,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(40, 40),
                          painter: _WaveformPainter(
                            color: (isDark
                                    ? AppColors.primaryLight
                                    : AppColors.primary)
                                .withValues(alpha: 0.2),
                            barCount: 10,
                            seed: title.hashCode,
                          ),
                        ),
                        Icon(Icons.music_note,
                            size: 16,
                            color: isDark
                                ? AppColors.primaryLight
                                : AppColors.primary),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sp3),

                  // Title & speaker
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: AppTextStyles.labelMedium.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(speaker,
                            style: AppTextStyles.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                                fontSize: 11)),
                      ],
                    ),
                  ),

                  // Play/Pause
                  GestureDetector(
                    onTap: onPlayPause,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.primaryLight
                            : AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sp2),

                  // Close
                  GestureDetector(
                    onTap: onClose,
                    child: Icon(Icons.close,
                        size: 18,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textDisabled),
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


