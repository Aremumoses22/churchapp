import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/sermon.dart';
import '../../core/providers/sermon_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// VIDEO PLAYER SCREEN
//
// Full-screen video with landscape support, quality selector,
// picture-in-picture support, Chromecast button.
// ──────────────────────────────────────────────────────────────────────────────

class VideoPlayerScreen extends ConsumerStatefulWidget {
  const VideoPlayerScreen({
    super.key,
    this.sermonId,
    this.sermonTitle,
    this.sermonSpeaker,
  });

  final String? sermonId;
  final String? sermonTitle;
  final String? sermonSpeaker;

  @override
  ConsumerState<VideoPlayerScreen> createState() =>
      _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  bool _controlsVisible = true;
  bool _isFullscreen = false;
  double _progress = 0.0;
  String _selectedQuality = '1080p';
  late AnimationController _controlsFadeController;
  late Animation<double> _controlsFade;

  // Resolved from API
  String _title = '';
  String _speaker = '';
  int _totalSeconds = 0;
  String _dateViews = '';

  static const _qualities = ['Auto', '1080p', '720p', '480p', '360p'];

  @override
  void initState() {
    super.initState();
    _controlsFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1.0,
    );
    _controlsFade = CurvedAnimation(
      parent: _controlsFadeController,
      curve: Curves.easeOut,
    );
    _title = widget.sermonTitle ?? '';
    _speaker = widget.sermonSpeaker ?? '';
    _loadSermonDetails();
  }

  Future<void> _loadSermonDetails() async {
    if (widget.sermonId == null) return;
    try {
      final repo = ref.read(sermonRepositoryProvider);
      final res = await repo.getSermon(widget.sermonId!);
      if (res.success && res.data != null && mounted) {
        final s = res.data!;
        setState(() {
          _title = s.title;
          _speaker = s.speaker ?? _speaker;
          _totalSeconds = s.duration ?? 0;
          _dateViews =
              '${s.dateFormatted} · ${s.playCount ?? 0} plays';
        });
        // Load related sermons (featured list excluding current)
        try {
          final featRes = await repo.getFeatured();
          if (featRes.success && featRes.data != null && mounted) {
            setState(() {
              _relatedSermons = featRes.data!
                  .where((r) => r.id != widget.sermonId)
                  .take(5)
                  .toList();
            });
          }
        } catch (_) {}
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _controlsFadeController.dispose();
    // Restore portrait orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _togglePlayPause() {
    HapticFeedback.lightImpact();
    setState(() => _isPlaying = !_isPlaying);
    // Auto-hide controls after 3 seconds while playing
    if (_isPlaying) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isPlaying) {
          _controlsFadeController.reverse();
          setState(() => _controlsVisible = false);
        }
      });
    }
  }

  void _toggleControls() {
    setState(() {
      _controlsVisible = !_controlsVisible;
      if (_controlsVisible) {
        _controlsFadeController.forward();
        // Auto-hide after 3s if playing
        if (_isPlaying) {
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted && _isPlaying && _controlsVisible) {
              _controlsFadeController.reverse();
              setState(() => _controlsVisible = false);
            }
          });
        }
      } else {
        _controlsFadeController.reverse();
      }
    });
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // ── Video Player Area ────────────────────────────────────────────
          Expanded(
            flex: _isFullscreen ? 1 : 0,
            child: _isFullscreen
                ? _buildVideoArea(isDark)
                : AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _buildVideoArea(isDark),
                  ),
          ),

          // ── Info & Related Content (portrait only) ───────────────────────
          if (!_isFullscreen)
            Expanded(
              child: Container(
                color: isDark ? AppColors.bgDark : AppColors.warmWhite,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Sermon Info ──────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.all(
                          AppSpacing.screenHorizontalPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: AppSpacing.sp2),
                            Text(
                              _title.isNotEmpty ? _title : 'Sermon',
                              style:
                                  AppTextStyles.headingMedium.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sp2),
                            Row(
                              children: [
                                // Speaker avatar
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDark
                                        ? AppColors.primaryLight
                                        : AppColors.primary,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '',
                                      style: TextStyle(
                                        color: AppColors.textInverse,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sp2),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _speaker.isNotEmpty
                                            ? _speaker
                                            : 'Unknown Speaker',
                                        style: AppTextStyles.labelMedium
                                            .copyWith(
                                          color: isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        _dateViews.isNotEmpty
                                            ? _dateViews
                                            : '',
                                        style: AppTextStyles.bodySmall
                                            .copyWith(
                                          color: isDark
                                              ? AppColors
                                                  .textSecondaryDark
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ── Action Row ──────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontalPadding,
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _VideoAction(
                                icon: Icons.bookmark_outline,
                                label: 'Save',
                                isDark: isDark,
                              ),
                              const SizedBox(width: AppSpacing.sp4),
                              _VideoAction(
                                icon: Icons.edit_note_outlined,
                                label: 'Notes',
                                isDark: isDark,
                              ),
                              const SizedBox(width: AppSpacing.sp4),
                              _VideoAction(
                                icon: Icons.share_outlined,
                                label: 'Share',
                                isDark: isDark,
                              ),
                              const SizedBox(width: AppSpacing.sp4),
                              _VideoAction(
                                icon: Icons.download_outlined,
                                label: 'Download',
                                isDark: isDark,
                              ),
                              const SizedBox(width: AppSpacing.sp4),
                              _VideoAction(
                                icon: Icons.headphones_outlined,
                                label: 'Audio Only',
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sp4),

                      // Divider
                      Container(
                        height: 8,
                        color: isDark
                            ? AppColors.cardDark
                            : AppColors.inputFill,
                      ),

                      // ── Related Sermons ──────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.all(
                          AppSpacing.screenHorizontalPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Up Next',
                              style:
                                  AppTextStyles.headingSmall.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sp3),
                            ..._relatedSermons.map(
                              (s) => _SermonTile(
                                sermon: s,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sp12),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoArea(bool isDark) {
    return GestureDetector(
      onTap: _toggleControls,
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video placeholder with gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1A1A2E),
                    Color(0xFF16213E),
                    Color(0xFF0F3460),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: AppSpacing.sp2),
                    Text(
                      'Video Player',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Controls overlay
            FadeTransition(
              opacity: _controlsFade,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top controls
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sp4,
                          vertical: AppSpacing.sp2,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            if (!_isFullscreen)
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    Navigator.of(context).pop(),
                              )
                            else
                              const SizedBox(width: 48),
                            Row(
                              children: [
                                // Chromecast button
                                IconButton(
                                  icon: const Icon(
                                    Icons.cast,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    _showCastDialog();
                                  },
                                  tooltip: 'Cast',
                                ),
                                // PiP button
                                IconButton(
                                  icon: const Icon(
                                    Icons
                                        .picture_in_picture_alt_outlined,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    // TODO: enter PiP mode
                                  },
                                  tooltip: 'Picture in Picture',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Center play/pause
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Rewind
                          IconButton(
                            icon: const Icon(
                              Icons.replay_10,
                              color: Colors.white,
                              size: 36,
                            ),
                            onPressed: () {
                              setState(() {
                                _progress = (_progress -
                                        (_totalSeconds > 0
                                            ? 10 / _totalSeconds
                                            : 0.0))
                                    .clamp(0.0, 1.0);
                              });
                            },
                          ),
                          const SizedBox(width: AppSpacing.sp8),
                          // Play / Pause
                          GestureDetector(
                            onTap: _togglePlayPause,
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white
                                    .withValues(alpha: 0.2),
                              ),
                              child: Icon(
                                _isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sp8),
                          // Forward
                          IconButton(
                            icon: const Icon(
                              Icons.forward_30,
                              color: Colors.white,
                              size: 36,
                            ),
                            onPressed: () {
                              setState(() {
                                _progress = (_progress +
                                        (_totalSeconds > 0
                                            ? 30 / _totalSeconds
                                            : 0.0))
                                    .clamp(0.0, 1.0);
                              });
                            },
                          ),
                        ],
                      ),

                      // Bottom controls (scrubber + info)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sp4,
                        ),
                        child: Column(
                          children: [
                            // Scrubber
                            SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 3,
                                thumbShape:
                                    const RoundSliderThumbShape(
                                  enabledThumbRadius: 6,
                                ),
                                overlayShape:
                                    const RoundSliderOverlayShape(
                                  overlayRadius: 14,
                                ),
                                activeTrackColor: AppColors.gold,
                                inactiveTrackColor:
                                    Colors.white.withValues(alpha: 0.3),
                                thumbColor: AppColors.gold,
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
                                    _formatDuration(
                                        Duration(
                                            seconds:
                                                (_totalSeconds *
                                                        _progress)
                                                    .round())),
                                    style: AppTextStyles.bodySmall
                                        .copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      // Quality selector
                                      GestureDetector(
                                        onTap: _showQualitySelector,
                                        child: Container(
                                          padding:
                                              const EdgeInsets
                                                  .symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.white54,
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius
                                                    .circular(4),
                                          ),
                                          child: Text(
                                            _selectedQuality,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight:
                                                  FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sp3),
                                      // Fullscreen toggle
                                      GestureDetector(
                                        onTap: _toggleFullscreen,
                                        child: Icon(
                                          _isFullscreen
                                              ? Icons
                                                  .fullscreen_exit
                                              : Icons.fullscreen,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    _formatDuration(
                                        Duration(
                                            seconds:
                                                _totalSeconds)),
                                    style: AppTextStyles.bodySmall
                                        .copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sp2),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQualitySelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              'Video Quality',
              style: AppTextStyles.headingSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sp4),
            ..._qualities.map((q) => AppTapAnimation(
                  onTap: () {
                    setState(() => _selectedQuality = q);
                    Navigator.pop(ctx);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sp3,
                    ),
                    child: Row(
                      children: [
                        Text(
                          q,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: _selectedQuality == q
                                ? (isDark
                                    ? AppColors.primaryLight
                                    : AppColors.primary)
                                : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary),
                            fontWeight: _selectedQuality == q
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        if (q == 'Auto')
                          Text(
                            '  (Recommended)',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        const Spacer(),
                        if (_selectedQuality == q)
                          Icon(
                            Icons.check,
                            size: 20,
                            color: isDark
                                ? AppColors.primaryLight
                                : AppColors.primary,
                          ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _showCastDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              'Cast to Device',
              style: AppTextStyles.headingSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sp5),
            // Searching indicator
            Column(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark
                          ? AppColors.primaryLight
                          : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sp4),
                Text(
                  'Searching for devices...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sp2),
                Text(
                  'Make sure your device is on the same Wi-Fi network',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textDisabled,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sp6),
          ],
        ),
      ),
    );
  }

  List<Sermon> _relatedSermons = [];
}

// ──────────────────────────────────────────────────────────────────────────────
// PRIVATE SUB-WIDGETS
// ──────────────────────────────────────────────────────────────────────────────

class _VideoAction extends StatelessWidget {
  const _VideoAction({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: () {
        // TODO: action handler
      },
      child: Column(
        children: [
          Icon(
            icon,
            size: 22,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimary,
          ),
          const SizedBox(height: 4),
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

class _SermonTile extends StatelessWidget {
  const _SermonTile({
    required this.sermon,
    required this.isDark,
  });

  final Sermon sermon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sp3),
      child: AppTapAnimation(
        onTap: () {
          // Navigate to this sermon's video
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => VideoPlayerScreen(
                sermonId: sermon.id,
                sermonTitle: sermon.title,
                sermonSpeaker: sermon.speaker,
              ),
            ),
          );
        },
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 120,
              height: 68,
              decoration: BoxDecoration(
                image: sermon.thumbnailUrl != null
                    ? DecorationImage(
                        image: NetworkImage(sermon.thumbnailUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
                gradient: sermon.thumbnailUrl == null
                    ? const LinearGradient(
                        colors: [
                          Color(0xFF1A1A2E),
                          Color(0xFF0F3460),
                        ],
                      )
                    : null,
                borderRadius: AppRadius.borderRadiusSm,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 28,
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        sermon.durationFormatted,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sp3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sermon.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sermon.speaker ?? 'Unknown',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${sermon.playCount ?? 0} plays',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.more_vert,
                size: 20,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textDisabled,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
