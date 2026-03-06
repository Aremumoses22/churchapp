import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// READING PLAN SCREEN
//
// Browse reading plans (e.g., "21 Days of Faith"), progress ring,
// daily checklist, community participation count.
// ──────────────────────────────────────────────────────────────────────────────

class ReadingPlanScreen extends StatefulWidget {
  const ReadingPlanScreen({super.key});

  @override
  State<ReadingPlanScreen> createState() => _ReadingPlanScreenState();
}

class _ReadingPlanScreenState extends State<ReadingPlanScreen> {
  int _selectedTabIndex = 0; // 0 = My Plans, 1 = Browse

  // ── Mock data ──────────────────────────────────────────────────────────────
  final _myPlans = [
    _PlanData(
      title: '21 Days of Faith',
      description: 'A journey through the heroes of faith in Hebrews 11',
      progress: 14,
      totalDays: 21,
      participants: 1247,
      imageColor: const Color(0xFF1E3A8A),
      isActive: true,
      todayReading: 'Hebrews 11:23-31',
      todayTitle: 'Day 14: The Faith of Moses',
    ),
    _PlanData(
      title: 'Psalms of Comfort',
      description: 'Find peace and rest in the Psalms',
      progress: 5,
      totalDays: 30,
      participants: 893,
      imageColor: const Color(0xFF059669),
      isActive: true,
      todayReading: 'Psalm 27:1-14',
      todayTitle: 'Day 5: The Lord is My Light',
    ),
  ];

  final _browsePlans = [
    _PlanData(
      title: 'The Sermon on the Mount',
      description: 'Explore Jesus\' most famous teachings over 14 days',
      progress: 0,
      totalDays: 14,
      participants: 3421,
      imageColor: const Color(0xFF7C3AED),
      isActive: false,
    ),
    _PlanData(
      title: 'Proverbs: Wisdom for Life',
      description: 'One chapter of Proverbs each day for 31 days',
      progress: 0,
      totalDays: 31,
      participants: 2156,
      imageColor: const Color(0xFFDC2626),
      isActive: false,
    ),
    _PlanData(
      title: 'Letters of Paul',
      description: 'Journey through Paul\'s epistles to the early church',
      progress: 0,
      totalDays: 60,
      participants: 1834,
      imageColor: const Color(0xFF0891B2),
      isActive: false,
    ),
    _PlanData(
      title: 'Genesis: In the Beginning',
      description: 'Discover God\'s creation story and covenant promises',
      progress: 0,
      totalDays: 45,
      participants: 1502,
      imageColor: const Color(0xFFB45309),
      isActive: false,
    ),
    _PlanData(
      title: 'Advent Devotional',
      description: 'Prepare your heart for Christmas in 25 days',
      progress: 0,
      totalDays: 25,
      participants: 4210,
      imageColor: const Color(0xFF9F1239),
      isActive: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Reading Plans',
        showBack: true,
      ),
      body: Column(
        children: [
          // ── Tab Switcher ─────────────────────────────────────────────────
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

          // ── Content ──────────────────────────────────────────────────────
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

  // ── My Plans Tab ──────────────────────────────────────────────────────────

  Widget _buildMyPlans(bool isDark) {
    if (_myPlans.isEmpty) {
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
        ..._myPlans.map((plan) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sp4),
              child: _ActivePlanCard(plan: plan, isDark: isDark),
            )),
        const SizedBox(height: AppSpacing.sp4),
        // Today's checklist for the first active plan
        _TodayChecklist(plan: _myPlans.first, isDark: isDark),
        const SizedBox(height: AppSpacing.sp12),
      ],
    );
  }

  // ── Browse Plans Tab ──────────────────────────────────────────────────────

  Widget _buildBrowsePlans(bool isDark) {
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
        ..._browsePlans.map((plan) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sp3),
              child: _BrowsePlanCard(plan: plan, isDark: isDark),
            )),
        const SizedBox(height: AppSpacing.sp12),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// DATA MODEL
// ──────────────────────────────────────────────────────────────────────────────

class _PlanData {
  const _PlanData({
    required this.title,
    required this.description,
    required this.progress,
    required this.totalDays,
    required this.participants,
    required this.imageColor,
    required this.isActive,
    this.todayReading,
    this.todayTitle,
  });

  final String title;
  final String description;
  final int progress;
  final int totalDays;
  final int participants;
  final Color imageColor;
  final bool isActive;
  final String? todayReading;
  final String? todayTitle;

  double get progressPercent => progress / totalDays;
  int get daysRemaining => totalDays - progress;
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
  const _ActivePlanCard({required this.plan, required this.isDark});
  final _PlanData plan;
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
          // Progress Ring
          _ProgressRing(
            progress: plan.progressPercent,
            color: plan.imageColor,
            size: 72,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(plan.progressPercent * 100).round()}%',
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
                  plan.title,
                  style: AppTextStyles.headingSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Day ${plan.progress} of ${plan.totalDays} · ${plan.daysRemaining} days left',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sp2),
                // Progress bar
                ClipRRect(
                  borderRadius: AppRadius.borderRadiusFull,
                  child: LinearProgressIndicator(
                    value: plan.progressPercent,
                    backgroundColor: isDark
                        ? AppColors.borderDark
                        : AppColors.inputFill,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(plan.imageColor),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: AppSpacing.sp2),
                // Community count
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
                      '${_formatCount(plan.participants)} reading together',
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
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textDisabled,
          ),
        ],
      ),
    );
  }
}

class _TodayChecklist extends StatefulWidget {
  const _TodayChecklist({required this.plan, required this.isDark});
  final _PlanData plan;
  final bool isDark;

  @override
  State<_TodayChecklist> createState() => _TodayChecklistState();
}

class _TodayChecklistState extends State<_TodayChecklist> {
  final List<bool> _checked = [false, false, false];

  final _items = const [
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
              Icon(
                Icons.task_alt_outlined,
                size: 20,
                color: AppColors.gold,
              ),
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
          if (widget.plan.todayTitle != null) ...[
            const SizedBox(height: AppSpacing.sp2),
            Text(
              widget.plan.todayTitle!,
              style: AppTextStyles.bodySmall.copyWith(
                color: widget.isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ],
          if (widget.plan.todayReading != null) ...[
            const SizedBox(height: 2),
            Text(
              widget.plan.todayReading!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sp4),
          ...List.generate(_items.length, (i) => _ChecklistItem(
                label: _items[i],
                isChecked: _checked[i],
                isDark: widget.isDark,
                onChanged: (val) {
                  HapticFeedback.lightImpact();
                  setState(() => _checked[i] = val ?? false);
                },
              )),
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
                decoration: isChecked
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrowsePlanCard extends StatelessWidget {
  const _BrowsePlanCard({required this.plan, required this.isDark});
  final _PlanData plan;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: () {
        // TODO: navigate to plan detail
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sp4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: AppRadius.borderRadiusLg,
          boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
        ),
        child: Row(
          children: [
            // Plan icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: plan.imageColor.withValues(alpha: 0.1),
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: Center(
                child: Icon(
                  Icons.menu_book_outlined,
                  color: plan.imageColor,
                  size: 28,
                ),
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
                        _formatCount(plan.participants),
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

// ── Progress Ring Widget ────────────────────────────────────────────────────

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.progress,
    required this.color,
    this.size = 64,
    this.strokeWidth = 5,
    this.child,
  });

  final double progress;
  final Color color;
  final double size;
  final double strokeWidth;
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
              strokeWidth: strokeWidth,
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

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
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

// ── Helper ──────────────────────────────────────────────────────────────────

String _formatCount(int count) {
  if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1)}K';
  }
  return count.toString();
}
