import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/chat.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/providers/chat_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_bars.dart';
import '../../shared/widgets/app_tap_animation.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/inputs.dart';

/// ══════════════════════════════════════════════════════════════════════════════
/// CHAT LIST SCREEN
///
/// Shows all conversations: DMs + group chats.
/// Features:
///   - Search conversations
///   - Filter: All / Direct / Groups
///   - Online status dots
///   - Last message preview + timestamp
///   - Unread count badges
///   - New chat FAB
///   - Long-press to pin / mute / delete
/// ══════════════════════════════════════════════════════════════════════════════

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final _searchCtrl = TextEditingController();

  static const _filterLabels = ['All', 'Direct', 'Groups'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showNewChatSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.sp4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.grey.shade300,
                  borderRadius: AppRadius.borderRadiusFull,
                ),
              ),
              const SizedBox(height: AppSpacing.sp4),
              Text(
                'Start a Conversation',
                style: AppTextStyles.headingSmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sp4),
              _SheetOption(
                icon: Icons.person_add_outlined,
                label: 'New Direct Message',
                subtitle: 'Send a private message to someone',
                color: AppColors.primary,
                isDark: isDark,
                onTap: () {
                  Navigator.of(ctx).pop();
                  context.push(
                    '${AppRoutes.chatConversation.replaceAll(':id', 'new')}?name=New%20Message',
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sp2),
              _SheetOption(
                icon: Icons.group_add_outlined,
                label: 'New Group Chat',
                subtitle: 'Create a chat with multiple people',
                color: const Color(0xFF8B5CF6),
                isDark: isDark,
                onTap: () {
                  Navigator.of(ctx).pop();
                  context.push(
                    '${AppRoutes.chatConversation.replaceAll(':id', 'new-group')}?name=New%20Group',
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sp6),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cState = ref.watch(chatListNotifierProvider);
    final chats = cState.filteredChats;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Messages',
        showBack: true,
        actions: [
          AppTapAnimation(
            onTap: _showNewChatSheet,
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sp3),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                child: const Icon(Icons.edit_outlined,
                    color: AppColors.primary, size: 18),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search + filters ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sp4, AppSpacing.sp3, AppSpacing.sp4, 0,
            ),
            child: Column(
              children: [
                AppSearchBar(
                  controller: _searchCtrl,
                  hint: 'Search conversations...',
                  onChanged: (v) => ref.read(chatListNotifierProvider.notifier).setSearchQuery(v.trim()),
                  onClear: () {
                    _searchCtrl.clear();
                    ref.read(chatListNotifierProvider.notifier).setSearchQuery('');
                  },
                ),
                const SizedBox(height: AppSpacing.sp3),
                SizedBox(
                  height: 36,
                  child: Row(
                    children: List.generate(_filterLabels.length, (i) {
                      final isActive = cState.filterIndex == i;
                      return Padding(
                        padding:
                            const EdgeInsets.only(right: AppSpacing.sp2),
                        child: AppTapAnimation(
                          onTap: () =>
                              ref.read(chatListNotifierProvider.notifier).setFilter(i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primary
                                  : (isDark
                                      ? Colors.white
                                          .withValues(alpha: 0.06)
                                      : const Color(0xFFF1F5F9)),
                              borderRadius: AppRadius.borderRadiusFull,
                            ),
                            child: Text(
                              _filterLabels[i],
                              style: AppTextStyles.labelSmall.copyWith(
                                color: isActive
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          AppDivider(),

          // ── Chat list ───────────────────────────────────────────────
          Expanded(
            child: chats.isEmpty
                ? const AppEmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'No conversations yet',
                    subtitle: 'Start a new chat to connect with others!',
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.only(bottom: AppSpacing.sp6),
                    itemCount: chats.length,
                    itemBuilder: (context, i) {
                      return _ChatTile(
                        data: chats[i],
                        isDark: isDark,
                        onTap: () => context.push(
                          '${AppRoutes.chatConversation.replaceAll(':id', chats[i].id)}?name=${Uri.encodeComponent(chats[i].name)}',
                        ),
                        onLongPress: () =>
                            _showChatOptions(chats[i]),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewChatSheet,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat_outlined, color: Colors.white),
      ),
    );
  }

  void _showChatOptions(ChatPreview chat) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.sp4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.grey.shade300,
                  borderRadius: AppRadius.borderRadiusFull,
                ),
              ),
              const SizedBox(height: AppSpacing.sp3),
              _SheetOption(
                icon: chat.isPinned
                    ? Icons.push_pin_outlined
                    : Icons.push_pin_rounded,
                label: chat.isPinned ? 'Unpin Chat' : 'Pin Chat',
                subtitle: chat.isPinned
                    ? 'Remove from top of list'
                    : 'Keep at top of list',
                color: const Color(0xFFF59E0B),
                isDark: isDark,
                onTap: () {
                  Navigator.of(ctx).pop();
                  ref.read(chatListNotifierProvider.notifier).togglePin(chat.id);
                },
              ),
              const SizedBox(height: AppSpacing.sp2),
              _SheetOption(
                icon: chat.isMuted
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_off_outlined,
                label: chat.isMuted ? 'Unmute' : 'Mute',
                subtitle: chat.isMuted
                    ? 'Turn notifications back on'
                    : 'Stop receiving notifications',
                color: const Color(0xFF6366F1),
                isDark: isDark,
                onTap: () {
                  Navigator.of(ctx).pop();
                  ref.read(chatListNotifierProvider.notifier).toggleMute(chat.id);
                },
              ),
              const SizedBox(height: AppSpacing.sp2),
              _SheetOption(
                icon: Icons.delete_outline_rounded,
                label: 'Delete Chat',
                subtitle: 'Remove this conversation',
                color: const Color(0xFFEF4444),
                isDark: isDark,
                onTap: () {
                  Navigator.of(ctx).pop();
                  ref.read(chatListNotifierProvider.notifier).deleteChat(chat.id);
                },
              ),
              const SizedBox(height: AppSpacing.sp6),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CHAT TILE — single conversation preview
// ═══════════════════════════════════════════════════════════════════════════════

class _ChatTile extends StatelessWidget {
  const _ChatTile({
    required this.data,
    required this.isDark,
    required this.onTap,
    required this.onLongPress,
  });
  final ChatPreview data;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp4,
            vertical: AppSpacing.sp3,
          ),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor:
                        data.avatarColor.withValues(alpha: 0.15),
                    child: data.isGroup
                        ? Icon(Icons.groups_rounded,
                            color: data.avatarColor, size: 22)
                        : Text(
                            data.initials,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: data.avatarColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                  if (data.isOnline && !data.isGroup)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isDark ? AppColors.bgDark : Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.sp3),

              // Name + last message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (data.isPinned)
                          Padding(
                            padding:
                                const EdgeInsets.only(right: 4),
                            child: Icon(Icons.push_pin_rounded,
                                size: 12,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textDisabled),
                          ),
                        Expanded(
                          child: Text(
                            data.name,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                              fontWeight: data.unreadCount > 0
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          data.time,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: data.unreadCount > 0
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textDisabled),
                            fontSize: 11,
                            fontWeight: data.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (data.isMuted)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                                Icons.notifications_off_outlined,
                                size: 13,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textDisabled),
                          ),
                        Expanded(
                          child: Text(
                            data.lastMessage,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                              fontWeight: data.unreadCount > 0
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (data.unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: AppRadius.borderRadiusFull,
                            ),
                            child: Text(
                              data.unreadCount > 99
                                  ? '99+'
                                  : '${data.unreadCount}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BOTTOM SHEET OPTION
// ═══════════════════════════════════════════════════════════════════════════════

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp3, vertical: AppSpacing.sp3),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : const Color(0xFFF8FAFC),
          borderRadius: AppRadius.borderRadiusMd,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppSpacing.sp3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textDisabled),
          ],
        ),
      ),
    );
  }
}


