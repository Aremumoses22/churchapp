import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SERVICE ROSTER SCREEN
//
// Calendar view of your upcoming volunteer shifts, swap request button,
// check-in on service day.
// ──────────────────────────────────────────────────────────────────────────────

class ServiceRosterScreen extends StatefulWidget {
  const ServiceRosterScreen({super.key});

  @override
  State<ServiceRosterScreen> createState() => _ServiceRosterScreenState();
}

class _ServiceRosterScreenState extends State<ServiceRosterScreen> {
  int _selectedTab = 0; // 0 = upcoming, 1 = past
  int _selectedMonth = DateTime.now().month - 1;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  // Mock scheduled shifts
  final List<_ShiftData> _upcoming = [
    _ShiftData(
      date: DateTime.now().add(const Duration(days: 2)),
      role: 'Camera Operator',
      ministry: 'Media',
      service: '1st Service — 8:00 AM',
      teamLead: 'John M.',
      canCheckIn: true,
      color: const Color(0xFF2563EB),
      icon: Icons.videocam_outlined,
    ),
    _ShiftData(
      date: DateTime.now().add(const Duration(days: 9)),
      role: 'Welcome Team',
      ministry: 'Ushering',
      service: '2nd Service — 10:30 AM',
      teamLead: 'Sarah K.',
      canCheckIn: false,
      color: const Color(0xFFF59E0B),
      icon: Icons.waving_hand_outlined,
    ),
    _ShiftData(
      date: DateTime.now().add(const Duration(days: 16)),
      role: 'Camera Operator',
      ministry: 'Media',
      service: '1st Service — 8:00 AM',
      teamLead: 'John M.',
      canCheckIn: false,
      color: const Color(0xFF2563EB),
      icon: Icons.videocam_outlined,
    ),
    _ShiftData(
      date: DateTime.now().add(const Duration(days: 30)),
      role: 'Coffee Bar Host',
      ministry: 'Hospitality',
      service: 'Both Services — 7:30 AM',
      teamLead: 'Grace L.',
      canCheckIn: false,
      color: const Color(0xFFB45309),
      icon: Icons.coffee_outlined,
    ),
  ];

  final List<_ShiftData> _past = [
    _ShiftData(
      date: DateTime.now().subtract(const Duration(days: 5)),
      role: 'Camera Operator',
      ministry: 'Media',
      service: '1st Service — 8:00 AM',
      teamLead: 'John M.',
      canCheckIn: false,
      attended: true,
      color: const Color(0xFF2563EB),
      icon: Icons.videocam_outlined,
    ),
    _ShiftData(
      date: DateTime.now().subtract(const Duration(days: 12)),
      role: 'Welcome Team',
      ministry: 'Ushering',
      service: '2nd Service — 10:30 AM',
      teamLead: 'Sarah K.',
      canCheckIn: false,
      attended: true,
      color: const Color(0xFFF59E0B),
      icon: Icons.waving_hand_outlined,
    ),
    _ShiftData(
      date: DateTime.now().subtract(const Duration(days: 19)),
      role: 'Sound Engineer',
      ministry: 'Media',
      service: '1st Service — 8:00 AM',
      teamLead: 'John M.',
      canCheckIn: false,
      attended: false,
      color: const Color(0xFF2563EB),
      icon: Icons.graphic_eq_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(title: 'My Roster', showBack: true),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.sp3),

          // ── Tab toggle ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontalPadding),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.inputFill,
                borderRadius: AppRadius.borderRadiusFull,
              ),
              child: Row(
                children: List.generate(2, (i) {
                  final sel = _selectedTab == i;
                  final labels = ['Upcoming', 'Past'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: sel
                              ? (isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary)
                              : Colors.transparent,
                          borderRadius: AppRadius.borderRadiusFull,
                        ),
                        child: Center(
                          child: Text(labels[i],
                              style: AppTextStyles.labelSmall.copyWith(
                                  color: sel
                                      ? Colors.white
                                      : (isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary))),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sp4),

          // ── Month selector ─────────────────────────────────────────
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding),
              itemCount: _months.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSpacing.sp2),
              itemBuilder: (context, i) {
                final sel = _selectedMonth == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMonth = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sp3),
                    decoration: BoxDecoration(
                      color: sel
                          ? (isDark
                              ? AppColors.primaryLight
                              : AppColors.primary)
                          : Colors.transparent,
                      borderRadius: AppRadius.borderRadiusFull,
                      border: sel
                          ? null
                          : Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.inputBorder),
                    ),
                    child: Center(
                      child: Text(_months[i],
                          style: AppTextStyles.labelSmall.copyWith(
                            color: sel
                                ? Colors.white
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary),
                          )),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.sp4),

          // ── Shift list ─────────────────────────────────────────────
          Expanded(
            child: () {
              final shifts = _selectedTab == 0 ? _upcoming : _past;
              if (shifts.isEmpty) {
                return Center(
                  child: AppEmptyState(
                    icon: Icons.calendar_today_outlined,
                    title: 'No Shifts',
                    subtitle: 'You have no scheduled volunteer shifts.',
                    buttonLabel: 'Browse Opportunities',
                    onButtonPressed: () => Navigator.of(context).pop(),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontalPadding),
                itemCount: shifts.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
                  child: _ShiftCard(
                    shift: shifts[i],
                    isDark: isDark,
                    isPast: _selectedTab == 1,
                    onSwapRequest: () => _showSwapSheet(context, shifts[i], isDark),
                    onCheckIn: shifts[i].canCheckIn
                        ? () => _checkIn(context, shifts[i])
                        : null,
                  ),
                ),
              );
            }(),
          ),
        ],
      ),
    );
  }

  void _checkIn(BuildContext context, _ShiftData shift) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Checked in for ${shift.role}! God bless your service.'),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSm),
    ));
  }

  void _showSwapSheet(BuildContext context, _ShiftData shift, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: AppRadius.borderRadiusXlTop,
        ),
        padding: EdgeInsets.fromLTRB(
            AppSpacing.sp6,
            AppSpacing.sp3,
            AppSpacing.sp6,
            MediaQuery.of(context).padding.bottom + AppSpacing.sp6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.inactive,
                  borderRadius: AppRadius.borderRadiusFull),
            ),
            const SizedBox(height: AppSpacing.sp5),
            Icon(Icons.swap_horiz,
                size: 48,
                color: isDark ? AppColors.primaryLight : AppColors.primary),
            const SizedBox(height: AppSpacing.sp4),
            Text('Request Swap',
                style: AppTextStyles.headingSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.sp2),
            Text(
              'Would you like to request a swap for your "${shift.role}" shift? '
              'Your team lead will be notified and help find a replacement.',
              style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sp6),
            AppPrimaryButton(
              label: 'Send Swap Request',
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Swap request sent to your team lead.'),
                  backgroundColor: AppColors.info,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusSm),
                ));
              },
              isFullWidth: true,
            ),
            const SizedBox(height: AppSpacing.sp3),
            AppGhostButton(
                label: 'Cancel',
                onPressed: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}

// ── Data ─────────────────────────────────────────────────────────────────────

class _ShiftData {
  _ShiftData({
    required this.date,
    required this.role,
    required this.ministry,
    required this.service,
    required this.teamLead,
    required this.canCheckIn,
    required this.color,
    required this.icon,
    this.attended,
  });

  final DateTime date;
  final String role;
  final String ministry;
  final String service;
  final String teamLead;
  final bool canCheckIn;
  final Color color;
  final IconData icon;
  final bool? attended;
}

// ── Widgets ─────────────────────────────────────────────────────────────────

class _ShiftCard extends StatelessWidget {
  const _ShiftCard({
    required this.shift,
    required this.isDark,
    required this.isPast,
    required this.onSwapRequest,
    this.onCheckIn,
  });

  final _ShiftData shift;
  final bool isDark;
  final bool isPast;
  final VoidCallback onSwapRequest;
  final VoidCallback? onCheckIn;

  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final day = _dayNames[shift.date.weekday - 1];
    final month = _monthNames[shift.date.month - 1];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surface,
        borderRadius: AppRadius.borderRadiusLg,
        boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
        border: shift.canCheckIn
            ? Border.all(color: AppColors.success.withValues(alpha: 0.4), width: 1.5)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date pill
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sp2),
            decoration: BoxDecoration(
              color: shift.color.withValues(alpha: 0.1),
              borderRadius: AppRadius.borderRadiusMd,
            ),
            child: Column(
              children: [
                Text(day,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: shift.color, fontSize: 10)),
                Text('${shift.date.day}',
                    style: AppTextStyles.headingMedium
                        .copyWith(color: shift.color)),
                Text(month,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: shift.color, fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sp3),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(shift.role,
                          style: AppTextStyles.bodyLargeSemiBold.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary)),
                    ),
                    if (isPast && shift.attended != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: shift.attended!
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.error.withValues(alpha: 0.1),
                          borderRadius: AppRadius.borderRadiusFull,
                        ),
                        child: Text(
                          shift.attended! ? 'Attended' : 'Missed',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: shift.attended!
                                ? AppColors.success
                                : AppColors.error,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(shift.service,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textDisabled),
                    const SizedBox(width: 4),
                    Text('Lead: ${shift.teamLead}',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textDisabled,
                            fontSize: 11)),
                  ],
                ),
                if (!isPast) ...[
                  const SizedBox(height: AppSpacing.sp3),
                  Row(
                    children: [
                      if (shift.canCheckIn)
                        Expanded(
                          child: SizedBox(
                            height: 34,
                            child: ElevatedButton.icon(
                              onPressed: onCheckIn,
                              icon: const Icon(Icons.check_circle_outline,
                                  size: 16),
                              label: const Text('Check In'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                                textStyle: AppTextStyles.labelSmall,
                                shape: RoundedRectangleBorder(
                                    borderRadius: AppRadius.borderRadiusFull),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ),
                      if (shift.canCheckIn)
                        const SizedBox(width: AppSpacing.sp2),
                      GestureDetector(
                        onTap: onSwapRequest,
                        child: Container(
                          height: 34,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sp3),
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.borderRadiusFull,
                            border: Border.all(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.inputBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.swap_horiz, size: 14,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text('Swap',
                                  style: AppTextStyles.labelSmall.copyWith(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                      fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
