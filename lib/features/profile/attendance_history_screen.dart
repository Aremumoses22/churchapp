import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// ATTENDANCE HISTORY SCREEN
//
// Calendar heatmap showing service attendance, total count, streak.
// ──────────────────────────────────────────────────────────────────────────────

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  int _selectedMonth = DateTime.now().month - 1;
  int _selectedYear = DateTime.now().year;

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const _dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  // Mock attendance data: set of attended dates
  static final _attended = <DateTime>{
    // Sundays attended over past months
    ..._generateSundays(DateTime(2026, 1, 1), DateTime(2026, 2, 23)),
    // Some missed Sundays
  };

  static Set<DateTime> _generateSundays(DateTime start, DateTime end) {
    final sundays = <DateTime>{};
    var d = start;
    while (d.isBefore(end)) {
      if (d.weekday == DateTime.sunday) {
        // Skip some randomly for realism
        if (d.day != 19 && d.day != 26) {
          sundays.add(DateTime(d.year, d.month, d.day));
        }
      }
      d = d.add(const Duration(days: 1));
    }
    return sundays;
  }

  bool _wasAttended(DateTime day) {
    return _attended.contains(DateTime(day.year, day.month, day.day));
  }

  bool _isSunday(DateTime day) => day.weekday == DateTime.sunday;

  int get _totalAttended => _attended.length;

  int get _currentStreak {
    var streak = 0;
    var d = DateTime.now();
    // Walk backwards through Sundays
    while (true) {
      // Find previous Sunday
      while (d.weekday != DateTime.sunday) {
        d = d.subtract(const Duration(days: 1));
      }
      if (_wasAttended(d)) {
        streak++;
        d = d.subtract(const Duration(days: 7));
      } else {
        break;
      }
    }
    return streak;
  }

  void _prevMonth() {
    setState(() {
      if (_selectedMonth == 0) {
        _selectedMonth = 11;
        _selectedYear--;
      } else {
        _selectedMonth--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_selectedMonth == 11) {
        _selectedMonth = 0;
        _selectedYear++;
      } else {
        _selectedMonth++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(title: 'Attendance', showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontalPadding),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.sp4),

            // ── Stats row ──────────────────────────────────────────────
            Row(
              children: [
                _StatCard(
                  value: '$_totalAttended',
                  label: 'Services\nAttended',
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                  isDark: isDark,
                ),
                const SizedBox(width: AppSpacing.sp3),
                _StatCard(
                  value: '$_currentStreak',
                  label: 'Week\nStreak',
                  icon: Icons.local_fire_department_outlined,
                  color: const Color(0xFFF59E0B),
                  isDark: isDark,
                ),
                const SizedBox(width: AppSpacing.sp3),
                _StatCard(
                  value: '92%',
                  label: 'Attendance\nRate',
                  icon: Icons.trending_up_outlined,
                  color: AppColors.primary,
                  isDark: isDark,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sp6),

            // ── Calendar header ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSpacing.sp4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.surface,
                borderRadius: AppRadius.borderRadiusLg,
                boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
              ),
              child: Column(
                children: [
                  // Month navigator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _prevMonth,
                        child: Icon(Icons.chevron_left,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary),
                      ),
                      Text(
                        '${_monthNames[_selectedMonth]} $_selectedYear',
                        style: AppTextStyles.bodyLargeSemiBold.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary),
                      ),
                      GestureDetector(
                        onTap: _nextMonth,
                        child: Icon(Icons.chevron_right,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sp4),

                  // Day labels
                  Row(
                    children: _dayLabels
                        .map((l) => Expanded(
                              child: Center(
                                child: Text(l,
                                    style: AppTextStyles.labelSmall.copyWith(
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textDisabled,
                                        fontSize: 11)),
                              ),
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: AppSpacing.sp2),

                  // Calendar grid
                  _buildCalendarGrid(isDark),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sp5),

            // ── Legend ─────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(
                    color: AppColors.success, label: 'Attended', isDark: isDark),
                const SizedBox(width: AppSpacing.sp5),
                _LegendDot(
                    color: AppColors.error.withValues(alpha: 0.3),
                    label: 'Missed',
                    isDark: isDark),
                const SizedBox(width: AppSpacing.sp5),
                _LegendDot(
                    color: isDark ? AppColors.borderDark : AppColors.inputFill,
                    label: 'Non-Service',
                    isDark: isDark),
              ],
            ),

            const SizedBox(height: AppSpacing.sp6),

            // ── Recent attendance list ─────────────────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Recent Attendance',
                  style: AppTextStyles.headingSmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary)),
            ),
            const SizedBox(height: AppSpacing.sp3),

            ..._buildRecentList(isDark),

            const SizedBox(height: AppSpacing.sp10),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(bool isDark) {
    final firstDay =
        DateTime(_selectedYear, _selectedMonth + 1, 1);
    final daysInMonth =
        DateTime(_selectedYear, _selectedMonth + 2, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0 = Sunday

    final cells = <Widget>[];

    // Empty cells before first day
    for (var i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }

    // Day cells
    for (var day = 1; day <= daysInMonth; day++) {
      final date =
          DateTime(_selectedYear, _selectedMonth + 1, day);
      final sunday = _isSunday(date);
      final attended = _wasAttended(date);
      final today = DateTime.now();
      final isToday = date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final isPast = date.isBefore(today);

      Color bgColor;
      Color textColor;

      if (sunday && attended) {
        bgColor = AppColors.success;
        textColor = Colors.white;
      } else if (sunday && isPast && !attended) {
        bgColor = AppColors.error.withValues(alpha: 0.15);
        textColor = AppColors.error;
      } else {
        bgColor = isDark ? AppColors.bgDark : AppColors.inputFill;
        textColor = isDark
            ? AppColors.textSecondaryDark
            : AppColors.textDisabled;
      }

      cells.add(
        Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.borderRadiusSm,
            border: isToday
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: Center(
            child: Text('$day',
                style: AppTextStyles.labelSmall.copyWith(
                    color: textColor, fontSize: 11)),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      children: cells,
    );
  }

  List<Widget> _buildRecentList(bool isDark) {
    final recentSundays = <DateTime>[];
    var d = DateTime.now();
    for (var i = 0; i < 6; i++) {
      while (d.weekday != DateTime.sunday) {
        d = d.subtract(const Duration(days: 1));
      }
      recentSundays.add(DateTime(d.year, d.month, d.day));
      d = d.subtract(const Duration(days: 1));
    }

    return recentSundays.map((sunday) {
      final attended = _wasAttended(sunday);
      final monthShort = _monthNames[sunday.month - 1].substring(0, 3);

      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sp2),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sp4, vertical: AppSpacing.sp3),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.surface,
            borderRadius: AppRadius.borderRadiusMd,
            boxShadow: isDark ? AppShadows.xsDark : AppShadows.xs,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: attended
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  attended
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  size: 18,
                  color: attended ? AppColors.success : AppColors.error,
                ),
              ),
              const SizedBox(width: AppSpacing.sp3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sunday Service',
                        style: AppTextStyles.labelMedium.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary)),
                    Text('$monthShort ${sunday.day}, ${sunday.year}',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                            fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: attended
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderRadiusFull,
                ),
                child: Text(
                  attended ? 'Present' : 'Absent',
                  style: AppTextStyles.labelSmall.copyWith(
                      color:
                          attended ? AppColors.success : AppColors.error,
                      fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

// ── Widgets ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sp3),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: AppRadius.borderRadiusMd,
          boxShadow: isDark ? AppShadows.xsDark : AppShadows.xs,
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: AppSpacing.sp1),
            Text(value,
                style: AppTextStyles.headingMedium
                    .copyWith(color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(label,
                style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    fontSize: 10),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    required this.isDark,
  });

  final Color color;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textDisabled,
                fontSize: 10)),
      ],
    );
  }
}
