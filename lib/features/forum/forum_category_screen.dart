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
import '../../shared/widgets/filter_chips.dart';
import '../../shared/widgets/inputs.dart';
import '../../shared/widgets/app_tap_animation.dart';

/// ══════════════════════════════════════════════════════════════════════════════
/// FORUM CATEGORY SCREEN - threads within a specific category
///
/// Features:
///   - Filter chips (Recent, Popular, Unanswered)
///   - Search within category
///   - Thread list with author info, likes, replies
///   - FAB for new post (pre-filled category)
///   - Pinned threads at top
/// ══════════════════════════════════════════════════════════════════════════════

class ForumCategoryScreen extends ConsumerStatefulWidget {
  const ForumCategoryScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  ConsumerState<ForumCategoryScreen> createState() => _ForumCategoryScreenState();
}

class _ForumCategoryScreenState extends ConsumerState<ForumCategoryScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ForumThread> _filterThreads(List<ForumThread> threads) {
    var list = List<ForumThread>.from(threads);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((t) =>
              t.title.toLowerCase().contains(q) ||
              t.body.toLowerCase().contains(q) ||
              t.author.toLowerCase().contains(q))
          .toList();
    }

    final pinned = list.where((t) => t.isPinned).toList();
    final unpinned = list.where((t) => !t.isPinned).toList();
    return [...pinned, ...unpinned];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catState = ref.watch(categoryThreadNotifierProvider(widget.categoryId));
    final meta = catState.meta ??
        const ForumCategory(
          id: '',
          label: 'Forum',
          icon: Icons.forum_outlined,
          color: Color(0xFF6B7280),
          threadCount: 0,
          description: 'Discussion forum.',
        );
    final filteredThreads = _filterThreads(catState.threads);

    return Scaffold(
      appBar: AppFilledAppBar(
        title: meta.label.replaceAll('\n', ' '),
        showBack: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(
          '${AppRoutes.forumCreatePost}?category=${widget.categoryId}',
        ),
        backgroundColor: meta.color,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Category header banner ──────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(AppSpacing.sp4),
              padding: const EdgeInsets.all(AppSpacing.sp4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    meta.color.withValues(alpha: isDark ? 0.25 : 0.1),
                    meta.color.withValues(alpha: isDark ? 0.1 : 0.04),
                  ],
                ),
                borderRadius: AppRadius.borderRadiusLg,
                border: Border.all(
                  color: meta.color.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          meta.color.withValues(alpha: isDark ? 0.3 : 0.15),
                      borderRadius: AppRadius.borderRadiusMd,
                    ),
                    child: Icon(meta.icon, color: meta.color, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.sp3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meta.description,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${catState.threads.length} threads',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: meta.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Search ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
              child: AppSearchBar(
                controller: _searchCtrl,
                hint: 'Search in ${meta.label.replaceAll('\n', ' ')}...',
                onChanged: (v) => setState(() => _searchQuery = v),
                onClear: () {
                  _searchCtrl.clear();
                  setState(() => _searchQuery = '');
                },
              ),
            ),
          ),

          // ── Sort chips ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sp4, AppSpacing.sp3, AppSpacing.sp4, AppSpacing.sp2,
              ),
              child: AppFilterChips(
                labels: const ['Recent', 'Popular', 'Unanswered'],
                selectedIndex: catState.sortIndex,
                onSelected: (i) => ref
                    .read(categoryThreadNotifierProvider(widget.categoryId).notifier)
                    .setSortIndex(i),
              ),
            ),
          ),

          // ── Thread list ─────────────────────────────────────────────
          if (filteredThreads.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sp8),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.forum_outlined,
                        size: 48,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textDisabled,
                      ),
                      const SizedBox(height: AppSpacing.sp3),
                      Text(
                        'No threads found',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sp2),
                      Text(
                        'Be the first to start a discussion!',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textDisabled,
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
                    return _CategoryThreadCard(
                      data: thread,
                      accentColor: meta.color,
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
// CATEGORY THREAD CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _CategoryThreadCard extends StatelessWidget {
  const _CategoryThreadCard({
    required this.data,
    required this.accentColor,
    required this.isDark,
    required this.onTap,
  });

  final ForumThread data;
  final Color accentColor;
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
            color: data.isPinned
                ? accentColor.withValues(alpha: 0.3)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.inputBorder),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pinned / Locked badges
            if (data.isPinned || data.isLocked)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sp2),
                child: Row(
                  children: [
                    if (data.isPinned) ...[
                      Icon(Icons.push_pin_rounded,
                          size: 13, color: accentColor),
                      const SizedBox(width: 4),
                      Text('Pinned',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          )),
                    ],
                    if (data.isPinned && data.isLocked)
                      const SizedBox(width: AppSpacing.sp3),
                    if (data.isLocked) ...[
                      Icon(Icons.lock_outline_rounded,
                          size: 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textDisabled),
                      const SizedBox(width: 4),
                      Text('Locked',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textDisabled,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          )),
                    ],
                  ],
                ),
              ),

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

            // Footer: author + stats
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: data.avatarColor.withValues(alpha: 0.15),
                  child: Text(
                    data.authorInitials,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: data.avatarColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(data.author,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    )),
                const SizedBox(width: 6),
                Text('  ${data.timeAgo}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textDisabled,
                      fontSize: 11,
                    )),
                const Spacer(),
                Icon(Icons.favorite_border_rounded, size: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textDisabled),
                const SizedBox(width: 3),
                Text('${data.likes}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      fontSize: 11,
                    )),
                const SizedBox(width: AppSpacing.sp3),
                Icon(Icons.chat_bubble_outline_rounded, size: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textDisabled),
                const SizedBox(width: 3),
                Text('${data.replies}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      fontSize: 11,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


