import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// LIVE SERVICE SCREEN — Section 9
//
// Full-screen immersive: Video player, live info bar, Chat/Prayer/Bible tabs,
// floating reaction buttons, message input.
// ──────────────────────────────────────────────────────────────────────────────

class LiveServiceScreen extends StatefulWidget {
  const LiveServiceScreen({super.key});

  @override
  State<LiveServiceScreen> createState() => _LiveServiceScreenState();
}

class _LiveServiceScreenState extends State<LiveServiceScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _chatScroll = ScrollController();
  final List<_ChatMsg> _messages = _seedMessages();
  final List<_FloatingEmoji> _emojis = [];
  int _viewerCount = 1243;

  // Pulsing LIVE badge
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulseAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 1),
    ]).animate(_pulseCtrl);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _msgController.dispose();
    _chatScroll.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      body: SafeArea(
        child: Column(
          children: [
            // ── Video player area ──────────────────────────────────────
            _VideoPlayer(
              pulseAnim: _pulseAnim,
              viewerCount: _viewerCount,
              onBack: () => context.pop(),
            ),

            // ── Live info bar ──────────────────────────────────────────
            _LiveInfoBar(
              viewerCount: _viewerCount,
              isDark: isDark,
            ),

            // ── Tab bar ────────────────────────────────────────────────
            _buildTabBar(isDark),

            // ── Tab content ────────────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  TabBarView(
                    controller: _tabController,
                    children: [
                      _ChatTab(
                        messages: _messages,
                        scrollController: _chatScroll,
                        isDark: isDark,
                      ),
                      _PrayerTab(isDark: isDark),
                      _BibleTab(isDark: isDark),
                    ],
                  ),

                  // ── Floating reactions ─────────────────────────────
                  Positioned(
                    right: 12,
                    bottom: 80,
                    child: _ReactionButtons(onReact: _onReaction),
                  ),

                  // ── Floating emoji particles ───────────────────────
                  ..._emojis.map((e) => _FloatingEmojiWidget(key: ValueKey(e.id), data: e)),
                ],
              ),
            ),

            // ── Message input (Chat tab only) ──────────────────────────
            AnimatedBuilder(
              listenable: _tabController,
              builder: (_, __) => _tabController.index == 0
                  ? _MessageInput(
                      controller: _msgController,
                      isDark: isDark,
                      onSend: _sendMessage,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      color: isDark ? AppColors.cardDark : AppColors.surface,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2,
        labelColor: isDark ? AppColors.primaryLight : AppColors.primary,
        unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        labelStyle: AppTextStyles.labelMedium,
        tabs: const [
          Tab(text: 'Chat'),
          Tab(text: 'Prayer'),
          Tab(text: 'Bible'),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMsg(
        name: 'You',
        text: text,
        time: 'Now',
        isOwn: true,
      ));
    });
    _msgController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScroll.hasClients) {
        _chatScroll.animateTo(
          _chatScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onReaction(String emoji) {
    final rng = Random();
    final id = DateTime.now().microsecondsSinceEpoch;
    setState(() {
      _emojis.add(_FloatingEmoji(
        id: id,
        emoji: emoji,
        startX: MediaQuery.of(context).size.width - 40 + rng.nextDouble() * 20,
        startY: MediaQuery.of(context).size.height * 0.5,
      ));
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _emojis.removeWhere((e) => e.id == id));
    });
  }
}

// ── Animated Builder alias ──────────────────────────────────────────────────
class AnimatedBuilder extends AnimatedWidget {
  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
  });

  final Widget Function(BuildContext, Widget?) builder;

  Animation<dynamic> get animation => listenable as Animation<dynamic>;

  @override
  Widget build(BuildContext context) => builder(context, null);
}

// ── Video Player ────────────────────────────────────────────────────────────

class _VideoPlayer extends StatelessWidget {
  const _VideoPlayer({
    required this.pulseAnim,
    required this.viewerCount,
    required this.onBack,
  });

  final Animation<double> pulseAnim;
  final int viewerCount;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Placeholder for video stream
            const Center(
              child: Icon(Icons.live_tv, color: Colors.white38, size: 64),
            ),

            // Back button
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),
            ),

            // LIVE badge (pulsing dot)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      listenable: pulseAnim,
                      builder: (_, __) => Transform.scale(
                        scale: pulseAnim.value,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    const Icon(Icons.volume_up, color: Colors.white, size: 22),
                    const Spacer(),
                    const Icon(Icons.cast, color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    const Icon(Icons.fullscreen, color: Colors.white, size: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Live Info Bar ───────────────────────────────────────────────────────────

class _LiveInfoBar extends StatelessWidget {
  const _LiveInfoBar({required this.viewerCount, required this.isDark});

  final int viewerCount;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
      color: isDark ? AppColors.cardDark : AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Sunday Worship Service',
              style: AppTextStyles.bodyLargeSemiBold.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ),
          Icon(Icons.visibility,
              size: 16,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            '$viewerCount watching',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chat Tab ────────────────────────────────────────────────────────────────

class _ChatTab extends StatelessWidget {
  const _ChatTab({
    required this.messages,
    required this.scrollController,
    required this.isDark,
  });

  final List<_ChatMsg> messages;
  final ScrollController scrollController;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(AppSpacing.sp4),
      itemCount: messages.length,
      itemBuilder: (_, i) {
        final msg = messages[i];
        return Align(
          alignment: msg.isOwn ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sp3),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            child: Column(
              crossAxisAlignment:
                  msg.isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!msg.isOwn)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(msg.name,
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.gold)),
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (!msg.isOwn) ...[
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: isDark
                            ? AppColors.primaryLight
                            : AppColors.skyLight,
                        child: Text(
                          msg.name[0],
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark
                                ? AppColors.textInverse
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: msg.isOwn
                              ? (isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary)
                              : (isDark
                                  ? AppColors.cardDark
                                  : AppColors.surface),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isDark ? AppShadows.xsDark : AppShadows.xs,
                        ),
                        child: Text(
                          msg.text,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: msg.isOwn
                                ? AppColors.textInverse
                                : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
                  child: Text(
                    msg.time,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textDisabled,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Prayer Tab ──────────────────────────────────────────────────────────────

class _PrayerTab extends StatelessWidget {
  const _PrayerTab({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final prayers = [
      'Please pray for my healing.',
      'Pray for my family and finances.',
      'Strength during this season. God is faithful.',
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.sp4),
      itemCount: prayers.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sp3),
      itemBuilder: (_, i) => AppCard(
        child: Row(
          children: [
            const Icon(Icons.favorite, color: AppColors.gold, size: 20),
            const SizedBox(width: AppSpacing.sp3),
            Expanded(
              child: Text(
                prayers[i],
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ),
            Text("Pray",
                style: AppTextStyles.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.primaryLight
                        : AppColors.primary)),
          ],
        ),
      ),
    );
  }
}

// ── Bible Tab ───────────────────────────────────────────────────────────────

class _BibleTab extends StatelessWidget {
  const _BibleTab({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.sp4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Romans 8:28-31',
            style: AppTextStyles.headingSmall.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sp3),
          Text(
            '28 And we know that in all things God works for the good of those who love him, who have been called according to his purpose.\n\n'
            '29 For those God foreknew he also predestined to be conformed to the image of his Son, that he might be the firstborn among many brothers and sisters.\n\n'
            '30 And those he predestined, he also called; those he called, he also justified; those he justified, he also glorified.\n\n'
            '31 What, then, shall we say in response to these things? If God is for us, who can be against us?',
            style: AppTextStyles.verseText.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Message Input ───────────────────────────────────────────────────────────

class _MessageInput extends StatelessWidget {
  const _MessageInput({
    required this.controller,
    required this.isDark,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isDark;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sp4, vertical: AppSpacing.sp2),
      color: isDark ? AppColors.cardDark : AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.bgDark : const Color(0xFFF3F4F6),
                borderRadius: AppRadius.borderRadiusFull,
              ),
              child: TextField(
                controller: controller,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Say something...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDisabled,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.primaryLight : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: AppColors.textInverse, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reaction Buttons ────────────────────────────────────────────────────────

class _ReactionButtons extends StatelessWidget {
  const _ReactionButtons({required this.onReact});
  final void Function(String emoji) onReact;

  @override
  Widget build(BuildContext context) {
    const reactions = ['\u{1F64F}', '\u{2764}\u{FE0F}', '\u{1F525}'];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: reactions
          .map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => onReact(e),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                        child: Text(e, style: const TextStyle(fontSize: 24))),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

// ── Floating Emoji Widget ───────────────────────────────────────────────────

class _FloatingEmoji {
  _FloatingEmoji({
    required this.id,
    required this.emoji,
    required this.startX,
    required this.startY,
  });
  final int id;
  final String emoji;
  final double startX;
  final double startY;
}

class _FloatingEmojiWidget extends StatefulWidget {
  const _FloatingEmojiWidget({super.key, required this.data});
  final _FloatingEmoji data;

  @override
  State<_FloatingEmojiWidget> createState() => _FloatingEmojiWidgetState();
}

class _FloatingEmojiWidgetState extends State<_FloatingEmojiWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      listenable: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        return Positioned(
          left: widget.data.startX + sin(t * 3) * 10,
          top: widget.data.startY - (t * 120),
          child: Opacity(
            opacity: 1.0 - t,
            child: Transform.rotate(
              angle: t * 0.5,
              child: Text(widget.data.emoji,
                  style: const TextStyle(fontSize: 24)),
            ),
          ),
        );
      },
    );
  }
}

// ── Data models ─────────────────────────────────────────────────────────────

class _ChatMsg {
  const _ChatMsg({
    required this.name,
    required this.text,
    required this.time,
    this.isOwn = false,
  });
  final String name;
  final String text;
  final String time;
  final bool isOwn;
}

List<_ChatMsg> _seedMessages() => [
      const _ChatMsg(name: 'Grace', text: 'Amen! This message is so powerful', time: '10:23 AM'),
      const _ChatMsg(name: 'David', text: 'Watching from Lagos. God bless', time: '10:24 AM'),
      const _ChatMsg(name: 'Sarah', text: 'The worship was incredible today', time: '10:26 AM'),
      const _ChatMsg(name: 'You', text: 'Blessed to be here!', time: '10:27 AM', isOwn: true),
      const _ChatMsg(name: 'Michael', text: 'What a word! Glory to God', time: '10:29 AM'),
    ];
