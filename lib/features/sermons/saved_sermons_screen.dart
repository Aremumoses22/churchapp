import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/sermon.dart';
import '../../core/providers/sermon_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SAVED SERMONS SCREEN
// ──────────────────────────────────────────────────────────────────────────────

class SavedSermonsScreen extends ConsumerStatefulWidget {
  const SavedSermonsScreen({super.key});

  @override
  ConsumerState<SavedSermonsScreen> createState() =>
      _SavedSermonsScreenState();
}

class _SavedSermonsScreenState extends ConsumerState<SavedSermonsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(sermonNotifierProvider.notifier).loadSaved());
  }

  void _removeSermon(Sermon sermon) {
    ref.read(sermonNotifierProvider.notifier).toggleSave(sermon.id);
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed "${sermon.title}"')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sState = ref.watch(sermonNotifierProvider);
    final saved = sState.savedSermons;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Saved Sermons',
        showBack: true,
        actions: [
          if (saved.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sp4),
              child: Center(
                child: Text(
                  '${saved.length} saved',
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
      body: sState.isLoading && saved.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : saved.isEmpty
              ? Center(
                  child: AppEmptyState(
                    icon: Icons.bookmark_outline,
                    title: 'No Saved Sermons',
                    subtitle: 'Bookmark sermons to listen again later',
                    buttonLabel: 'Browse Sermons',
                    onButtonPressed: () => Navigator.of(context).pop(),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontalPadding,
                    vertical: AppSpacing.sp4,
                  ),
                  itemCount: saved.length,
                  itemBuilder: (context, index) {
                    final sermon = saved[index];
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.cardGap),
                      child: Dismissible(
                        key: ValueKey(sermon.id),
                        direction: DismissDirection.endToStart,
                        background: _SwipeBackground(isDark: isDark),
                        onDismissed: (_) => _removeSermon(sermon),
                        confirmDismiss: (_) async {
                          HapticFeedback.lightImpact();
                          return true;
                        },
                        child: _SavedSermonCard(
                          sermon: sermon,
                          isDark: isDark,
                          onTap: () =>
                              context.push('/sermons/${sermon.id}'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
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

  final Sermon sermon;
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
                gradient: isDark ? AppGradients.heroDark : AppGradients.hero,
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: sermon.thumbnailUrl != null
                  ? ClipRRect(
                      borderRadius: AppRadius.borderRadiusMd,
                      child: Image.network(sermon.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.play_arrow,
                                  color: AppColors.textInverse, size: 28))))
                  : const Center(
                      child: Icon(Icons.play_arrow,
                          color: AppColors.textInverse, size: 28)),
            ),
            const SizedBox(width: AppSpacing.sp3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Text(
                    sermon.speaker ?? '',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sp2),
                  Row(
                    children: [
                      if (sermon.series != null)
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
                            sermon.series!.title,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      if (sermon.series != null)
                        const SizedBox(width: AppSpacing.sp2),
                      Icon(Icons.schedule,
                          size: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textDisabled),
                      const SizedBox(width: 2),
                      Text(
                        sermon.durationFormatted,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textDisabled,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sp2),
                  Text(
                    sermon.dateFormatted,
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
            const Icon(Icons.bookmark, size: 20, color: AppColors.gold),
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
          const Icon(Icons.bookmark_remove_outlined,
              color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text('Remove',
              style: AppTextStyles.labelSmall
                  .copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}
