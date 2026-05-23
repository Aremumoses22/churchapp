import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/volunteer.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SERVICE ROSTER SCREEN
//
// Upcoming and past volunteer shifts from GET /volunteer/roster.
// Check-in via POST /volunteer/roster/:id/checkin.
// ──────────────────────────────────────────────────────────────────────────────

class ServiceRosterScreen extends ConsumerStatefulWidget {
  const ServiceRosterScreen({super.key});

  @override
  ConsumerState<ServiceRosterScreen> createState() =>
      _ServiceRosterScreenState();
}

class _ServiceRosterScreenState extends ConsumerState<ServiceRosterScreen> {
  int _selectedTab = 0;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static IconData _iconForMinistry(String ministry) {
    switch (ministry.toLowerCase()) {
      case 'media': return Icons.videocam_outlined;
      case 'ushering': return Icons.waving_hand_outlined;
      case 'children': return Icons.child_care_outlined;
      case 'worship': return Icons.mic_outlined;
      case 'hospitality': return Icons.coffee_outlined;
      case 'outreach': return Icons.restaurant_outlined;
      case 'prayer': return Icons.volunteer_activism_outlined;
      default: return Icons.handshake_outlined;
    }
  }

  static Color _colorForMinistry(String ministry) {
    switch (ministry.toLowerCase()) {
      case 'media': return const Color(0xFF2563EB);
      case 'ushering': return const Color(0xFFF59E0B);
      case 'children': return const Color(0xFFEC4899);
      case 'worship': return const Color(0xFF7C3AED);
      case 'hospitality': return const Color(0xFFB45309);
      case 'outreach': return const Color(0xFFDC2626);
      case 'prayer': return const Color(0xFF0891B2);
      default: return const Color(0xFF059669);
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${_months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final roster = ref.watch(rosterProvider);

    final upcoming =
        roster.where((s) => !s.isPast).toList();
    final past = roster.where((s) => s.isPast).toList();
    final shown = _selectedTab == 0 ? upcoming : past;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(title: 'My Roster', showBack: true),
      body: Column(
        children: [
          // Tab bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.inputFill,
                borderRadius: AppRadius.borderRadiusFull,
              ),
              child: Row(
                children: ['Upcoming', 'Past'].asMap().entries.map((e) {
                  final sel = _selectedTab == e.key;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = e.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.all(3),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: sel
                              ? (isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary)
                              : Colors.transparent,
                          borderRadius: AppRadius.borderRadiusFull,
                        ),
                        child: Center(
                          child: Text(
                            e.value,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: sel
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Expanded(
            child: shown.isEmpty
                ? AppEmptyState(
                    icon: Icons.event_available_outlined,
                    title: _selectedTab == 0
                        ? 'No upcoming shifts'
                        : 'No past shifts',
                    subtitle: _selectedTab == 0
                        ? 'Sign up for volunteer opportunities to see shifts here.'
                        : 'Your completed shifts will appear here.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontalPadding),
                    itemCount: shown.length,
                    itemBuilder: (context, i) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.cardGap),
                      child: _ShiftCard(
                        shift: shown[i],
                        isDark: isDark,
                        color: _colorForMinistry(shown[i].ministry),
                        icon: _iconForMinistry(shown[i].ministry),
                        formattedDate: _formatDate(shown[i].serviceDate),
                        onCheckIn: shown[i].canCheckIn && !shown[i].checkedIn
                            ? () async {
                                final ok = await ref
                                    .read(rosterProvider.notifier)
                                    .checkIn(shown[i].id);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(ok
                                      ? 'Checked in successfully!'
                                      : 'Check-in failed. Try again.'),
                                  backgroundColor:
                                      ok ? AppColors.success : AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                ));
                              }
                            : null,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Shift card ────────────────────────────────────────────────────────────────

class _ShiftCard extends StatelessWidget {
  const _ShiftCard({
    required this.shift,
    required this.isDark,
    required this.color,
    required this.icon,
    required this.formattedDate,
    this.onCheckIn,
  });

  final RosterShift shift;
  final bool isDark;
  final Color color;
  final IconData icon;
  final String formattedDate;
  final VoidCallback? onCheckIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surface,
        borderRadius: AppRadius.borderRadiusLg,
        boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
        border: shift.checkedIn
            ? Border.all(color: AppColors.success.withValues(alpha: 0.4))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: AppSpacing.sp3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(shift.role,
                        style: AppTextStyles.bodyLargeSemiBold.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(shift.ministry,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: color, fontSize: 11)),
                  ],
                ),
              ),
              if (shift.checkedIn)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: AppRadius.borderRadiusFull,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle,
                          size: 12, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text('Checked In',
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.success, fontSize: 10)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp3),
          if (formattedDate.isNotEmpty)
            _InfoRow(
                icon: Icons.calendar_today_outlined,
                text: formattedDate,
                isDark: isDark),
          if (shift.serviceName != null) ...[
            const SizedBox(height: AppSpacing.sp1),
            _InfoRow(
                icon: Icons.access_time_outlined,
                text: shift.serviceName!,
                isDark: isDark),
          ],
          if (shift.teamLead != null) ...[
            const SizedBox(height: AppSpacing.sp1),
            _InfoRow(
                icon: Icons.person_outline,
                text: 'Team Lead: ${shift.teamLead}',
                isDark: isDark),
          ],
          if (onCheckIn != null) ...[
            const SizedBox(height: AppSpacing.sp4),
            AppPrimaryButton(
              label: 'Check In Now',
              icon: const Icon(Icons.check_circle_outline,
                  color: Colors.white, size: 18),
              onPressed: onCheckIn,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.text, required this.isDark});
  final IconData icon;
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon,
            size: 13,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textDisabled),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary)),
        ),
      ],
    );
  }
}
