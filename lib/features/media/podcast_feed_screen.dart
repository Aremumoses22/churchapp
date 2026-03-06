import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// PODCAST FEED SCREEN
//
// Sermon audio as podcast-style feed, subscribe button, auto-download
// new episodes, playback controls.
// ──────────────────────────────────────────────────────────────────────────────

class PodcastFeedScreen extends StatefulWidget {
  const PodcastFeedScreen({super.key});

  @override
  State<PodcastFeedScreen> createState() => _PodcastFeedScreenState();
}

class _PodcastFeedScreenState extends State<PodcastFeedScreen> {
  bool _subscribed = false;
  bool _autoDownload = false;
  int? _playingIndex;

  static final _episodes = [
    _EpisodeData(
      title: 'Walking by Faith, Not by Sight',
      series: 'Faith Foundations',
      speaker: 'Pastor James',
      date: DateTime.now().subtract(const Duration(days: 1)),
      duration: '42:15',
      durationMinutes: 42,
      description:
          'An in-depth exploration of 2 Corinthians 5:7 and what it means to live a faith-driven life even when the path ahead is unclear.',
      downloaded: true,
      played: false,
    ),
    _EpisodeData(
      title: 'The Power of Prayer',
      series: 'Faith Foundations',
      speaker: 'Pastor James',
      date: DateTime.now().subtract(const Duration(days: 8)),
      duration: '38:30',
      durationMinutes: 38,
      description:
          'Discover how prayer transforms our relationship with God and how to build a consistent prayer life.',
      downloaded: true,
      played: true,
    ),
    _EpisodeData(
      title: 'Grace Upon Grace',
      series: 'Unmerited Favor',
      speaker: 'Pastor Sarah',
      date: DateTime.now().subtract(const Duration(days: 15)),
      duration: '45:00',
      durationMinutes: 45,
      description:
          'Understanding the depth of God\'s grace and how it covers every area of our lives.',
      downloaded: false,
      played: false,
    ),
    _EpisodeData(
      title: 'Community & Connection',
      series: 'Better Together',
      speaker: 'Pastor David',
      date: DateTime.now().subtract(const Duration(days: 22)),
      duration: '35:45',
      durationMinutes: 35,
      description:
          'Why God designed us for community and how small groups can transform our spiritual growth.',
      downloaded: false,
      played: true,
    ),
    _EpisodeData(
      title: 'Anchored in Hope',
      series: 'Unshakeable',
      speaker: 'Pastor James',
      date: DateTime.now().subtract(const Duration(days: 29)),
      duration: '40:20',
      durationMinutes: 40,
      description:
          'Finding unshakeable hope in uncertain times through the promises of Scripture.',
      downloaded: false,
      played: true,
    ),
    _EpisodeData(
      title: 'Renewed Mind',
      series: 'Transformation',
      speaker: 'Pastor Sarah',
      date: DateTime.now().subtract(const Duration(days: 36)),
      duration: '44:10',
      durationMinutes: 44,
      description:
          'Romans 12:2 teaches us about the transformative power of renewing our minds with God\'s Word.',
      downloaded: false,
      played: true,
    ),
    _EpisodeData(
      title: 'The Heart of Worship',
      series: 'Worship Series',
      speaker: 'Pastor David',
      date: DateTime.now().subtract(const Duration(days: 43)),
      duration: '37:55',
      durationMinutes: 37,
      description:
          'What does it truly mean to worship God in spirit and truth? A deep dive into authentic worship.',
      downloaded: false,
      played: true,
    ),
  ];

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return '${_monthNames[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Podcast',
        showBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: Colors.white, size: 20),
            onPressed: () => _showSettingsSheet(context, isDark),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Podcast header ───────────────────────────────────────
          Container(
            margin: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
            padding: const EdgeInsets.all(AppSpacing.sp4),
            decoration: BoxDecoration(
              gradient: AppGradients.hero,
              borderRadius: AppRadius.borderRadiusLg,
            ),
            child: Row(
              children: [
                // Podcast art placeholder
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.podcasts,
                          size: 32,
                          color: Colors.white.withValues(alpha: 0.9)),
                      const SizedBox(height: 2),
                      Text('GRACE',
                          style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 8,
                              letterSpacing: 2)),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sp4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Grace Community\nPodcast',
                          style: AppTextStyles.headingSmall
                              .copyWith(color: Colors.white, height: 1.2)),
                      const SizedBox(height: 6),
                      Text('${_episodes.length} episodes • Weekly',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 11)),
                      const SizedBox(height: AppSpacing.sp3),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _subscribed = !_subscribed),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sp3, vertical: 5),
                          decoration: BoxDecoration(
                            color: _subscribed
                                ? Colors.white.withValues(alpha: 0.2)
                                : AppColors.gold,
                            borderRadius: AppRadius.borderRadiusFull,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _subscribed
                                    ? Icons.check
                                    : Icons.add,
                                size: 14,
                                color: _subscribed
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _subscribed ? 'Subscribed' : 'Subscribe',
                                style: AppTextStyles.labelSmall.copyWith(
                                    color: _subscribed
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Episode list ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontalPadding),
            child: AppSectionHeader(
              title: 'Episodes',
              actionLabel: '${_episodes.length} total',
              onAction: () {},
            ),
          ),

          const SizedBox(height: AppSpacing.sp2),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding),
              itemCount: _episodes.length,
              itemBuilder: (context, i) {
                final ep = _episodes[i];
                final isPlaying = _playingIndex == i;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sp3),
                  child: AppTapAnimation(
                    onTap: () => _showEpisodeSheet(context, ep, i, isDark),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sp4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : AppColors.surface,
                        borderRadius: AppRadius.borderRadiusLg,
                        boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
                        border: isPlaying
                            ? Border.all(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                width: 1.5)
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!ep.played)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 4),
                                        child: Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    Text(ep.title,
                                        style: AppTextStyles.bodyLargeSemiBold
                                            .copyWith(
                                                color: isDark
                                                    ? AppColors.textPrimaryDark
                                                    : AppColors.textPrimary)),
                                    const SizedBox(height: 4),
                                    Text(ep.series,
                                        style: AppTextStyles.bodySmall
                                            .copyWith(
                                                color: isDark
                                                    ? AppColors.primaryLight
                                                    : AppColors.primary,
                                                fontSize: 11)),
                                  ],
                                ),
                              ),
                              // Play button
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _playingIndex =
                                        isPlaying ? null : i;
                                  });
                                },
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isPlaying
                                        ? AppColors.primary
                                        : AppColors.primary
                                            .withValues(alpha: 0.1),
                                  ),
                                  child: Icon(
                                    isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    size: 22,
                                    color: isPlaying
                                        ? Colors.white
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sp3),
                          Text(ep.description,
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                  height: 1.4),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: AppSpacing.sp3),
                          Row(
                            children: [
                              Icon(Icons.person_outline,
                                  size: 13,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textDisabled),
                              const SizedBox(width: 3),
                              Text(ep.speaker,
                                  style: AppTextStyles.bodySmall.copyWith(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textDisabled,
                                      fontSize: 11)),
                              const SizedBox(width: AppSpacing.sp3),
                              Icon(Icons.schedule_outlined,
                                  size: 13,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textDisabled),
                              const SizedBox(width: 3),
                              Text(ep.duration,
                                  style: AppTextStyles.bodySmall.copyWith(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textDisabled,
                                      fontSize: 11)),
                              const SizedBox(width: AppSpacing.sp3),
                              Text(_formatDate(ep.date),
                                  style: AppTextStyles.bodySmall.copyWith(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textDisabled,
                                      fontSize: 11)),
                              const Spacer(),
                              if (ep.downloaded)
                                Icon(Icons.download_done,
                                    size: 16, color: AppColors.success),
                            ],
                          ),

                          // Mini player if this episode is playing
                          if (isPlaying) ...[
                            const SizedBox(height: AppSpacing.sp3),
                            ClipRRect(
                              borderRadius: AppRadius.borderRadiusFull,
                              child: LinearProgressIndicator(
                                value: 0.35,
                                backgroundColor: isDark
                                    ? AppColors.borderDark
                                    : AppColors.inputFill,
                                color: AppColors.primary,
                                minHeight: 3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text('14:47',
                                    style: AppTextStyles.bodySmall.copyWith(
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textDisabled,
                                        fontSize: 10)),
                                const Spacer(),
                                Text(ep.duration,
                                    style: AppTextStyles.bodySmall.copyWith(
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textDisabled,
                                        fontSize: 10)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEpisodeSheet(
      BuildContext context, _EpisodeData ep, int index, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: AppRadius.borderRadiusXlTop,
        ),
        padding: EdgeInsets.fromLTRB(
            AppSpacing.sp6,
            AppSpacing.sp3,
            AppSpacing.sp6,
            MediaQuery.of(context).padding.bottom + AppSpacing.sp6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.inactive,
                  borderRadius: AppRadius.borderRadiusFull),
            ),
            const SizedBox(height: AppSpacing.sp5),
            Text(ep.title,
                style: AppTextStyles.headingSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('${ep.speaker} • ${ep.series}',
                style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.sp4),
            Text(ep.description,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    height: 1.5),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sp6),
            AppPrimaryButton(
              label: _playingIndex == index ? 'Pause' : 'Play Episode',
              icon: Icon(
                  _playingIndex == index ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 18),
              isFullWidth: true,
              onPressed: () {
                setState(() {
                  _playingIndex = _playingIndex == index ? null : index;
                });
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: AppSpacing.sp3),
            Row(
              children: [
                Expanded(
                  child: _SheetActionButton(
                    icon: ep.downloaded
                        ? Icons.download_done
                        : Icons.download_outlined,
                    label: ep.downloaded ? 'Downloaded' : 'Download',
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ep.downloaded
                            ? 'Already downloaded'
                            : 'Downloading...'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.borderRadiusSm),
                      ));
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sp3),
                Expanded(
                  child: _SheetActionButton(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    isDark: isDark,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sp3),
                Expanded(
                  child: _SheetActionButton(
                    icon: Icons.queue_outlined,
                    label: 'Queue',
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Added to queue'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.borderRadiusSm),
                      ));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.surface,
            borderRadius: AppRadius.borderRadiusXlTop,
          ),
          padding: EdgeInsets.fromLTRB(
              AppSpacing.sp6,
              AppSpacing.sp3,
              AppSpacing.sp6,
              MediaQuery.of(context).padding.bottom + AppSpacing.sp6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.inactive,
                    borderRadius: AppRadius.borderRadiusFull),
              ),
              const SizedBox(height: AppSpacing.sp5),
              Text('Podcast Settings',
                  style: AppTextStyles.headingSmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.sp5),
              _SettingTile(
                icon: Icons.download_outlined,
                title: 'Auto-Download New Episodes',
                isDark: isDark,
                trailing: Switch.adaptive(
                  value: _autoDownload,
                  onChanged: (v) {
                    setSheetState(() => _autoDownload = v);
                    setState(() => _autoDownload = v);
                  },
                  activeColor: AppColors.primary,
                ),
              ),
              const AppDivider(),
              _SettingTile(
                icon: Icons.notifications_outlined,
                title: 'New Episode Notifications',
                isDark: isDark,
                trailing: Switch.adaptive(
                  value: _subscribed,
                  onChanged: (v) {
                    setSheetState(() => _subscribed = v);
                    setState(() => _subscribed = v);
                  },
                  activeColor: AppColors.primary,
                ),
              ),
              const AppDivider(),
              _SettingTile(
                icon: Icons.speed_outlined,
                title: 'Playback Speed',
                isDark: isDark,
                trailing: Text('1.0x',
                    style: AppTextStyles.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary)),
              ),
              const AppDivider(),
              _SettingTile(
                icon: Icons.timer_outlined,
                title: 'Sleep Timer',
                isDark: isDark,
                trailing: Text('Off',
                    style: AppTextStyles.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Data ─────────────────────────────────────────────────────────────────────

class _EpisodeData {
  const _EpisodeData({
    required this.title,
    required this.series,
    required this.speaker,
    required this.date,
    required this.duration,
    required this.durationMinutes,
    required this.description,
    required this.downloaded,
    required this.played,
  });

  final String title;
  final String series;
  final String speaker;
  final DateTime date;
  final String duration;
  final int durationMinutes;
  final String description;
  final bool downloaded;
  final bool played;
}

// ── Widgets ─────────────────────────────────────────────────────────────────

class _SheetActionButton extends StatelessWidget {
  const _SheetActionButton({
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sp2),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgDark : AppColors.inputFill,
          borderRadius: AppRadius.borderRadiusMd,
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 20,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary),
            const SizedBox(height: 4),
            Text(label,
                style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.isDark,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final bool isDark;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sp2),
      child: Row(
        children: [
          Icon(icon,
              size: 20,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sp3),
          Expanded(
            child: Text(title,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary)),
          ),
          trailing,
        ],
      ),
    );
  }
}
