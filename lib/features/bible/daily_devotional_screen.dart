import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// DAILY DEVOTIONAL SCREEN
//
// Date header, scripture passage, devotional body text, reflection prompt,
// "Mark as Read" checkmark, reading streak tracker with flame icon.
// ──────────────────────────────────────────────────────────────────────────────

class DailyDevotionalScreen extends StatefulWidget {
  const DailyDevotionalScreen({super.key});

  @override
  State<DailyDevotionalScreen> createState() => _DailyDevotionalScreenState();
}

class _DailyDevotionalScreenState extends State<DailyDevotionalScreen>
    with SingleTickerProviderStateMixin {
  bool _isMarkedRead = false;
  late AnimationController _checkController;
  late Animation<double> _checkScale;

  // ── Mock data ──────────────────────────────────────────────────────────────
  final _devotional = const _DevotionalData(
    date: 'January 15, 2025',
    dayOfWeek: 'Wednesday',
    title: 'Walking in Faith',
    scripture: 'Hebrews 11:1',
    scriptureText:
        'Now faith is the substance of things hoped for, the evidence of things not seen.',
    body:
        'Faith is not the absence of doubt, but the courage to move forward despite it. Today, we are reminded that our walk with God does not require perfection, but persistence.\n\n'
        'Abraham left his homeland not knowing where he was going. Moses confronted Pharaoh with nothing but a staff and a promise. David faced Goliath with stones and a sling.\n\n'
        'Each of these heroes had moments of uncertainty, yet they chose to trust. Their faith was not in their own strength but in the faithfulness of God.\n\n'
        'As you face this day, remember that faith is a muscle. The more you exercise it, the stronger it becomes. Every small act of trust — choosing prayer over worry, choosing hope over despair — builds the foundation for a deeper relationship with our Creator.',
    reflectionPrompt:
        'What is one area of your life where you are being called to step out in faith today? How can you surrender your need for certainty and trust God with the outcome?',
    author: 'Pastor David Mitchell',
    readingTime: '4 min read',
    streakDays: 12,
  );

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  void _toggleRead() {
    HapticFeedback.mediumImpact();
    setState(() => _isMarkedRead = !_isMarkedRead);
    if (_isMarkedRead) {
      _checkController.forward();
    } else {
      _checkController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Daily Devotional',
        showBack: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.share_outlined,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              size: 22,
            ),
            onPressed: () {
              // TODO: share devotional
            },
          ),
          const SizedBox(width: AppSpacing.sp2),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sp5),

            // ── Streak Banner ──────────────────────────────────────────────
            _StreakBanner(
              streakDays: _devotional.streakDays,
              isDark: isDark,
            ),

            const SizedBox(height: AppSpacing.sp6),

            // ── Date Header ────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sp3,
                    vertical: AppSpacing.sp1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: AppRadius.borderRadiusFull,
                  ),
                  child: Text(
                    _devotional.dayOfWeek.toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sp3),
                Text(
                  _devotional.date,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sp5),

            // ── Title ──────────────────────────────────────────────────────
            Text(
              _devotional.title,
              style: AppTextStyles.displayMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: AppSpacing.sp2),

            // ── Author & Reading Time ──────────────────────────────────────
            Row(
              children: [
                Text(
                  _devotional.author,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sp3),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textDisabled,
                  ),
                ),
                const SizedBox(width: AppSpacing.sp3),
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textDisabled,
                ),
                const SizedBox(width: 4),
                Text(
                  _devotional.readingTime,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sp8),

            // ── Scripture Card ─────────────────────────────────────────────
            _ScriptureCard(
              reference: _devotional.scripture,
              text: _devotional.scriptureText,
              isDark: isDark,
            ),

            const SizedBox(height: AppSpacing.sp8),

            // ── Devotional Body ────────────────────────────────────────────
            Text(
              _devotional.body,
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 17,
                fontWeight: FontWeight.w400,
                height: 1.9,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
                letterSpacing: 0.1,
              ),
            ),

            const SizedBox(height: AppSpacing.sp8),

            // ── Reflection Prompt ──────────────────────────────────────────
            _ReflectionCard(
              prompt: _devotional.reflectionPrompt,
              isDark: isDark,
            ),

            const SizedBox(height: AppSpacing.sp8),

            // ── Mark as Read ───────────────────────────────────────────────
            Center(
              child: AppTapAnimation(
                onTap: _toggleRead,
                child: Column(
                  children: [
                    ScaleTransition(
                      scale: _isMarkedRead
                          ? _checkScale
                          : const AlwaysStoppedAnimation(1.0),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isMarkedRead
                              ? AppColors.success
                              : (isDark
                                  ? AppColors.cardDark
                                  : AppColors.inputFill),
                          border: Border.all(
                            color: _isMarkedRead
                                ? AppColors.success
                                : (isDark
                                    ? AppColors.borderDark
                                    : AppColors.inputBorder),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _isMarkedRead
                              ? Icons.check
                              : Icons.check_outlined,
                          size: 28,
                          color: _isMarkedRead
                              ? Colors.white
                              : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textDisabled),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp3),
                    Text(
                      _isMarkedRead ? 'Completed!' : 'Mark as Read',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: _isMarkedRead
                            ? AppColors.success
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sp12),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// DATA MODEL
// ──────────────────────────────────────────────────────────────────────────────

class _DevotionalData {
  const _DevotionalData({
    required this.date,
    required this.dayOfWeek,
    required this.title,
    required this.scripture,
    required this.scriptureText,
    required this.body,
    required this.reflectionPrompt,
    required this.author,
    required this.readingTime,
    required this.streakDays,
  });

  final String date;
  final String dayOfWeek;
  final String title;
  final String scripture;
  final String scriptureText;
  final String body;
  final String reflectionPrompt;
  final String author;
  final String readingTime;
  final int streakDays;
}

// ──────────────────────────────────────────────────────────────────────────────
// PRIVATE SUB-WIDGETS
// ──────────────────────────────────────────────────────────────────────────────

class _StreakBanner extends StatelessWidget {
  const _StreakBanner({required this.streakDays, required this.isDark});
  final int streakDays;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp4,
        vertical: AppSpacing.sp3,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0.15),
            AppColors.gold.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Flame icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🔥', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: AppSpacing.sp3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streakDays-Day Streak!',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Keep your streak going! Read today\'s devotional.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Progress dots
          Row(
            children: List.generate(7, (i) {
              final isCompleted = i < (streakDays % 7);
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppColors.gold
                      : (isDark ? AppColors.borderDark : AppColors.inactive),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ScriptureCard extends StatelessWidget {
  const _ScriptureCard({
    required this.reference,
    required this.text,
    required this.isDark,
  });

  final String reference;
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sp5),
      decoration: BoxDecoration(
        gradient: isDark ? AppGradients.heroDark : AppGradients.hero,
        borderRadius: AppRadius.borderRadiusLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quote icon
          Icon(
            Icons.format_quote,
            color: AppColors.gold,
            size: 28,
          ),
          const SizedBox(height: AppSpacing.sp3),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 18,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              height: 1.7,
              color: AppColors.textInverse,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sp4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '— $reference',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.gold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  const _ReflectionCard({
    required this.prompt,
    required this.isDark,
  });

  final String prompt;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sp5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.skyLight,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(
          color: isDark
              ? AppColors.borderDark
              : AppColors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sp2),
              Text(
                'Reflect',
                style: AppTextStyles.labelMedium.copyWith(
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp3),
          Text(
            prompt,
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimary,
              height: 1.7,
            ),
          ),
          const SizedBox(height: AppSpacing.sp4),
          // Journal prompt
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sp4),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.bgDark
                  : AppColors.surface,
              borderRadius: AppRadius.borderRadiusMd,
              border: Border.all(
                color: isDark
                    ? AppColors.borderDark
                    : AppColors.inputBorder,
                width: 1,
              ),
            ),
            child: Text(
              'Tap to journal your thoughts...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textDisabled,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
