import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SERMON DETAIL SCREEN — § 8.6
//
// Full-width thumbnail → overlapping white card → title / speaker / actions →
// sermon notes → related sermons. Sticky audio player bar at the bottom.
// ──────────────────────────────────────────────────────────────────────────────

class SermonDetailScreen extends StatefulWidget {
  const SermonDetailScreen({super.key, required this.sermonId});

  final String sermonId;

  @override
  State<SermonDetailScreen> createState() => _SermonDetailScreenState();
}

class _SermonDetailScreenState extends State<SermonDetailScreen> {
  bool _isPlaying = false;
  bool _isBookmarked = false;
  double _progress = 0.3;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: CustomScrollView(
              slivers: [
                // ── Hero image ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      Container(
                        height: 250,
                        width: double.infinity,
                        color: isDark ? AppColors.skyDark : AppColors.skyLight,
                        child: Icon(Icons.headphones, size: 64,
                            color: isDark
                                ? AppColors.primaryLight
                                : AppColors.primary),
                      ),
                      // Back button
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: AppSpacing.sp4,
                        child: AppIconButton(
                          icon: Icons.arrow_back,
                          onPressed: () => context.pop(),
                          semanticLabel: 'Go back',
                        ),
                      ),
                      // Share button
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        right: AppSpacing.sp4,
                        child: AppIconButton(
                          icon: Icons.share_outlined,
                          onPressed: () {},
                          semanticLabel: 'Share',
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Content card overlapping image ────────────────────
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : AppColors.surface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppRadius.xl),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.sp4, AppSpacing.sp6,
                        AppSpacing.sp4, AppSpacing.sp4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Series tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.goldLight.withValues(alpha: 0.3),
                              borderRadius: AppRadius.borderRadiusXs,
                            ),
                            child: Text('Faith Series',
                                style: AppTextStyles.labelSmall
                                    .copyWith(color: AppColors.gold)),
                          ),
                          const SizedBox(height: AppSpacing.sp3),

                          // Title
                          Text(
                            'The Power of Faith',
                            style: AppTextStyles.displayMedium.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sp2),

                          // Speaker + date
                          Text(
                            'Pastor James \u00b7 Feb 23, 2026',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sp4),

                          // Action row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _ActionIcon(
                                icon: Icons.play_circle_outlined,
                                label: 'Play',
                                isDark: isDark,
                                onTap: () =>
                                    setState(() => _isPlaying = !_isPlaying),
                              ),
                              _ActionIcon(
                                icon: Icons.download_outlined,
                                label: 'Download',
                                isDark: isDark,
                                onTap: () {},
                              ),
                              _ActionIcon(
                                icon: Icons.share_outlined,
                                label: 'Share',
                                isDark: isDark,
                                onTap: () {},
                              ),
                              _ActionIcon(
                                icon: _isBookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                label: 'Save',
                                isDark: isDark,
                                isActive: _isBookmarked,
                                onTap: () => setState(
                                    () => _isBookmarked = !_isBookmarked),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sp4),
                          const AppDivider(),

                          // Sermon notes section
                          const SizedBox(height: AppSpacing.sp4),
                          Text(
                            'Sermon Notes',
                            style: AppTextStyles.headingSmall.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sp3),
                          Text(
                            'Faith is the substance of things hoped for, the evidence of things not seen. In this powerful message, Pastor James explores what it means to walk by faith and not by sight.\n\n'
                            'Key Points:\n'
                            '\u2022 Faith begins where understanding ends\n'
                            '\u2022 God honors persistent faith\n'
                            '\u2022 Your faith journey is personal and unique\n'
                            '\u2022 Community strengthens individual faith\n\n'
                            'Scripture References: Hebrews 11:1, 2 Corinthians 5:7, Matthew 17:20',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sp6),
                          const AppDivider(),

                          // Related sermons
                          const SizedBox(height: AppSpacing.sp4),
                          Text(
                            'Related Sermons',
                            style: AppTextStyles.headingSmall.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sp3),
                        ],
                      ),
                    ),
                  ),
                ),

                // Related sermons list
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sp4),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      AppFeatureCard(
                        title: 'Walking in Grace',
                        subtitle: 'Pastor James \u00b7 38 min',
                        onTap: () {},
                      ),
                      const SizedBox(height: AppSpacing.sp3),
                      AppFeatureCard(
                        title: 'Love Without Limits',
                        subtitle: 'Pastor James \u00b7 39 min',
                        onTap: () {},
                      ),
                      const SizedBox(height: AppSpacing.sp8),
                    ]),
                  ),
                ),
              ],
            ),
          ),

          // ── Sticky audio player bar ─────────────────────────────────
          _AudioPlayerBar(
            isDark: isDark,
            isPlaying: _isPlaying,
            progress: _progress,
            onPlayPause: () => setState(() => _isPlaying = !_isPlaying),
            onProgressChanged: (v) => setState(() => _progress = v),
          ),
        ],
      ),
    );
  }
}

// ── Action icon button ───────────────────────────────────────────────────────

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? AppColors.gold
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary);

    return AppTapAnimation(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? AppColors.skyDark : AppColors.skyLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: AppTextStyles.bodySmall.copyWith(color: color)),
        ],
      ),
    );
  }
}

// ── Audio player bar ─────────────────────────────────────────────────────────

class _AudioPlayerBar extends StatelessWidget {
  const _AudioPlayerBar({
    required this.isDark,
    required this.isPlaying,
    required this.progress,
    required this.onPlayPause,
    required this.onProgressChanged,
  });

  final bool isDark;
  final bool isPlaying;
  final double progress;
  final VoidCallback onPlayPause;
  final ValueChanged<double> onProgressChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surface,
        boxShadow: AppShadows.lg,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress scrubber
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                activeTrackColor:
                    isDark ? AppColors.primaryLight : AppColors.primary,
                inactiveTrackColor: isDark ? AppColors.skyDark : AppColors.inactive,
                thumbColor: AppColors.gold,
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                value: progress,
                onChanged: onProgressChanged,
              ),
            ),

            // Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sp4, 0, AppSpacing.sp4, AppSpacing.sp2,
              ),
              child: Row(
                children: [
                  // Time
                  Text(
                    '12:36',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  // Rewind 15s
                  AppTapAnimation(
                    onTap: () {},
                    child: Icon(Icons.replay_10, size: 28,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary),
                  ),
                  const SizedBox(width: AppSpacing.sp4),
                  // Play / Pause
                  AppTapAnimation(
                    onTap: onPlayPause,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color:
                            isDark ? AppColors.primaryLight : AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: AppColors.textInverse,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sp4),
                  // Forward 15s
                  AppTapAnimation(
                    onTap: () {},
                    child: Icon(Icons.forward_10, size: 28,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary),
                  ),
                  const Spacer(),
                  // Duration
                  Text(
                    '42:00',
                    style: AppTextStyles.bodySmall.copyWith(
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
      ),
    );
  }
}
