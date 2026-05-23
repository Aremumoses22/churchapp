import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/forum.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/providers/forum_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_bars.dart';
import '../../shared/widgets/inputs.dart';
import '../../shared/widgets/app_tap_animation.dart';

/// ══════════════════════════════════════════════════════════════════════════════
/// FORUM SCREEN - Main community forum hub
///
/// Features:
///   - Category grid (Prayer, Bible Study, Testimonies, etc.)
///   - Trending topics section
///   - Recent discussions feed
///   - FAB for creating new post
///   - Search bar for finding threads
/// ══════════════════════════════════════════════════════════════════════════════

class ForumScreen extends ConsumerStatefulWidget {
  const ForumScreen({super.key});

  @override
  ConsumerState<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends ConsumerState<ForumScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fState = ref.watch(forumNotifierProvider);
    final categories = ref.watch(forumCategoriesProvider).maybeWhen(
      data: (d) => d, orElse: () => <ForumCategory>[],
    );
    final trendingTopics = ref.watch(forumTrendingProvider).maybeWhen(
      data: (d) => d, orElse: () => <ForumThread>[],
    );
    final recentThreads = ref.watch(forumRecentProvider).maybeWhen(
      data: (d) => d, orElse: () => <ForumThread>[],
    );
    final filteredThreads = fState.searchQuery.isEmpty
        ? recentThreads
        : recentThreads.where((t) {
            final q = fState.searchQuery.toLowerCase();
            return t.title.toLowerCase().contains(q) ||
                t.body.toLowerCase().contains(q);
          }).toList();

    return Scaffold(
      appBar: AppFilledAppBar(
        title: 'Community Forum',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, size: 22),
            onPressed: () => context.push(AppRoutes.notificationCenter),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.forumCreatePost),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_outlined, size: 20),
        label: const Text('New Post'),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Search bar ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sp4, AppSpacing.sp3, AppSpacing.sp4, 0,
              ),
              child: AppSearchBar(
                controller: _searchCtrl,
                hint: 'Search discussions...',
                onChanged: (v) => ref
                    .read(forumNotifierProvider.notifier)
                    .setSearchQuery(v),
                onClear: () {
                  _searchCtrl.clear();
                  ref
                      .read(forumNotifierProvider.notifier)
                      .setSearchQuery('');
                },
              ),
            ),
          ),

          // ── Forum stats ribbon ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sp4, AppSpacing.sp4, AppSpacing.sp4, 0,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sp4,
                  vertical: AppSpacing.sp3,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E3A8A), const Color(0xFF312E81)]
                        : [const Color(0xFFEFF6FF), const Color(0xFFEDE9FE)],
                  ),
                  borderRadius: AppRadius.borderRadiusLg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      value: '755',
                      label: 'Topics',
                      icon: Icons.forum_outlined,
                      isDark: isDark,
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: (isDark ? Colors.white : AppColors.primary)
                          .withValues(alpha: 0.15),
                    ),
                    _StatItem(
                      value: '2.4K',
                      label: 'Replies',
                      icon: Icons.reply_all_outlined,
                      isDark: isDark,
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: (isDark ? Colors.white : AppColors.primary)
                          .withValues(alpha: 0.15),
                    ),
                    _StatItem(
                      value: '312',
                      label: 'Members',
                      icon: Icons.people_outline,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Categories header ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sp4, AppSpacing.sp5, AppSpacing.sp4, AppSpacing.sp3,
              ),
              child: Text(
                'Categories',
                style: AppTextStyles.headingSmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          // ── Categories grid ─────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: AppSpacing.sp3,
                crossAxisSpacing: AppSpacing.sp3,
                childAspectRatio: 0.82,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cat = categories[index];
                  return _CategoryTile(
                    data: cat,
                    isDark: isDark,
                    onTap: () => context.push(
                      AppRoutes.forumCategory.replaceFirst(':id', cat.id),
                    ),
                  );
                },
                childCount: categories.length,
              ),
            ),
          ),

          // ── Trending topics header ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sp4, AppSpacing.sp5, AppSpacing.sp4, AppSpacing.sp2,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sp2),
                  Text(
                    'Trending Now',
                    style: AppTextStyles.headingSmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Trending topics list ────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 112,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sp4,
                  vertical: AppSpacing.sp2,
                ),
                itemCount: trendingTopics.length,
                separatorBuilder: (_, i) =>
                    const SizedBox(width: AppSpacing.sp3),
                itemBuilder: (context, index) {
                  final topic = trendingTopics[index];
                  return _TrendingCard(
                    data: topic,
                    isDark: isDark,
                    onTap: () => context.push(
                      AppRoutes.forumThread
                          .replaceFirst(':id', topic.id),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Recent discussions header ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sp4, AppSpacing.sp4, AppSpacing.sp4, AppSpacing.sp2,
              ),
              child: Text(
                fState.searchQuery.isEmpty
                    ? 'Recent Discussions'
                    : 'Search Results (${filteredThreads.length})',
                style: AppTextStyles.headingSmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          // ── Threads list ────────────────────────────────────────────
          if (filteredThreads.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sp8),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textDisabled,
                      ),
                      const SizedBox(height: AppSpacing.sp3),
                      Text(
                        'No discussions found',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final thread = filteredThreads[index];
                    return _ThreadCard(
                      data: thread,
                      isDark: isDark,
                      onTap: () => context.push(
                        AppRoutes.forumThread.replaceFirst(':id', thread.id),
                      ),
                    );
                  },
                  childCount: filteredThreads.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STAT ITEM
// ═══════════════════════════════════════════════════════════════════════════════

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.isDark,
  });

  final String value;
  final String label;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18,
            color: isDark ? const Color(0xFF93C5FD) : AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.headingSmall.copyWith(
            color: isDark ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CATEGORY TILE
// ═══════════════════════════════════════════════════════════════════════════════

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.data,
    required this.isDark,
    required this.onTap,
  });

  final ForumCategory data;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: AppRadius.borderRadiusMd,
            ),
            child: Center(
              child: Icon(data.icon, color: data.color, size: 24),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              fontSize: 10.5,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TRENDING CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _TrendingCard extends StatelessWidget {
  const _TrendingCard({
    required this.data,
    required this.isDark,
    required this.onTap,
  });

  final ForumThread data;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: onTap,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(AppSpacing.sp3),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: AppRadius.borderRadiusLg,
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.inputBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              data.title,
              style: AppTextStyles.labelMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: data.categoryColor.withValues(alpha: 0.12),
                    borderRadius: AppRadius.borderRadiusSm,
                  ),
                  child: Text(
                    data.category,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: data.categoryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.reply_rounded, size: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textDisabled),
                const SizedBox(width: 4),
                Text(
                  '${data.replies}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// THREAD CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _ThreadCard extends StatelessWidget {
  const _ThreadCard({
    required this.data,
    required this.isDark,
    required this.onTap,
  });

  final ForumThread data;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp4, vertical: AppSpacing.sp1),
        padding: const EdgeInsets.all(AppSpacing.sp4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: AppRadius.borderRadiusLg,
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.inputBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: author + category badge
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: data.avatarColor.withValues(alpha: 0.15),
                  child: Text(
                    data.authorInitials,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: data.avatarColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sp2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.author,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          )),
                      Text(data.timeAgo,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textDisabled,
                            fontSize: 11,
                          )),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: data.categoryColor.withValues(alpha: 0.12),
                    borderRadius: AppRadius.borderRadiusSm,
                  ),
                  child: Text(
                    data.category,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: data.categoryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (data.isPinned) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.push_pin_rounded,
                      size: 14, color: Color(0xFFF59E0B)),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sp3),

            // Title
            Text(
              data.title,
              style: AppTextStyles.labelLarge.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sp2),

            // Body preview
            Text(
              data.body,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sp3),

            // Footer
            Row(
              children: [
                Icon(Icons.favorite_border_rounded, size: 16,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textDisabled),
                const SizedBox(width: 4),
                Text('${data.likes}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      fontSize: 12,
                    )),
                const SizedBox(width: AppSpacing.sp4),
                Icon(Icons.chat_bubble_outline_rounded, size: 15,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textDisabled),
                const SizedBox(width: 4),
                Text('${data.replies} replies',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      fontSize: 12,
                    )),
                const Spacer(),
                Icon(Icons.bookmark_border_rounded, size: 18,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textDisabled),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


