import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/chat.dart';
import '../../core/providers/chat_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_bars.dart';
import '../../shared/widgets/app_tap_animation.dart';

/// ══════════════════════════════════════════════════════════════════════════════
/// CHAT CONVERSATION SCREEN
///
/// Full chat view for a 1:1 or group conversation.
/// Features:
///   - Chat bubbles with tails (sent vs received styling)
///   - Typing indicator animation
///   - Message timestamps grouped by time
///   - Text input with send button
///   - Header shows online status
///   - Scroll to bottom on new message
///   - Long-press message actions (copy, reply)
/// ══════════════════════════════════════════════════════════════════════════════

class ChatConversationScreen extends ConsumerStatefulWidget {
  const ChatConversationScreen({
    super.key,
    required this.chatId,
    this.chatName,
  });

  final String chatId;
  final String? chatName;

  @override
  ConsumerState<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends ConsumerState<ChatConversationScreen>
    with SingleTickerProviderStateMixin {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late final AnimationController _typingCtrl;

  @override
  void initState() {
    super.initState();
    _typingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _typingCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    ref.read(conversationNotifierProvider(widget.chatId).notifier).sendMessage(text);
    _msgCtrl.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final convState = ref.watch(conversationNotifierProvider(widget.chatId));
    final messages = convState.messages;
    final isTyping = convState.isTyping;
    final meta = convState.meta ?? ChatMeta(
      name: widget.chatName ?? 'Chat',
      initials: '?',
      color: AppColors.primary,
      isOnline: false,
    );
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF8FAFC),
      appBar: AppFilledAppBar(
        title: meta.name,
        showBack: true,
        actions: [
          AppTapAnimation(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Voice call started')),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.call_outlined, size: 20),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, size: 20),
            onSelected: (v) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$v selected')),
              );
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'View Profile', child: Text('View Profile')),
              PopupMenuItem(value: 'Search', child: Text('Search in Chat')),
              PopupMenuItem(value: 'Mute', child: Text('Mute Notifications')),
              PopupMenuItem(value: 'Clear', child: Text('Clear Chat')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Online status bar ──────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sp4, vertical: 6),
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: meta.isOnline
                        ? const Color(0xFF22C55E)
                        : AppColors.textDisabled,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  meta.isGroup
                      ? '${meta.memberCount} members'
                      : (meta.isOnline ? 'Online' : 'Last seen recently'),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: meta.isOnline
                        ? const Color(0xFF22C55E)
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textDisabled),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // ── Messages ──────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sp3,
                vertical: AppSpacing.sp3,
              ),
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, i) {
                // Typing indicator
                if (i == messages.length && isTyping) {
                  return _TypingIndicator(
                    name: meta.name.split(' ').first,
                    color: meta.color,
                    initials: meta.initials,
                    animation: _typingCtrl,
                    isDark: isDark,
                  );
                }

                final msg = messages[i];

                // Show time separator
                Widget? separator;
                if (i == 0 ||
                    messages[i].time != messages[i - 1].time &&
                        !['Just now'].contains(msg.time)) {
                  separator = _TimeSeparator(
                      label: msg.timeGroup, isDark: isDark);
                }

                return Column(
                  children: [
                    if (separator != null) separator,
                    _ChatBubble(
                      message: msg,
                      isDark: isDark,
                      showSender:
                          meta.isGroup && !msg.isMe,
                    ),
                  ],
                );
              },
            ),
          ),

          // ── Input bar ─────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.sp3,
              AppSpacing.sp2,
              AppSpacing.sp3,
              bottomInset > 0 ? AppSpacing.sp2 : AppSpacing.sp4,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Attachment
                  AppTapAnimation(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Attachments coming soon')),
                      );
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        size: 20,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sp2),

                  // Text field
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
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
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : const Color(0xFFE2E8F0),
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
                      maxLines: 4,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sp2),

                  // Send button
                  AppTapAnimation(
                    onTap: _sendMessage,
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
// CHAT BUBBLE
// ═══════════════════════════════════════════════════════════════════════════════

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.isDark,
    this.showSender = false,
  });
  final ChatMessage message;
  final bool isDark;
  final bool showSender;

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: AppSpacing.sp2),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp3, vertical: AppSpacing.sp2),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.primary
              : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showSender)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.sender,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: message.senderColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            Text(
              message.text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isMe
                    ? Colors.white
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.time,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isMe
                          ? Colors.white.withValues(alpha: 0.7)
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textDisabled),
                      fontSize: 10,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.done_all_rounded,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TYPING INDICATOR
// ═══════════════════════════════════════════════════════════════════════════════

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator({
    required this.name,
    required this.color,
    required this.initials,
    required this.animation,
    required this.isDark,
  });
  final String name;
  final Color color;
  final String initials;
  final Animation<double> animation;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sp2),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp3, vertical: AppSpacing.sp2),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$name is typing',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            AnimatedBuilder(
              animation: animation,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  return Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textDisabled)
                          .withValues(
                        alpha: (animation.value - i * 0.2)
                            .clamp(0.3, 1.0),
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TIME SEPARATOR
// ═══════════════════════════════════════════════════════════════════════════════

class _TimeSeparator extends StatelessWidget {
  const _TimeSeparator({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sp3),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp3),
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textDisabled,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE2E8F0),
            ),
          ),
        ],
      ),
    );
  }
}


