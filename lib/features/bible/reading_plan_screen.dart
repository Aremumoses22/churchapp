import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/bible.dart';
import '../../core/providers/bible_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// READING PLAN SCREEN
// ──────────────────────────────────────────────────────────────────────────────

class ReadingPlanScreen extends ConsumerStatefulWidget {
  const ReadingPlanScreen({super.key});

  @override
  ConsumerState<ReadingPlanScreen> createState() => _ReadingPlanScreenState();
}

class _ReadingPlanScreenState extends ConsumerState<ReadingPlanScreen> {
  int _selectedTabIndex = 0; // 0 = My Plans, 1 = Browse

  static const _kColors = [
    Color(0xFF1E3A8A),
    Color(0xFF059669),
    Color(0xFF7C3AED),
    Color(0xFFDC2626),
    Color(0xFF0891B2),
    Color(0xFFB45309),
    Color(0xFF9F1239),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(title: 'Reading Plans', showBack: true),
      body: Column(
        children: [
          // ── Tab Switcher ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontalPadding,
              vertical: AppSpacing.sp4,
            ),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.inputFill,
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: Row(
                children: [
                  _TabButton(
                    label: 'My Plans',
                    isActive: _selectedTabIndex == 0,
                    isDark: isDark,
                    onTap: () => setState(() => _selectedTabIndex = 0),
                  ),
                  _TabButton(
                    label: 'Browse',
                    isActive: _selectedTabIndex == 1,
                    isDark: isDark,
                    onTap: () => setState(() => _selectedTabIndex = 1),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _selectedTabIndex == 0
                  ? _buildMyPlans(isDark)
                  : _buildBrowsePlans(isDark),
            ),
          ),
        ],
      ),
    );
  }

  // ── My Plans Tab ────────────────────────────────────────────────────────────

  Widget _buildMyPlans(bool isDark) {
    final myPlansAsync = ref.watch(myReadingPlansProvider);

    return myPlansAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: AppEmptyState(
          icon: Icons.menu_book_outlined,
          title: 'No Active Plans',
          subtitle: 'Browse reading plans to start your journey',
          buttonLabel: 'Browse Plans',
          onButtonPressed: () => setState(() => _selectedTabIndex = 1),
        ),
      ),
      data: (myPlans) {
        if (myPlans.isEmpty) {
          return Center(
            child: AppEmptyState(
              icon: Icons.menu_book_outlined,
              title: 'No Active Plans',
              subtitle: 'Browse reading plans to start your journey',
              buttonLabel: 'Browse Plans',
              onButtonPressed: () => setState(() => _selectedTabIndex = 1),
            ),
          );
        }

        return ListView(
          key: const ValueKey('my-plans'),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontalPadding,
          ),
          children: [
            ...myPlans.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sp4),
                  child: _ActivePlanCard(
                    userPlan: e.value,
                    color: _kColors[e.key % _kColors.length],
                    isDark: isDark,
                  ),
                )),
            const SizedBox(height: AppSpacing.sp4),
            _TodayChecklist(userPlan: myPlans.first, isDark: isDark),
            const SizedBox(height: AppSpacing.sp12),
          ],
        );
      },
    );
  }

  // ── Browse Plans Tab ────────────────────────────────────────────────────────

  Widget _buildBrowsePlans(bool isDark) {
    final plansAsync = ref.watch(readingPlansProvider);

    return plansAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: AppEmptyState(
          icon: Icons.menu_book_outlined,
          title: 'No Plans Available',
          subtitle: 'Check back soon for reading plans.',
        ),
      ),
      data: (plans) {
        if (plans.isEmpty) {
          return Center(
            child: AppEmptyState(
              icon: Icons.menu_book_outlined,
              title: 'No Plans Available',
              subtitle: 'Check back soon for reading plans.',
            ),
          );
        }

        return ListView(
          key: const ValueKey('browse-plans'),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontalPadding,
          ),
          children: [
            Text(
              'Popular Plans',
              style: AppTextStyles.headingMedium.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sp4),
            ...plans.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sp3),
                  child: _BrowsePlanCard(
                    plan: e.value,
                    color: _kColors[e.key % _kColors.length],
                    isDark: isDark,
                  ),
                )),
            const SizedBox(height: AppSpacing.sp12),
          ],
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// PRIVATE SUB-WIDGETS
// ──────────────────────────────────────────────────────────────────────────────

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? AppColors.primaryLight : AppColors.primary)
                : Colors.transparent,
            borderRadius: AppRadius.borderRadiusSm,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isActive
                    ? AppColors.textInverse
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivePlanCard extends StatelessWidget {
  const _ActivePlanCard({
    required this.userPlan,
    required this.color,
    required this.isDark,
  });

  final UserReadingPlan userPlan;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surface,
        borderRadius: AppRadius.borderRadiusLg,
        boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
      ),
      child: Row(
        children: [
          _ProgressRing(
            progress: userPlan.progressPercent,
            color: color,
            size: 72,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(userPlan.progressPercent * 100).round()}%',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sp4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userPlan.plan.title,
                  style: AppTextStyles.headingSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Day ${userPlan.currentDay} of ${userPlan.plan.totalDays} · ${userPlan.daysRemaining} days left',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sp2),
                ClipRRect(
                  borderRadius: AppRadius.borderRadiusFull,
                  child: LinearProgressIndicator(
                    value: userPlan.progressPercent,
                    backgroundColor:
                        isDark ? AppColors.borderDark : AppColors.inputFill,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: AppSpacing.sp2),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textDisabled,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatCount(userPlan.plan.participantCount)} reading together',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textDisabled,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sp2),
          Icon(
            Icons.chevron_right,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textDisabled,
          ),
        ],
      ),
    );
  }
}

class _TodayChecklist extends StatefulWidget {
  const _TodayChecklist({required this.userPlan, required this.isDark});
  final UserReadingPlan userPlan;
  final bool isDark;

  @override
  State<_TodayChecklist> createState() => _TodayChecklistState();
}

class _TodayChecklistState extends State<_TodayChecklist> {
  final List<bool> _checked = [false, false, false];

  static const _items = [
    'Read today\'s scripture passage',
    'Reflect on the devotional prompt',
    'Pray for understanding and application',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp4),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.cardDark : AppColors.surface,
        borderRadius: AppRadius.borderRadiusLg,
        boxShadow: widget.isDark ? AppShadows.smDark : AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.task_alt_outlined, size: 20, color: AppColors.gold),
              const SizedBox(width: AppSpacing.sp2),
              Text(
                "Today's Checklist",
                style: AppTextStyles.headingSmall.copyWith(
                  color: widget.isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp2),
          Text(
            'Day ${widget.userPlan.currentDay} · ${widget.userPlan.plan.title}',
            style: AppTextStyles.bodySmall.copyWith(
              color: widget.isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sp4),
          ...List.generate(
            _items.length,
            (i) => _ChecklistItem(
              label: _items[i],
              isChecked: _checked[i],
              isDark: widget.isDark,
              onChanged: (val) {
                HapticFeedback.lightImpact();
                setState(() => _checked[i] = val ?? false);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({
    required this.label,
    required this.isChecked,
    required this.isDark,
    required this.onChanged,
  });

  final String label;
  final bool isChecked;
  final bool isDark;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sp2),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: isChecked,
              onChanged: onChanged,
              activeColor: AppColors.success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              side: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.inputBorder,
                width: 1.5,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sp3),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isChecked
                    ? (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textDisabled)
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary),
                decoration:
                    isChecked ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrowsePlanCard extends StatelessWidget {
  const _BrowsePlanCard({
    required this.plan,
    required this.color,
    required this.isDark,
  });

  final ReadingPlan plan;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sp4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: AppRadius.borderRadiusLg,
          boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: Center(
                child: Icon(Icons.menu_book_outlined, color: color, size: 28),
              ),
            ),
            const SizedBox(width: AppSpacing.sp3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.title,
                    style: AppTextStyles.bodyLargeSemiBold.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    plan.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sp2),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textDisabled,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${plan.totalDays} days',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textDisabled,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sp3),
                      Icon(
                        Icons.people_outline,
                        size: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textDisabled,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatCount(plan.participantCount),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textDisabled,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sp2),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sp3,
                vertical: AppSpacing.sp1 + 2,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primaryLight.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.08),
                borderRadius: AppRadius.borderRadiusFull,
              ),
              child: Text(
                'Start',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Progress Ring ────────────────────────────────────────────────────────────

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.progress,
    required this.color,
    this.size = 64,
    this.child,
  });

  final double progress;
  final Color color;
  final double size;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: progress,
              color: color,
              backgroundColor:
                  isDark ? AppColors.borderDark : AppColors.inputFill,
              strokeWidth: 5,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

// ── Helper ───────────────────────────────────────────────────────────────────

String _formatCount(int count) {
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
  return count.toString();
}
