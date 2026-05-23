import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../core/repositories/user_repository.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// ATTENDANCE HISTORY SCREEN
//
// Loaded from GET /users/me/attendance via userNotifierProvider.
// ──────────────────────────────────────────────────────────────────────────────

class AttendanceHistoryScreen extends ConsumerStatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  ConsumerState<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState
    extends ConsumerState<AttendanceHistoryScreen> {
  int _selectedMonth = DateTime.now().month - 1;
  int _selectedYear = DateTime.now().year;

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const _dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(userNotifierProvider.notifier).fetchAttendance());
  }

  Set<DateTime> _attendedDates(List<AttendanceRecord> history) {
    final set = <DateTime>{};
    for (final r in history) {
      try {
        final dt = DateTime.parse(r.date);
        set.add(DateTime(dt.year, dt.month, dt.day));
      } catch (_) {}
    }
    return set;
  }

  bool _wasAttended(DateTime day, Set<DateTime> attended) =>
      attended.contains(DateTime(day.year, day.month, day.day));

  bool _isSunday(DateTime day) => day.weekday == DateTime.sunday;

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
    final now = DateTime.now();
    if (_selectedYear == now.year && _selectedMonth == now.month - 1) return;
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
    final userState = ref.watch(userNotifierProvider);
    final attendanceData = userState.attendance;

    if (attendanceData == null && userState.isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
        appBar: AppFilledAppBar(title: 'Attendance', showBack: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final attended = _attendedDates(attendanceData?.history ?? []);
    final streak = attendanceData?.streak ?? 0;
    final total = attendanceData?.totalAttendances ?? 0;

    final firstDay =
        DateTime(_selectedYear, _selectedMonth + 1, 1).weekday % 7;
    final daysInMonth =
        DateTime(_selectedYear, _selectedMonth + 2, 0).day;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(title: 'Attendance History', showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.sp4),
        child: Column(
          children: [
            Row(
              children: [
                _StatCard(
                  label: 'Total',
                  value: '$total',
                  icon: Icons.check_circle_outline,
                  isDark: isDark,
                ),
                const SizedBox(width: AppSpacing.sp3),
                _StatCard(
                  label: 'Streak',
                  value: '$streak wk',
                  icon: Icons.local_fire_department_outlined,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sp4),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sp4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.surface,
                borderRadius: AppRadius.borderRadiusLg,
                boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _prevMonth,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                      Text(
                        '${_monthNames[_selectedMonth]} $_selectedYear',
                        style: AppTextStyles.bodyLargeSemiBold.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _nextMonth,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sp3),
                  Row(
                    children: _dayLabels
                        .map((l) => Expanded(
                              child: Center(
                                child: Text(
                                  l,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: AppSpacing.sp2),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: firstDay + daysInMonth,
                    itemBuilder: (_, idx) {
                      if (idx < firstDay) return const SizedBox();
                      final day = DateTime(
                          _selectedYear, _selectedMonth + 1, idx - firstDay + 1);
                      final isSun = _isSunday(day);
                      final wasAtt = _wasAttended(day, attended);
                      final isToday = day.year == DateTime.now().year &&
                          day.month == DateTime.now().month &&
                          day.day == DateTime.now().day;

                      return Container(
                        decoration: BoxDecoration(
                          color: wasAtt
                              ? AppColors.success
                              : isSun
                                  ? (isDark
                                      ? AppColors.primary.withValues(alpha: 0.15)
                                      : AppColors.skyLight)
                                  : Colors.transparent,
                          shape: BoxShape.circle,
                          border: isToday
                              ? Border.all(color: AppColors.primary, width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: wasAtt
                                  ? Colors.white
                                  : isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: wasAtt
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sp4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(
                    color: AppColors.success,
                    label: 'Attended',
                    isDark: isDark),
                const SizedBox(width: AppSpacing.sp4),
                _LegendDot(
                    color: isDark
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.skyLight,
                    label: 'Sunday',
                    isDark: isDark),
              ],
            ),
            const SizedBox(height: AppSpacing.sp10),
          ],
        ),
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sp4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: AppRadius.borderRadiusLg,
          boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sp2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: AppTextStyles.headingSmall.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary)),
                Text(label,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot(
      {required this.color, required this.label, required this.isDark});

  final Color color;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary),
        ),
      ],
    );
  }
}
