import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// FULL AUDIO PLAYER SCREEN
//
// Expanded from the mini-player bar: full-screen with large artwork,
// scrubber, speed control (0.5×–2×), sleep timer, queue/up-next list.
// ──────────────────────────────────────────────────────────────────────────────

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({
    super.key,
    this.sermonId,
    this.sermonTitle,
    this.sermonSpeaker,
    this.sermonSeries,
  });

  final String? sermonId;
  final String? sermonTitle;
  final String? sermonSpeaker;
  final String? sermonSeries;

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  double _progress = 0.35;
  double _playbackSpeed = 1.0;
  int? _sleepTimerMinutes;
  late AnimationController _playPauseController;

  // Mock data
  final _currentPosition = const Duration(minutes: 14, seconds: 48);
  final _totalDuration = const Duration(minutes: 42, seconds: 15);

  // Queue
  final _queue = const [
    _QueueItem(
      title: 'The Power of Prayer',
      speaker: 'Pastor Sarah Chen',
      duration: '38 min',
    ),
    _QueueItem(
      title: 'Grace Upon Grace',
      speaker: 'Pastor David Mitchell',
      duration: '45 min',
    ),
    _QueueItem(
      title: 'Finding Purpose',
      speaker: 'Rev. James Williams',
      duration: '36 min',
    ),
  ];

  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  @override
  void initState() {
    super.initState();
    _playPauseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _playPauseController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    HapticFeedback.lightImpact();
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _playPauseController.forward();
    } else {
      _playPauseController.reverse();
    }
  }

  void _cycleSpeed() {
    HapticFeedback.lightImpact();
    final currentIndex = _speeds.indexOf(_playbackSpeed);
    final nextIndex = (currentIndex + 1) % _speeds.length;
    setState(() => _playbackSpeed = _speeds[nextIndex]);
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sp4,
                vertical: AppSpacing.sp3,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Collapse button
                  AppTapAnimation(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardDark
                            : AppColors.inputFill,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        'NOW PLAYING',
                        style: AppTextStyles.labelAllCaps.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                      if (widget.sermonSeries != null)
                        Text(
                          widget.sermonSeries ?? '',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark
                                ? AppColors.primaryLight
                                : AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                  // More options
                  AppTapAnimation(
                    onTap: () {
                      // TODO: more options
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardDark
                            : AppColors.inputFill,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.more_horiz,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.sp6),

                    // ── Artwork ────────────────────────────────────────────
                    Container(
                      width: screenWidth * 0.72,
                      height: screenWidth * 0.72,
                      decoration: BoxDecoration(
                        gradient: isDark
                            ? AppGradients.heroDark
                            : AppGradients.hero,
                        borderRadius: AppRadius.borderRadiusXl,
                        boxShadow: isDark
                            ? AppShadows.lgDark
                            : AppShadows.lg,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Decorative circles
                          Positioned(
                            top: 30,
                            right: 30,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.05),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 40,
                            left: 20,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.05),
                              ),
                            ),
                          ),
                          // Center content
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.headphones,
                                size: 64,
                                color: AppColors.gold,
                              ),
                              const SizedBox(height: AppSpacing.sp4),
                              Text(
                                'SERMON',
                                style: AppTextStyles.labelAllCaps.copyWith(
                                  color:
                                      Colors.white.withValues(alpha: 0.6),
                                  letterSpacing: 3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sp8),

                    // ── Title & Speaker ────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sp8,
                      ),
                      child: Column(
                        children: [
                          Text(
                            widget.sermonTitle ?? 'Walking in Faith',
                            style: AppTextStyles.headingLarge.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.sp2),
                          Text(
                            widget.sermonSpeaker ??
                                'Pastor David Mitchell',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sp8),

                    // ── Scrubber ───────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sp6,
                      ),
                      child: Column(
                        children: [
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 7,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 16,
                              ),
                              activeTrackColor: isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary,
                              inactiveTrackColor: isDark
                                  ? AppColors.borderDark
                                  : AppColors.inputFill,
                              thumbColor: isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary,
                            ),
                            child: Slider(
                              value: _progress,
                              onChanged: (val) {
                                setState(() => _progress = val);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sp2,
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(_currentPosition),
                                  style:
                                      AppTextStyles.bodySmall.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '-${_formatDuration(_totalDuration - _currentPosition)}',
                                  style:
                                      AppTextStyles.bodySmall.copyWith(
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

                    const SizedBox(height: AppSpacing.sp5),

                    // ── Playback Controls ──────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Speed control
                        AppTapAnimation(
                          onTap: _cycleSpeed,
                          child: Container(
                            width: 48,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.cardDark
                                  : AppColors.inputFill,
                              borderRadius: AppRadius.borderRadiusFull,
                            ),
                            child: Center(
                              child: Text(
                                '${_playbackSpeed}x',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: AppSpacing.sp5),

                        // Skip back 15s
                        AppTapAnimation(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _progress =
                                  (_progress - 15 / _totalDuration.inSeconds)
                                      .clamp(0.0, 1.0);
                            });
                          },
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.replay,
                                  size: 32,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                                Positioned(
                                  bottom: 8,
                                  child: Text(
                                    '15',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: AppSpacing.sp5),

                        // Play / Pause
                        AppTapAnimation(
                          onTap: _togglePlayPause,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: (isDark
                                          ? AppColors.primaryLight
                                          : AppColors.primary)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: AnimatedIcon(
                              icon: AnimatedIcons.play_pause,
                              progress: _playPauseController,
                              size: 36,
                              color: AppColors.textInverse,
                            ),
                          ),
                        ),

                        const SizedBox(width: AppSpacing.sp5),

                        // Skip forward 30s
                        AppTapAnimation(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _progress =
                                  (_progress + 30 / _totalDuration.inSeconds)
                                      .clamp(0.0, 1.0);
                            });
                          },
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..setEntry(0, 0, -1.0),
                                  child: Icon(
                                    Icons.replay,
                                    size: 32,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  child: Text(
                                    '30',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: AppSpacing.sp5),

                        // Sleep timer
                        AppTapAnimation(
                          onTap: () => _showSleepTimerSheet(),
                          child: Container(
                            width: 48,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _sleepTimerMinutes != null
                                  ? AppColors.gold.withValues(alpha: 0.15)
                                  : (isDark
                                      ? AppColors.cardDark
                                      : AppColors.inputFill),
                              borderRadius: AppRadius.borderRadiusFull,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.bedtime_outlined,
                                size: 18,
                                color: _sleepTimerMinutes != null
                                    ? AppColors.gold
                                    : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.sp8),

                    // ── Action Buttons ─────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sp6,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                        children: [
                          _ActionButton(
                            icon: Icons.bookmark_outline,
                            label: 'Save',
                            isDark: isDark,
                            onTap: () {
                              // TODO: save sermon
                            },
                          ),
                          _ActionButton(
                            icon: Icons.edit_note_outlined,
                            label: 'Notes',
                            isDark: isDark,
                            onTap: () {
                              // TODO: open sermon notes
                            },
                          ),
                          _ActionButton(
                            icon: Icons.share_outlined,
                            label: 'Share',
                            isDark: isDark,
                            onTap: () {
                              // TODO: share sermon
                            },
                          ),
                          _ActionButton(
                            icon: Icons.download_outlined,
                            label: 'Download',
                            isDark: isDark,
                            onTap: () {
                              // TODO: download sermon
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sp8),

                    // ── Up Next / Queue ────────────────────────────────────
                    if (_queue.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sp4,
                        ),
                        child: AppSectionHeader(
                          title: 'Up Next',
                          actionLabel: '${_queue.length} sermons',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sp3),
                      ..._queue.asMap().entries.map((entry) =>
                          _QueueItemTile(
                            item: entry.value,
                            index: entry.key + 1,
                            isDark: isDark,
                          )),
                      const SizedBox(height: AppSpacing.sp12),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSleepTimerSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final options = [5, 10, 15, 30, 45, 60];

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.sp6,
          right: AppSpacing.sp6,
          top: AppSpacing.sp6,
          bottom: AppSpacing.sp6 + MediaQuery.of(ctx).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : AppColors.inactive,
                borderRadius: AppRadius.borderRadiusFull,
              ),
            ),
            const SizedBox(height: AppSpacing.sp5),
            Text(
              'Sleep Timer',
              style: AppTextStyles.headingSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sp5),
            if (_sleepTimerMinutes != null) ...[
              AppTapAnimation(
                onTap: () {
                  setState(() => _sleepTimerMinutes = null);
                  Navigator.pop(ctx);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sp3,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.close, size: 20, color: AppColors.error),
                      const SizedBox(width: AppSpacing.sp3),
                      Text(
                        'Turn Off Timer',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                color: isDark ? AppColors.borderDark : AppColors.divider,
              ),
            ],
            ...options.map((min) => AppTapAnimation(
                  onTap: () {
                    setState(() => _sleepTimerMinutes = min);
                    Navigator.pop(ctx);
                    HapticFeedback.lightImpact();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sp3,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bedtime_outlined,
                          size: 20,
                          color: _sleepTimerMinutes == min
                              ? AppColors.gold
                              : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary),
                        ),
                        const SizedBox(width: AppSpacing.sp3),
                        Text(
                          '$min minutes',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: _sleepTimerMinutes == min
                                ? AppColors.gold
                                : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary),
                          ),
                        ),
                        const Spacer(),
                        if (_sleepTimerMinutes == min)
                          Icon(Icons.check, size: 20, color: AppColors.gold),
                      ],
                    ),
                  ),
                )),
            AppTapAnimation(
              onTap: () {
                // Set timer to end of current sermon
                Navigator.pop(ctx);
                HapticFeedback.lightImpact();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sp3,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.stop_circle_outlined,
                      size: 20,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                    const SizedBox(width: AppSpacing.sp3),
                    Text(
                      'End of sermon',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// DATA MODEL
// ──────────────────────────────────────────────────────────────────────────────

class _QueueItem {
  const _QueueItem({
    required this.title,
    required this.speaker,
    required this.duration,
  });

  final String title;
  final String speaker;
  final String duration;
}

// ──────────────────────────────────────────────────────────────────────────────
// PRIVATE SUB-WIDGETS
// ──────────────────────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.inputFill,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 22,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sp2),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueItemTile extends StatelessWidget {
  const _QueueItemTile({
    required this.item,
    required this.index,
    required this.isDark,
  });

  final _QueueItem item;
  final int index;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontalPadding,
        vertical: AppSpacing.sp2,
      ),
      child: Row(
        children: [
          // Index
          SizedBox(
            width: 24,
            child: Text(
              '$index',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textDisabled,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppSpacing.sp3),
          // Thumbnail
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: isDark
                  ? AppGradients.heroDark
                  : AppGradients.hero,
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: const Center(
              child: Icon(
                Icons.headphones,
                color: AppColors.textInverse,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sp3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.speaker} \u00B7 ${item.duration}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Reorder handle
          Icon(
            Icons.drag_handle,
            size: 20,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textDisabled,
          ),
        ],
      ),
    );
  }
}
