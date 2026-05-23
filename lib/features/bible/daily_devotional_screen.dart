import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/bible_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// DAILY DEVOTIONAL SCREEN
// ──────────────────────────────────────────────────────────────────────────────

class DailyDevotionalScreen extends ConsumerStatefulWidget {
  const DailyDevotionalScreen({super.key});

  @override
  ConsumerState<DailyDevotionalScreen> createState() =>
      _DailyDevotionalScreenState();
}

class _DailyDevotionalScreenState extends ConsumerState<DailyDevotionalScreen>
    with SingleTickerProviderStateMixin {
  // null = not yet overridden by the user; display falls back to devotional.isRead
  bool? _isMarkedRead;
  late final AnimationController _checkController;
  late final Animation<double> _checkScale;

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

  void _toggleRead(String devotionalId) {
    HapticFeedback.mediumImpact();
    final newVal = !(_isMarkedRead ?? false);
    setState(() => _isMarkedRead = newVal);
    if (newVal) {
      _checkController.forward(from: 0.0);
      ref.read(bibleRepositoryProvider).markDevotionalRead(devotionalId);
    } else {
      _checkController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final devotionalAsync = ref.watch(devotionalProvider);
    final streakAsync = ref.watch(devotionalStreakProvider);

    final appBar = AppFilledAppBar(
      title: 'Daily Devotional',
      showBack: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined, color: Colors.white, size: 22),
          onPressed: () {},
        ),
        const SizedBox(width: AppSpacing.sp2),
      ],
    );

    return devotionalAsync.when(
      loading: () => Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
        appBar: appBar,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
        appBar: appBar,
        body: Center(
          child: AppEmptyState(
            icon: Icons.menu_book_outlined,
            title: 'No Devotional Today',
            subtitle: 'Check back soon for today\'s devotional.',
          ),
        ),
      ),
      data: (devotional) {
        if (devotional == null) {
          return Scaffold(
            backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
            appBar: appBar,
            body: Center(
              child: AppEmptyState(
                icon: Icons.menu_book_outlined,
                title: 'No Devotional Today',
                subtitle: 'Check back soon for today\'s devotional.',
              ),
            ),
          );
        }

        final isRead = _isMarkedRead ?? devotional.isRead;
        final streak = streakAsync.value;

        return Scaffold(
          backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
          appBar: appBar,
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.sp5),

                if (streak != null) ...[
                  _StreakBanner(streakDays: streak.currentStreak, isDark: isDark),
                  const SizedBox(height: AppSpacing.sp6),
                ],

                // ── Date Header ──────────────────────────────────────────────
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
                        devotional.dayOfWeek.toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sp3),
                    Text(
                      devotional.date,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sp5),

                // ── Title ────────────────────────────────────────────────────
                Text(
                  devotional.title,
                  style: AppTextStyles.displayMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: AppSpacing.sp2),

                // ── Author & Reading Time ────────────────────────────────────
                Row(
                  children: [
                    Text(
                      devotional.author,
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
                      devotional.readingTime,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sp8),

                // ── Scripture Card ───────────────────────────────────────────
                _ScriptureCard(
                  reference: devotional.scripture,
                  text: devotional.scriptureText,
                  isDark: isDark,
                ),

                const SizedBox(height: AppSpacing.sp8),

                // ── Devotional Body ──────────────────────────────────────────
                Text(
                  devotional.body,
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

                // ── Reflection Prompt ────────────────────────────────────────
                _ReflectionCard(
                  prompt: devotional.reflectionPrompt,
                  isDark: isDark,
                ),

                const SizedBox(height: AppSpacing.sp8),

                // ── Mark as Read ─────────────────────────────────────────────
                Center(
                  child: AppTapAnimation(
                    onTap: () => _toggleRead(devotional.id),
                    child: Column(
                      children: [
                        ScaleTransition(
                          scale: (_isMarkedRead != null && isRead)
                              ? _checkScale
                              : const AlwaysStoppedAnimation(1.0),
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isRead
                                  ? AppColors.success
                                  : (isDark
                                      ? AppColors.cardDark
                                      : AppColors.inputFill),
                              border: Border.all(
                                color: isRead
                                    ? AppColors.success
                                    : (isDark
                                        ? AppColors.borderDark
                                        : AppColors.inputBorder),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              isRead ? Icons.check : Icons.check_outlined,
                              size: 28,
                              color: isRead
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textDisabled),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sp3),
                        Text(
                          isRead ? 'Completed!' : 'Mark as Read',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: isRead
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
      },
    );
  }
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
          Icon(Icons.format_quote, color: AppColors.gold, size: 28),
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
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  const _ReflectionCard({required this.prompt, required this.isDark});

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
              Icon(Icons.psychology_outlined, size: 20, color: AppColors.primary),
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
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              height: 1.7,
            ),
          ),
          const SizedBox(height: AppSpacing.sp4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sp4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgDark : AppColors.surface,
              borderRadius: AppRadius.borderRadiusMd,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.inputBorder,
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
