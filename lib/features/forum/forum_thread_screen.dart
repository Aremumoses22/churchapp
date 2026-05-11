import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/forum.dart';
import '../../core/providers/forum_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_bars.dart';
import '../../shared/widgets/app_tap_animation.dart';

/// ══════════════════════════════════════════════════════════════════════════════
/// FORUM THREAD SCREEN - full thread view with replies
///
/// Features:
///   - Original post with full body text
///   - Like / bookmark / share actions
///   - Chronological replies with author avatars
///   - Nested reply indicator (accent bar)
///   - Reply input bar at bottom
///   - Report / flag option in overflow menu
/// ══════════════════════════════════════════════════════════════════════════════

class ForumThreadScreen extends ConsumerStatefulWidget {
  const ForumThreadScreen({super.key, required this.threadId});

  final String threadId;

  @override
  ConsumerState<ForumThreadScreen> createState() => _ForumThreadScreenState();
}

class _ForumThreadScreenState extends ConsumerState<ForumThreadScreen> {
  final _replyCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _replyCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _submitReply() {
    final text = _replyCtrl.text.trim();
    if (text.isEmpty) return;

    ref.read(threadDetailNotifierProvider(widget.threadId).notifier).addReply(text);
    _replyCtrl.clear();

    Timer(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final tState = ref.watch(threadDetailNotifierProvider(widget.threadId));
    final post = tState.post;
    final replies = tState.replies;

    if (post == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppFilledAppBar(
        title: 'Thread',
        showBack: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, size: 20),
            onSelected: (v) {
              if (v == 'share') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard')),
                );
              } else if (v == 'report') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Thread reported to moderators')),
                );
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.flag_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Report'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Scrollable content ──────────────────────────────────────
          Expanded(
            child: CustomScrollView(
              controller: _scrollCtrl,
              slivers: [
                // ── Original post ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(AppSpacing.sp4),
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
                        // Category badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: post.categoryColor
                                .withValues(alpha: 0.12),
                            borderRadius: AppRadius.borderRadiusSm,
                          ),
                          child: Text(
                            post.category,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: post.categoryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sp3),

                        // Title
                        Text(
                          post.title,
                          style: AppTextStyles.headingMedium.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sp3),

                        // Author row
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  post.avatarColor.withValues(alpha: 0.15),
                              child: Text(
                                post.authorInitials,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: post.avatarColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sp2),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.author,
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${post.timeAgo}  |  ${post.views} views',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textDisabled,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sp4),

                        // Body
                        Text(
                          post.body,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                            height: 1.7,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sp4),

                        // Actions bar
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sp3,
                            vertical: AppSpacing.sp2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.04)
                                : const Color(0xFFF8FAFC),
                            borderRadius: AppRadius.borderRadiusMd,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _ActionButton(
                                icon: tState.isLiked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                label: '${tState.likeCount}',
                                color: tState.isLiked
                                    ? const Color(0xFFEF4444)
                                    : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary),
                                onTap: () => ref
                                    .read(threadDetailNotifierProvider(widget.threadId).notifier)
                                    .toggleLike(),
                              ),
                              _ActionButton(
                                icon: Icons.chat_bubble_outline_rounded,
                                label: '${replies.length}',
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                                onTap: () =>
                                    FocusScope.of(context).nextFocus(),
                              ),
                              _ActionButton(
                                icon: tState.isBookmarked
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                label: 'Save',
                                color: tState.isBookmarked
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary),
                                onTap: () {
                                  ref
                                      .read(threadDetailNotifierProvider(widget.threadId).notifier)
                                      .toggleBookmark();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(!tState.isBookmarked
                                          ? 'Thread saved'
                                          : 'Removed from saved'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                              _ActionButton(
                                icon: Icons.share_outlined,
                                label: 'Share',
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Link copied'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Replies header ────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.sp4, 0, AppSpacing.sp4, AppSpacing.sp2,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Replies',
                          style: AppTextStyles.headingSmall.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sp2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary
                                .withValues(alpha: isDark ? 0.2 : 0.1),
                            borderRadius: AppRadius.borderRadiusFull,
                          ),
                          child: Text(
                            '${replies.length}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Replies list ──────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sp4),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final reply = replies[index];
                        return _ReplyCard(
                          data: reply,
                          isDark: isDark,
                          onLike: () => ref
                              .read(threadDetailNotifierProvider(widget.threadId).notifier)
                              .toggleReplyLike(reply.id),
                        );
                      },
                      childCount: replies.length,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Reply input bar ─────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.sp4,
              AppSpacing.sp2,
              AppSpacing.sp4,
              bottomInset > 0 ? AppSpacing.sp2 : AppSpacing.sp4,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.inputBorder,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.12),
                    child: Text(
                      'ME',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sp2),
                  Expanded(
                    child: TextField(
                      controller: _replyCtrl,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Write a reply...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textDisabled,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : AppColors.inputBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : AppColors.inputBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        isDense: true,
                      ),
                      maxLines: 3,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitReply(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sp2),
                  AppTapAnimation(
                    onTap: _submitReply,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ACTION BUTTON
// ═══════════════════════════════════════════════════════════════════════════════

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp2, vertical: AppSpacing.sp1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                )),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// REPLY CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _ReplyCard extends StatelessWidget {
  const _ReplyCard({
    required this.data,
    required this.isDark,
    required this.onLike,
  });

  final ForumReply data;
  final bool isDark;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sp4, vertical: AppSpacing.sp1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accent bar
          Container(
            width: 3,
            height: 80,
            decoration: BoxDecoration(
              color: data.avatarColor.withValues(alpha: 0.3),
              borderRadius: AppRadius.borderRadiusFull,
            ),
          ),
          const SizedBox(width: AppSpacing.sp3),

          // Reply content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sp3),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : const Color(0xFFF8FAFC),
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author + time
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor:
                            data.avatarColor.withValues(alpha: 0.15),
                        child: Text(
                          data.authorInitials,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: data.avatarColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 9,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(data.author,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          )),
                      const Spacer(),
                      Text(data.timeAgo,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textDisabled,
                            fontSize: 11,
                          )),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sp2),

                  // Body
                  Text(
                    data.body,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sp2),

                  // Like button
                  AppTapAnimation(
                    onTap: onLike,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          data.isLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 14,
                          color: data.isLiked
                              ? const Color(0xFFEF4444)
                              : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textDisabled),
                        ),
                        const SizedBox(width: 4),
                        Text('${data.likes}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                              fontSize: 11,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
