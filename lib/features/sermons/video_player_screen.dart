import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// VIDEO PLAYER SCREEN
//
// Full-screen video with landscape support, quality selector,
// picture-in-picture support, Chromecast button.
// ──────────────────────────────────────────────────────────────────────────────

class VideoPlayerScreen extends StatefulWidget {
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
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with SingleTickerProviderStateMixin {
  // ── Online demo video – replace with your sermon CDN URL ──────────────────
  static const _videoUrl =
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  String _selectedQuality = '1080p';
  static const _qualities = ['Auto', '1080p', '720p', '480p', '360p'];

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _videoController =
        VideoPlayerController.networkUrl(Uri.parse(_videoUrl));
    await _videoController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: false,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      showOptions: false,
      materialProgressColors: ChewieProgressColors(
        playedColor: AppColors.gold,
        handleColor: AppColors.gold,
        backgroundColor: Colors.white24,
        bufferedColor: Colors.white38,
      ),
      placeholder: Container(color: Colors.black),
      errorBuilder: (context, errorMessage) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 48),
            const SizedBox(height: 8),
            Text(errorMessage,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // ── Video Player Area ────────────────────────────────────────────
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _chewieController != null
                ? Chewie(controller: _chewieController!)
                : Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.gold,
                      ),
                    ),
                  ),
          ),

          // ── Info & Related Content ───────────────────────────────────────
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
                            widget.sermonTitle ?? 'Walking in Faith',
                            style: AppTextStyles.headingMedium.copyWith(
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
                                    'D',
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
                                      widget.sermonSpeaker ??
                                          'Pastor David Mitchell',
                                      style: AppTextStyles.labelMedium
                                          .copyWith(
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Jan 12, 2025 · 1.2K views',
                                      style: AppTextStyles.bodySmall
                                          .copyWith(
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
                            _VideoAction(                                icon: Icons.hd_outlined,
                                label: _selectedQuality,
                                isDark: isDark,
                                onTap: _showQualitySelector,
                              ),
                              const SizedBox(width: AppSpacing.sp4),
                              _VideoAction(                              icon: Icons.bookmark_outline,
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
                            style: AppTextStyles.headingSmall.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sp3),
                          ..._relatedSermons.map(
                            (s) => _RelatedSermonTile(
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

  void _showQualitySelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.sp4,
          right: AppSpacing.sp4,
          top: AppSpacing.sp4,
          bottom: AppSpacing.sp4 + MediaQuery.of(ctx).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Video Quality',
              style: AppTextStyles.headingSmall.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sp3),
            ..._qualities.map((q) => ListTile(
                  title: Text(q,
                      style: TextStyle(
                        color: _selectedQuality == q
                            ? (isDark ? AppColors.primaryLight : AppColors.primary)
                            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                        fontWeight: _selectedQuality == q ? FontWeight.w600 : FontWeight.w400,
                      )),
                  trailing: _selectedQuality == q
                      ? Icon(Icons.check,
                          color: isDark ? AppColors.primaryLight : AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() => _selectedQuality = q);
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }

  // Related sermons data
  static const _relatedSermons = [
    _RelatedSermon(
      title: 'The Power of Prayer',
      speaker: 'Pastor Sarah Chen',
      duration: '38 min',
      views: '892 views',
    ),
    _RelatedSermon(
      title: 'Grace Upon Grace',
      speaker: 'Pastor David Mitchell',
      duration: '45 min',
      views: '1.4K views',
    ),
    _RelatedSermon(
      title: 'Finding Purpose',
      speaker: 'Rev. James Williams',
      duration: '36 min',
      views: '756 views',
    ),
  ];
}

// ──────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ──────────────────────────────────────────────────────────────────────────────

class _RelatedSermon {
  const _RelatedSermon({
    required this.title,
    required this.speaker,
    required this.duration,
    required this.views,
  });

  final String title;
  final String speaker;
  final String duration;
  final String views;
}

// ──────────────────────────────────────────────────────────────────────────────
// PRIVATE SUB-WIDGETS
// ──────────────────────────────────────────────────────────────────────────────

class _VideoAction extends StatelessWidget {
  const _VideoAction({
    required this.icon,
    required this.label,
    required this.isDark,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: onTap ?? () {},
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

class _RelatedSermonTile extends StatelessWidget {
  const _RelatedSermonTile({
    required this.sermon,
    required this.isDark,
  });

  final _RelatedSermon sermon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sp3),
      child: AppTapAnimation(
        onTap: () {
          // TODO: play related sermon
        },
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 120,
              height: 68,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1A1A2E),
                    Color(0xFF0F3460),
                  ],
                ),
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
                        sermon.duration,
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
                    sermon.speaker,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    sermon.views,
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
