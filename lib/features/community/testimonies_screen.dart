import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/community.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// TESTIMONIES SCREEN
//
// Community testimonies feed with heart reactions and prayer emoji,
// "Share Your Testimony" FAB, content cards with quotation-mark accent.
// ──────────────────────────────────────────────────────────────────────────────

class TestimoniesScreen extends ConsumerWidget {
  const TestimoniesScreen({super.key});

  static _TestimonyData _fromApi(Testimony t) => _TestimonyData(
        id: t.id,
        author: t.isAnonymous ? 'Anonymous' : (t.authorName ?? 'Member'),
        date: t.createdAt ?? '',
        category: '',
        title: t.title,
        content: t.content,
        likes: t.likeCount,
        prayers: t.prayCount,
        comments: 0,
        isLiked: t.hasLiked,
        isPrayed: t.hasPrayed,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Use FutureProvider for load/error state, NotifierProvider for live mutations
    final testimoniesAsync = ref.watch(testimoniesFutureProvider);
    final liveTestimonies = ref.watch(testimoniesProvider);

    final appBar = AppFilledAppBar(
      title: 'Testimonies',
      showBack: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );

    final fab = FloatingActionButton.extended(
      onPressed: () {},
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
      label: Text(
        'Share Testimony',
        style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
      ),
    );

    return testimoniesAsync.when(
      loading: () => Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
        appBar: appBar,
        floatingActionButton: fab,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
        appBar: appBar,
        floatingActionButton: fab,
        body: Center(
          child: AppEmptyState(
            icon: Icons.volunteer_activism_outlined,
            title: 'No Testimonies',
            subtitle: 'Check back soon for community testimonies.',
          ),
        ),
      ),
      data: (_) {
        // Use the live NotifierProvider so mutations (react) are reflected instantly
        final testimonies = liveTestimonies.map(_fromApi).toList();
        return Scaffold(
          backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
          appBar: appBar,
          floatingActionButton: fab,
          body: testimonies.isEmpty
              ? Center(
                  child: AppEmptyState(
                    icon: Icons.volunteer_activism_outlined,
                    title: 'No Testimonies',
                    subtitle: 'Check back soon for community testimonies.',
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
                  itemCount: testimonies.length,
                  itemBuilder: (context, index) {
                    final t = testimonies[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
                      child: _TestimonyCard(
                        testimony: t,
                        isDark: isDark,
                        onLike: () => ref
                            .read(testimoniesProvider.notifier)
                            .react(t.id, 'LIKE'),
                        onPray: () => ref
                            .read(testimoniesProvider.notifier)
                            .react(t.id, 'PRAYER'),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

// ── Data ─────────────────────────────────────────────────────────────────────

class _TestimonyData {
  const _TestimonyData({
    required this.id,
    required this.author,
    required this.date,
    required this.category,
    required this.title,
    required this.content,
    required this.likes,
    required this.prayers,
    required this.comments,
    required this.isLiked,
    required this.isPrayed,
  });

  final String id;
  final String author;
  final String date;
  final String category;
  final String title;
  final String content;
  final int likes;
  final int prayers;
  final int comments;
  final bool isLiked;
  final bool isPrayed;
}

// ── Widgets ─────────────────────────────────────────────────────────────────

class _TestimonyCard extends StatelessWidget {
  const _TestimonyCard({
    required this.testimony,
    required this.isDark,
    required this.onLike,
    required this.onPray,
  });

  final _TestimonyData testimony;
  final bool isDark;
  final VoidCallback onLike;
  final VoidCallback onPray;

  Color get _categoryColor {
    switch (testimony.category) {
      case 'Healing':
        return AppColors.success;
      case 'Salvation':
        return AppColors.primary;
      case 'Provision':
        return AppColors.gold;
      case 'Family':
        return const Color(0xFFDC2626);
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surface,
        borderRadius: AppRadius.borderRadiusLg,
        boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sp4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: author + date + category
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor:
                          _categoryColor.withValues(alpha: 0.15),
                      child: Text(
                        testimony.author.isNotEmpty ? testimony.author[0] : '?',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: _categoryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sp3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            testimony.author,
                            style:
                                AppTextStyles.labelMedium.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            testimony.date,
                            style:
                                AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textDisabled,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sp2,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _categoryColor.withValues(alpha: 0.1),
                        borderRadius: AppRadius.borderRadiusFull,
                      ),
                      child: Text(
                        testimony.category,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _categoryColor,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sp4),

                // Quotation mark accent
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\u201C',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.primaryLight
                            : AppColors.primary,
                        height: 0.8,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sp2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            testimony.title,
                            style: AppTextStyles.headingSmall
                                .copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sp2),
                          Text(
                            testimony.content,
                            style:
                                AppTextStyles.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                              height: 1.6,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 0.5,
            color: isDark ? AppColors.borderDark : AppColors.divider,
          ),

          // Reactions row
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sp4,
              vertical: AppSpacing.sp3,
            ),
            child: Row(
              children: [
                _ReactionButton(
                  icon: testimony.isLiked
                      ? Icons.favorite
                      : Icons.favorite_border,
                  label: '${testimony.likes}',
                  color: testimony.isLiked
                      ? const Color(0xFFEF4444)
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textDisabled),
                  isDark: isDark,
                  onTap: onLike,
                ),
                const SizedBox(width: AppSpacing.sp5),
                _ReactionButton(
                  icon: testimony.isPrayed
                      ? Icons.volunteer_activism
                      : Icons.volunteer_activism_outlined,
                  label: '${testimony.prayers} praying',
                  color: testimony.isPrayed
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textDisabled),
                  isDark: isDark,
                  onTap: onPray,
                ),
                const SizedBox(width: AppSpacing.sp5),
                _ReactionButton(
                  icon: Icons.chat_bubble_outline,
                  label: '${testimony.comments}',
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textDisabled,
                  isDark: isDark,
                  onTap: () {},
                ),
                const Spacer(),
                Icon(
                  Icons.bookmark_border,
                  size: 20,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textDisabled,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  const _ReactionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
