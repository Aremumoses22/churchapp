import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/models/sermon.dart';
import '../../core/providers/sermon_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  const VideoPlayerScreen({
    super.key,
    this.sermonId,
    this.sermonTitle,
    this.sermonSpeaker,
    this.videoUrl,
  });

  final String? sermonId;
  final String? sermonTitle;
  final String? sermonSpeaker;
  final String? videoUrl;

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen>
    with SingleTickerProviderStateMixin {
  bool _isFullscreen = false;
  String _title = '';
  String _speaker = '';
  String _dateViews = '';
  List<Sermon> _relatedSermons = [];

  String? _resolvedVideoUrl;
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _title = widget.sermonTitle ?? '';
    _speaker = widget.sermonSpeaker ?? '';
    if (widget.videoUrl != null) {
      _setVideoUrl(widget.videoUrl!);
    }
    _loadSermonDetails();
  }

  void _setVideoUrl(String url) {
    _resolvedVideoUrl = url;
    final youtubeId = _extractYouTubeId(url);
    if (youtubeId != null) {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..loadRequest(Uri.parse(
          'https://www.youtube.com/embed/$youtubeId?autoplay=1&playsinline=1&rel=0',
        ));
    }
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
          _speaker = s.speaker;
          _dateViews = '${s.dateFormatted} · ${s.playCount} plays';
          if (s.videoUrl != null && _resolvedVideoUrl == null) {
            _setVideoUrl(s.videoUrl!);
          }
        });
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
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

  // Extract YouTube video ID from any YouTube URL format
  static String? _extractYouTubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains('youtube.com') || uri.host.contains('youtube-nocookie.com')) {
      // Handle /embed/ID format
      if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'embed') {
        return uri.pathSegments[1];
      }
      // Handle watch?v=ID format (including live streams)
      return uri.queryParameters['v'];
    }
    if (uri.host == 'youtu.be') {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // ── Video Player Area ──────────────────────────────────────────
          _isFullscreen
              ? Expanded(child: _buildVideoArea(isDark))
              : AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _buildVideoArea(isDark),
                ),

          // ── Info & Related (portrait only) ─────────────────────────────
          if (!_isFullscreen)
            Expanded(
              child: Container(
                color: isDark ? AppColors.bgDark : AppColors.warmWhite,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: AppSpacing.sp2),
                            Text(
                              _title.isNotEmpty ? _title : 'Sermon',
                              style: AppTextStyles.headingMedium.copyWith(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sp2),
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _speaker.isNotEmpty ? _speaker[0] : 'S',
                                      style: const TextStyle(
                                        color: AppColors.textInverse,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sp2),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _speaker.isNotEmpty ? _speaker : 'Unknown Speaker',
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      _dateViews,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontalPadding),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _VideoAction(icon: Icons.bookmark_outline, label: 'Save', isDark: isDark),
                              const SizedBox(width: AppSpacing.sp4),
                              _VideoAction(icon: Icons.edit_note_outlined, label: 'Notes', isDark: isDark),
                              const SizedBox(width: AppSpacing.sp4),
                              _VideoAction(icon: Icons.share_outlined, label: 'Share', isDark: isDark),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sp4),
                      Container(height: 8, color: isDark ? AppColors.cardDark : AppColors.inputFill),

                      if (_relatedSermons.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Up Next', style: AppTextStyles.headingSmall.copyWith(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              )),
                              const SizedBox(height: AppSpacing.sp3),
                              ..._relatedSermons.map((s) => _SermonTile(sermon: s, isDark: isDark)),
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
    // Real YouTube/WebView player
    if (_webViewController != null) {
      return Stack(
        children: [
          WebViewWidget(controller: _webViewController!),
          // Top controls overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.5), Colors.transparent],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: _toggleFullscreen,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Loading state while fetching sermon details
    if (widget.sermonId != null && _resolvedVideoUrl == null) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    // No video URL available — placeholder
    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam_off, size: 64, color: Colors.white.withValues(alpha: 0.3)),
                  const SizedBox(height: AppSpacing.sp2),
                  Text('No video available', style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.3),
                  )),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _VideoAction extends StatelessWidget {
  const _VideoAction({required this.icon, required this.label, required this.isDark});
  final IconData icon;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.bodySmall.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        )),
      ],
    );
  }
}

class _SermonTile extends StatelessWidget {
  const _SermonTile({required this.sermon, required this.isDark});
  final Sermon sermon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sp3),
      child: AppTapAnimation(
        onTap: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => VideoPlayerScreen(
                sermonId: sermon.id,
                sermonTitle: sermon.title,
                sermonSpeaker: sermon.speaker,
                videoUrl: sermon.videoUrl,
              ),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: 120,
              height: 68,
              decoration: BoxDecoration(
                image: sermon.thumbnailUrl != null
                    ? DecorationImage(image: NetworkImage(sermon.thumbnailUrl!), fit: BoxFit.cover)
                    : null,
                gradient: sermon.thumbnailUrl == null
                    ? const LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)])
                    : null,
                borderRadius: AppRadius.borderRadiusSm,
              ),
              child: const Center(child: Icon(Icons.play_arrow, color: Colors.white70, size: 28)),
            ),
            const SizedBox(width: AppSpacing.sp3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sermon.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  Text(sermon.speaker,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
