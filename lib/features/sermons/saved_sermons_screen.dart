import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SAVED SERMONS SCREEN
//
// Bookmarked sermons list with remove-from-saved swipe action.
// Accessed from profile "Saved Sermons" menu item.
// ──────────────────────────────────────────────────────────────────────────────

class SavedSermonsScreen extends StatefulWidget {
  const SavedSermonsScreen({super.key});

  @override
  State<SavedSermonsScreen> createState() => _SavedSermonsScreenState();
}

class _SavedSermonsScreenState extends State<SavedSermonsScreen> {
  // ── Mock data ──────────────────────────────────────────────────────────────
  final List<_SavedSermon> _sermons = [
    _SavedSermon(
      id: '1',
      title: 'Walking in Faith',
      speaker: 'Pastor David Mitchell',
      series: 'Faith Over Fear',
      date: 'Jan 12, 2025',
      duration: '42 min',
      savedDate: 'Saved Jan 12',
      hasNotes: true,
    ),
    _SavedSermon(
      id: '2',
      title: 'The Power of Prayer',
      speaker: 'Pastor Sarah Chen',
      series: 'Prayer Warriors',
      date: 'Jan 5, 2025',
      duration: '38 min',
      savedDate: 'Saved Jan 5',
      hasNotes: false,
    ),
    _SavedSermon(
      id: '3',
      title: 'Grace Upon Grace',
      speaker: 'Pastor David Mitchell',
      series: 'Amazing Grace',
      date: 'Dec 29, 2024',
      duration: '45 min',
      savedDate: 'Saved Dec 29',
      hasNotes: true,
    ),
    _SavedSermon(
      id: '4',
      title: 'Finding Purpose',
      speaker: 'Rev. James Williams',
      series: 'Discovering Your Calling',
      date: 'Dec 22, 2024',
      duration: '36 min',
      savedDate: 'Saved Dec 23',
      hasNotes: false,
    ),
    _SavedSermon(
      id: '5',
      title: 'Strength in Weakness',
      speaker: 'Pastor Sarah Chen',
      series: 'Faith Over Fear',
      date: 'Dec 15, 2024',
      duration: '41 min',
      savedDate: 'Saved Dec 16',
      hasNotes: false,
    ),
    _SavedSermon(
      id: '6',
      title: 'The Good Shepherd',
      speaker: 'Pastor David Mitchell',
      series: 'Names of God',
      date: 'Dec 8, 2024',
      duration: '39 min',
      savedDate: 'Saved Dec 8',
      hasNotes: true,
    ),
  ];

  void _removeSermon(int index) {
    final removed = _sermons[index];
    setState(() => _sermons.removeAt(index));
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "${removed.title}"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() => _sermons.insert(index, removed));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Saved Sermons',
        showBack: true,
        actions: [
          if (_sermons.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sp4),
              child: Center(
                child: Text(
                  '${_sermons.length} saved',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _sermons.isEmpty
          ? Center(
              child: AppEmptyState(
                icon: Icons.bookmark_outline,
                title: 'No Saved Sermons',
                subtitle:
                    'Bookmark sermons to listen again later',
                buttonLabel: 'Browse Sermons',
                onButtonPressed: () => Navigator.of(context).pop(),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontalPadding,
                vertical: AppSpacing.sp4,
              ),
              itemCount: _sermons.length,
              itemBuilder: (context, index) {
                final sermon = _sermons[index];
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppSpacing.cardGap),
                  child: Dismissible(
                    key: ValueKey(sermon.id),
                    direction: DismissDirection.endToStart,
                    background: _SwipeBackground(isDark: isDark),
                    onDismissed: (_) => _removeSermon(index),
                    confirmDismiss: (_) async {
                      HapticFeedback.lightImpact();
                      return true;
                    },
                    child: _SavedSermonCard(
                      sermon: sermon,
                      isDark: isDark,
                      onTap: () {
                        // TODO: navigate to sermon detail
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// DATA MODEL
// ──────────────────────────────────────────────────────────────────────────────

class _SavedSermon {
  const _SavedSermon({
    required this.id,
    required this.title,
    required this.speaker,
    required this.series,
    required this.date,
    required this.duration,
    required this.savedDate,
    this.hasNotes = false,
  });

  final String id;
  final String title;
  final String speaker;
  final String series;
  final String date;
  final String duration;
  final String savedDate;
  final bool hasNotes;
}

// ──────────────────────────────────────────────────────────────────────────────
// PRIVATE SUB-WIDGETS
// ──────────────────────────────────────────────────────────────────────────────

class _SavedSermonCard extends StatelessWidget {
  const _SavedSermonCard({
    required this.sermon,
    required this.isDark,
    required this.onTap,
  });

  final _SavedSermon sermon;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sp4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: AppRadius.borderRadiusLg,
          boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sermon thumbnail placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: isDark
                    ? AppGradients.heroDark
                    : AppGradients.hero,
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: Center(
                child: Icon(
                  Icons.play_arrow,
                  color: AppColors.textInverse,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sp3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    sermon.title,
                    style: AppTextStyles.bodyLargeSemiBold.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Speaker
                  Text(
                    sermon.speaker,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sp2),

                  // Series & Duration
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sp2,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : AppColors.skyLight,
                          borderRadius: AppRadius.borderRadiusXs,
                        ),
                        child: Text(
                          sermon.series,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.primaryLight
                                : AppColors.primary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sp2),
                      Icon(
                        Icons.schedule,
                        size: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textDisabled,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        sermon.duration,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textDisabled,
                          fontSize: 11,
                        ),
                      ),
                      if (sermon.hasNotes) ...[
                        const SizedBox(width: AppSpacing.sp2),
                        Icon(
                          Icons.edit_note,
                          size: 14,
                          color: AppColors.gold,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sp2),

                  // Saved date
                  Text(
                    sermon.savedDate,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textDisabled,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Bookmark icon
            Icon(
              Icons.bookmark,
              size: 20,
              color: AppColors.gold,
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppSpacing.sp6),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: AppRadius.borderRadiusLg,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.bookmark_remove_outlined,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            'Remove',
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
