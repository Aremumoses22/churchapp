import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/media.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// WORSHIP LYRICS SCREEN
//
// Song list loaded from GET /media/songs. Tap to view full lyrics.
// ──────────────────────────────────────────────────────────────────────────────

class WorshipLyricsScreen extends ConsumerWidget {
  const WorshipLyricsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final songsAsync = ref.watch(songsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(title: 'Worship Songs', showBack: true),
      body: songsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48),
              const SizedBox(height: AppSpacing.sp3),
              Text('Failed to load songs', style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.sp3),
              AppSecondaryButton(
                label: 'Retry',
                onPressed: () => ref.invalidate(songsProvider),
              ),
            ],
          ),
        ),
        data: (songs) => songs.isEmpty
            ? const AppEmptyState(
                icon: Icons.music_note_outlined,
                title: 'No songs yet',
                subtitle: 'Worship songs will appear here.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.sp4),
                itemCount: songs.length,
                separatorBuilder: (_, i) =>
                    const SizedBox(height: AppSpacing.sp3),
                itemBuilder: (context, i) => _SongTile(
                  song: songs[i],
                  isDark: isDark,
                  onTap: () => _openLyrics(context, songs[i], isDark),
                ),
              ),
      ),
    );
  }

  void _openLyrics(BuildContext context, Song song, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (ctx2, scroll) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.surface,
            borderRadius: AppRadius.borderRadiusXlTop,
          ),
          child: _LyricsSheet(
            song: song,
            isDark: isDark,
            scrollController: scroll,
          ),
        ),
      ),
    );
  }
}

// ── Song tile ─────────────────────────────────────────────────────────────────

class _SongTile extends StatelessWidget {
  const _SongTile({
    required this.song,
    required this.isDark,
    required this.onTap,
  });

  final Song song;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: onTap,
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primaryLight.withValues(alpha: 0.15)
                    : AppColors.skyLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.music_note,
                  size: 22,
                  color: isDark
                      ? AppColors.primaryLight
                      : AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.sp3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(song.title,
                      style: AppTextStyles.bodyLargeSemiBold.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary)),
                  if (song.artist != null)
                    Text(song.artist!,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary)),
                ],
              ),
            ),
            if (song.key != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sp2, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.skyLight,
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Text('Key: ${song.key}',
                    style: AppTextStyles.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.primaryLight
                            : AppColors.primary,
                        fontSize: 10)),
              ),
            const SizedBox(width: AppSpacing.sp2),
            Icon(Icons.chevron_right,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textDisabled),
          ],
        ),
      ),
    );
  }
}

// ── Lyrics sheet ──────────────────────────────────────────────────────────────

class _LyricsSheet extends StatelessWidget {
  const _LyricsSheet({
    required this.song,
    required this.isDark,
    required this.scrollController,
  });

  final Song song;
  final bool isDark;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color:
                    isDark ? AppColors.borderDark : AppColors.inactive,
                borderRadius: AppRadius.borderRadiusFull),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.sp4),
          child: Column(
            children: [
              Text(song.title,
                  style: AppTextStyles.headingSmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary),
                  textAlign: TextAlign.center),
              if (song.artist != null) ...[
                const SizedBox(height: 4),
                Text(song.artist!,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary)),
              ],
              if (song.key != null || song.bpm != null) ...[
                const SizedBox(height: AppSpacing.sp2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (song.key != null)
                      _Chip('Key: ${song.key}', isDark),
                    if (song.key != null && song.bpm != null)
                      const SizedBox(width: AppSpacing.sp2),
                    if (song.bpm != null)
                      _Chip('${song.bpm} BPM', isDark),
                  ],
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: song.lyricsText != null && song.lyricsText!.isNotEmpty
              ? SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.sp6, 0, AppSpacing.sp6, AppSpacing.sp10),
                  child: Text(
                    song.lyricsText!,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                        height: 1.8),
                    textAlign: TextAlign.center,
                  ),
                )
              : Center(
                  child: Text(
                    'No lyrics available.',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary),
                  ),
                ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.isDark);
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary.withValues(alpha: 0.2)
            : AppColors.skyLight,
        borderRadius: AppRadius.borderRadiusFull,
      ),
      child: Text(label,
          style: AppTextStyles.labelSmall.copyWith(
              color: isDark ? AppColors.primaryLight : AppColors.primary,
              fontSize: 11)),
    );
  }
}
