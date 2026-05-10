import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/sermon.dart';
import '../../core/providers/sermon_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SERMON DETAIL SCREEN — § 8.6
// ──────────────────────────────────────────────────────────────────────────────

class SermonDetailScreen extends ConsumerStatefulWidget {
  const SermonDetailScreen({super.key, required this.sermonId});
  final String sermonId;

  @override
  ConsumerState<SermonDetailScreen> createState() =>
      _SermonDetailScreenState();
}

class _SermonDetailScreenState extends ConsumerState<SermonDetailScreen> {
  bool _isPlaying = false;
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sermonAsync = ref.watch(sermonDetailProvider(widget.sermonId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      body: sermonAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: AppEmptyState(
            icon: Icons.error_outline,
            title: 'Failed to load sermon',
            subtitle: e.toString(),
            buttonLabel: 'Retry',
            onButtonPressed: () =>
                ref.invalidate(sermonDetailProvider(widget.sermonId)),
          ),
        ),
        data: (sermon) => _buildBody(sermon, isDark),
      ),
    );
  }

  Widget _buildBody(Sermon sermon, bool isDark) {
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              // ── Hero image ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    Container(
                      height: 250,
                      width: double.infinity,
                      color: isDark ? AppColors.skyDark : AppColors.skyLight,
                      child: sermon.thumbnailUrl != null
                          ? Image.network(sermon.thumbnailUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                  Icons.headphones,
                                  size: 64,
                                  color: isDark
                                      ? AppColors.primaryLight
                                      : AppColors.primary))
                          : Icon(Icons.headphones,
                              size: 64,
                              color: isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: AppSpacing.sp4,
                      child: AppIconButton(
                        icon: Icons.arrow_back,
                        onPressed: () => context.pop(),
                        semanticLabel: 'Go back',
                      ),
                    ),
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

              // ── Content card overlapping image ──────────────────────
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
                        if (sermon.series != null)
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sp3),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.goldLight.withValues(alpha: 0.3),
                                borderRadius: AppRadius.borderRadiusXs,
                              ),
                              child: Text(sermon.series!.title,
                                  style: AppTextStyles.labelSmall
                                      .copyWith(color: AppColors.gold)),
                            ),
                          ),

                        // Title
                        Text(
                          sermon.title,
                          style: AppTextStyles.displayMedium.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sp2),

                        // Speaker + date + duration
                        Text(
                          '${sermon.speaker ?? 'Unknown'} · ${sermon.dateFormatted}',
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
                              onTap: () {
                                setState(() => _isPlaying = !_isPlaying);
                                ref
                                    .read(sermonNotifierProvider.notifier)
                                    .setNowPlaying(sermon);
                              },
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
                              icon: sermon.isSaved
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              label: 'Save',
                              isDark: isDark,
                              isActive: sermon.isSaved,
                              onTap: () => ref
                                  .read(sermonNotifierProvider.notifier)
                                  .toggleSave(sermon.id),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sp4),
                        const AppDivider(),

                        // Description / Sermon Notes
                        if (sermon.description != null &&
                            sermon.description!.isNotEmpty) ...[
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
                            sermon.description!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sp6),
                          const AppDivider(),
                        ],

                        // Scripture reference
                        if (sermon.scriptureRef != null) ...[
                          const SizedBox(height: AppSpacing.sp3),
                          Row(
                            children: [
                              const Icon(Icons.menu_book,
                                  size: 16, color: AppColors.gold),
                              const SizedBox(width: 6),
                              Text(
                                sermon.scriptureRef!,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sp4),
                          const AppDivider(),
                        ],

                        // Related sermons header
                        if (sermon.series != null &&
                            sermon.series!.sermons
                                .where((s) => s.id != sermon.id)
                                .isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sp4),
                          Text(
                            'More from ${sermon.series!.title}',
                            style: AppTextStyles.headingSmall.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sp3),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Related sermons list
              if (sermon.series != null)
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final related = sermon.series!.sermons
                            .where((s) => s.id != sermon.id)
                            .toList();
                        if (i >= related.length) return null;
                        final rel = related[i];
                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.sp3),
                          child: AppFeatureCard(
                            title: rel.title,
                            subtitle:
                                '${rel.speaker ?? ''} · ${rel.durationFormatted}',
                            onTap: () => context.push('/sermons/${rel.id}'),
                          ),
                        );
                      },
                      childCount: sermon.series!.sermons
                          .where((s) => s.id != sermon.id)
                          .length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.sp8)),
            ],
          ),
        ),

        // ── Sticky audio player bar ─────────────────────────────────
        _AudioPlayerBar(
          isDark: isDark,
          isPlaying: _isPlaying,
          progress: _progress,
          durationLabel: sermon.durationFormatted,
          onPlayPause: () => setState(() => _isPlaying = !_isPlaying),
          onProgressChanged: (v) => setState(() => _progress = v),
        ),
      ],
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
    required this.durationLabel,
    required this.onPlayPause,
    required this.onProgressChanged,
  });

  final bool isDark;
  final bool isPlaying;
  final double progress;
  final String durationLabel;
  final VoidCallback onPlayPause;
  final ValueChanged<double> onProgressChanged;

  String _elapsed(double p) {
    final match = RegExp(r'(\d+)').firstMatch(durationLabel);
    final totalMin = match != null ? int.parse(match.group(1)!) : 0;
    final secs = (totalMin * 60 * p).round();
    final m = secs ~/ 60;
    final s = secs % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

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
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6),
                activeTrackColor:
                    isDark ? AppColors.primaryLight : AppColors.primary,
                inactiveTrackColor:
                    isDark ? AppColors.skyDark : AppColors.inactive,
                thumbColor: AppColors.gold,
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(value: progress, onChanged: onProgressChanged),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sp4, 0, AppSpacing.sp4, AppSpacing.sp2),
              child: Row(
                children: [
                  Text(_elapsed(progress),
                      style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary)),
                  const Spacer(),
                  AppTapAnimation(
                      onTap: () {},
                      child: Icon(Icons.replay_10,
                          size: 28,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary)),
                  const SizedBox(width: AppSpacing.sp4),
                  AppTapAnimation(
                    onTap: onPlayPause,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.primaryLight
                            : AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: AppColors.textInverse,
                          size: 28),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sp4),
                  AppTapAnimation(
                      onTap: () {},
                      child: Icon(Icons.forward_10,
                          size: 28,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary)),
                  const Spacer(),
                  Text(durationLabel,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
