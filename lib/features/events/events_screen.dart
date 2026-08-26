import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/event.dart';
import '../../core/providers/event_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// EVENTS SCREEN — Section 10  (Enhanced)
//
// Layout:
//   1. App bar with 3-mode toggle (List / Calendar / Map)
//   2. Countdown timer — live ticking banner for next upcoming event
//   3. Event list / calendar / map views
//   4. Event cards with photo previews from past editions
//   5. Registration confirmation bottom sheet
// ──────────────────────────────────────────────────────────────────────────────

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {

  String _countdownText(Duration timeUntilNext) {
    if (timeUntilNext <= Duration.zero) return 'Starting now!';
    final d = timeUntilNext.inDays;
    final h = timeUntilNext.inHours % 24;
    final m = timeUntilNext.inMinutes % 60;
    final s = timeUntilNext.inSeconds % 60;
    if (d > 0) return 'Starts in ${d}d ${h}h ${m}m';
    if (h > 0) return 'Starts in ${h}h ${m}m ${s}s';
    return 'Starts in ${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final eState = ref.watch(eventNotifierProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Events',
        actions: [
          // View mode toggle
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ViewModeChip(
                icon: Icons.list,
                label: 'List',
                isActive: eState.viewMode == 0,
                isDark: isDark,
                onTap: () {
                  ref.read(eventNotifierProvider.notifier).setViewMode(0);
                  ref.read(eventNotifierProvider.notifier).selectDay(null);
                },
              ),
              const SizedBox(width: 4),
              _ViewModeChip(
                icon: Icons.calendar_month,
                label: 'Cal',
                isActive: eState.viewMode == 1,
                isDark: isDark,
                onTap: () {
                  ref.read(eventNotifierProvider.notifier).setViewMode(1);
                  ref.read(eventNotifierProvider.notifier).selectDay(null);
                },
              ),
              const SizedBox(width: 4),
              _ViewModeChip(
                icon: Icons.map_outlined,
                label: 'Map',
                isActive: eState.viewMode == 2,
                isDark: isDark,
                onTap: () {
                  ref.read(eventNotifierProvider.notifier).setViewMode(2);
                  ref.read(eventNotifierProvider.notifier).selectDay(null);
                },
              ),
              const SizedBox(width: AppSpacing.sp2),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Countdown Timer Banner ──────────────────────────────────
          if (eState.timeUntilNext > Duration.zero)
            _CountdownBanner(
              eventTitle: eState.nextEventTitle,
              countdownText: _countdownText(eState.timeUntilNext),
              isDark: isDark,
            ),

          // ── View Body ──────────────────────────────────────────────
          Expanded(
            child: eState.viewMode == 0
                ? _buildListView(isDark)
                : eState.viewMode == 1
                    ? _buildCalendarView(isDark)
                    : _buildMapView(isDark),
          ),
        ],
      ),
    );
  }

  // ── List View ─────────────────────────────────────────────────────────────
  Widget _buildListView(bool isDark) {
    final events = ref.read(eventNotifierProvider).allEvents;
    if (events.isEmpty) {
      return const AppEmptyState(
        icon: Icons.event_busy,
        title: 'No upcoming events',
        subtitle: 'Check back soon for new events.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.sp4),
      itemCount: events.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sp3),
        child: _EventCard(event: events[i], isDark: isDark),
      ),
    );
  }

  // ── Calendar View ─────────────────────────────────────────────────────────
  Widget _buildCalendarView(bool isDark) {
    final eState = ref.read(eventNotifierProvider);
    return Column(
      children: [
        // Month navigation
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sp4, vertical: AppSpacing.sp3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  final fm = ref.read(eventNotifierProvider).focusMonth!;
                  ref.read(eventNotifierProvider.notifier).setFocusMonth(
                      DateTime(fm.year, fm.month - 1));
                  ref.read(eventNotifierProvider.notifier).selectDay(null);
                },
                child: Icon(Icons.chevron_left,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary),
              ),
              Text(
                _monthName(eState.focusMonth!),
                style: AppTextStyles.headingSmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  final fm = ref.read(eventNotifierProvider).focusMonth!;
                  ref.read(eventNotifierProvider.notifier).setFocusMonth(
                      DateTime(fm.year, fm.month + 1));
                  ref.read(eventNotifierProvider.notifier).selectDay(null);
                },
                child: Icon(Icons.chevron_right,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary),
              ),
            ],
          ),
        ),

        // Day headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
          child: Row(
            children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.sp2),

        // Calendar grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
          child: _buildCalendarGrid(isDark),
        ),

        const AppDivider(),

        // Selected day events
        Expanded(
          child: eState.selectedDay != null && eState.eventsByDay[eState.selectedDay] != null
              ? ListView(
                  padding: const EdgeInsets.all(AppSpacing.sp4),
                  children: eState.eventsByDay[eState.selectedDay]!
                      .map((e) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sp3),
                            child: _EventCard(event: e, isDark: isDark),
                          ))
                      .toList(),
                )
              : Center(
                  child: Text(
                    eState.selectedDay != null
                        ? 'No events on this day'
                        : 'Select a day to see events',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // ── Map View ──────────────────────────────────────────────────────────────
  Widget _buildMapView(bool isDark) {
    final events = ref.read(eventNotifierProvider).allEvents;
    return Stack(
      children: [
        // Mock map background
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1A1D23)
                : const Color(0xFFE8F0FE),
          ),
          child: CustomPaint(
            painter: _MapGridPainter(isDark: isDark),
            size: Size.infinite,
          ),
        ),

        // Event pins
        ..._buildMapPins(events, isDark),

        // Map legend
        Positioned(
          top: AppSpacing.sp4,
          left: AppSpacing.sp4,
          right: AppSpacing.sp4,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sp4, vertical: AppSpacing.sp3),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.surface,
              borderRadius: AppRadius.borderRadiusLg,
              boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
            ),
            child: Row(
              children: [
                Icon(Icons.map_outlined,
                    size: 18,
                    color: isDark
                        ? AppColors.primaryLight
                        : AppColors.primary),
                const SizedBox(width: AppSpacing.sp2),
                Text(
                  '${events.length} events nearby',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  'Tap a pin for details',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMapPins(List<Event> events, bool isDark) {
    // Mock positions for each event
    const positions = [
      Offset(0.25, 0.30),
      Offset(0.65, 0.25),
      Offset(0.45, 0.55),
      Offset(0.75, 0.65),
    ];

    return List.generate(events.length, (i) {
      final pos = positions[i % positions.length];
      final event = events[i];
      return Positioned(
        left: pos.dx *
            (MediaQuery.of(context).size.width - 60),
        top: 80 +
            pos.dy *
                (MediaQuery.of(context).size.height * 0.45),
        child: GestureDetector(
          onTap: () => _showMapEventSheet(event, isDark),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.cardDark : AppColors.surface,
                  borderRadius: AppRadius.borderRadiusSm,
                  boxShadow:
                      isDark ? AppShadows.smDark : AppShadows.sm,
                ),
                child: Text(
                  event.title,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _eventCategoryColor(event),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _eventCategoryColor(event)
                          .withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.location_on,
                    color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showMapEventSheet(Event event, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? AppColors.cardDark : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.sp5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.borderDark
                      : AppColors.inputFill,
                  borderRadius: AppRadius.borderRadiusFull,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sp4),
            Text(event.title,
                style: AppTextStyles.headingSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.sp2),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 14, color: AppColors.gold),
                const SizedBox(width: 6),
                Text(event.dateFormatted,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: AppSpacing.sp1),
            Row(
              children: [
                Icon(Icons.location_on,
                    size: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(event.location ?? '',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: AppSpacing.sp4),
            SizedBox(
              width: double.infinity,
              child: AppPrimaryButton(
                label: 'View Details',
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/events/${event.id}');
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sp2),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(bool isDark) {
    final eState = ref.read(eventNotifierProvider);
    final focusMonth = eState.focusMonth!;
    final firstDay = DateTime(focusMonth.year, focusMonth.month, 1);
    final daysInMonth =
        DateTime(focusMonth.year, focusMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0 = Sun

    final cells = <Widget>[];

    // Empty cells before first day
    for (var i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }

    final today = DateTime.now();
    final isCurrentMonth =
        today.year == focusMonth.year && today.month == focusMonth.month;

    for (var day = 1; day <= daysInMonth; day++) {
      final hasEvent = eState.eventsByDay.containsKey(day);
      final isToday = isCurrentMonth && today.day == day;
      final isSelected = eState.selectedDay == day;
      final currentDay = day;

      cells.add(
        GestureDetector(
          onTap: () => ref.read(eventNotifierProvider.notifier).selectDay(currentDay),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isToday
                  ? (isDark ? AppColors.primaryLight : AppColors.primary)
                  : isSelected
                      ? (isDark ? AppColors.skyDark : AppColors.skyLight)
                      : null,
              shape: BoxShape.circle,
              border: isSelected && !isToday
                  ? Border.all(
                      color:
                          isDark ? AppColors.primaryLight : AppColors.primary,
                      width: 1.5)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isToday
                        ? AppColors.textInverse
                        : isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                    fontWeight: isToday ? FontWeight.w600 : null,
                  ),
                ),
                if (hasEvent)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          isToday ? AppColors.textInverse : AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
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

  String _monthName(DateTime dt) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// COUNTDOWN BANNER — live ticking timer for next event
// ═══════════════════════════════════════════════════════════════════════════════

class _CountdownBanner extends StatelessWidget {
  const _CountdownBanner({
    required this.eventTitle,
    required this.countdownText,
    required this.isDark,
  });

  final String eventTitle;
  final String countdownText;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sp4, vertical: AppSpacing.sp3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.primaryLight.withValues(alpha: 0.15),
                  AppColors.gold.withValues(alpha: 0.08),
                ]
              : [
                  AppColors.skyLight,
                  AppColors.goldLight.withValues(alpha: 0.3),
                ],
        ),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.inputBorder,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Pulsing dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.5),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sp3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEXT UP',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.gold,
                    letterSpacing: 1.2,
                    fontSize: 9,
                  ),
                ),
                Text(
                  eventTitle,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primaryLight.withValues(alpha: 0.2)
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: AppRadius.borderRadiusFull,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined,
                    size: 13,
                    color: isDark
                        ? AppColors.primaryLight
                        : AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  countdownText,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.primaryLight
                        : AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// VIEW MODE CHIP — small toggle for list/cal/map
// ═══════════════════════════════════════════════════════════════════════════════

class _ViewModeChip extends StatelessWidget {
  const _ViewModeChip({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark
                  ? AppColors.primaryLight.withValues(alpha: 0.2)
                  : AppColors.primary.withValues(alpha: 0.1))
              : Colors.transparent,
          borderRadius: AppRadius.borderRadiusFull,
          border: isActive
              ? Border.all(
                  color: isDark
                      ? AppColors.primaryLight
                      : AppColors.primary,
                  width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: isActive
                    ? (isDark
                        ? AppColors.primaryLight
                        : AppColors.primary)
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary)),
            const SizedBox(width: 3),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 10,
                color: isActive
                    ? (isDark
                        ? AppColors.primaryLight
                        : AppColors.primary)
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MAP GRID PAINTER — mock map background
// ═══════════════════════════════════════════════════════════════════════════════

class _MapGridPainter extends CustomPainter {
  _MapGridPainter({required this.isDark});
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.04)
          : AppColors.primary.withValues(alpha: 0.06)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Horizontal lines
    for (var y = 0.0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical lines
    for (var x = 0.0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // A few "road" lines
    final roadPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.08)
          : AppColors.primary.withValues(alpha: 0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
        Offset(0, size.height * 0.4),
        Offset(size.width, size.height * 0.35),
        roadPaint);
    canvas.drawLine(
        Offset(size.width * 0.5, 0),
        Offset(size.width * 0.45, size.height),
        roadPaint);
    canvas.drawLine(
        Offset(0, size.height * 0.7),
        Offset(size.width, size.height * 0.75),
        roadPaint);
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

// ═══════════════════════════════════════════════════════════════════════════════
// HELPER — deterministic category color for events
// ═══════════════════════════════════════════════════════════════════════════════

Color _eventCategoryColor(Event event) {
  switch (event.category) {
    case EventCategory.worship:
      return const Color(0xFF6C63FF);
    case EventCategory.conference:
      return const Color(0xFF2196F3);
    case EventCategory.youth:
      return const Color(0xFFFF6B6B);
    case EventCategory.prayer:
      return const Color(0xFF4ECDC4);
    case EventCategory.outreach:
      return const Color(0xFFF59E0B);
    case EventCategory.fellowship:
      return const Color(0xFF8B5CF6);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// EVENT CARD — with photo preview row + registration confirmation sheet
// ═══════════════════════════════════════════════════════════════════════════════

class _EventCard extends StatefulWidget {
  const _EventCard({required this.event, required this.isDark});
  final Event event;
  final bool isDark;

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard>
    with SingleTickerProviderStateMixin {
  bool _registered = false;

  void _handleRegister() {
    setState(() => _registered = true);
    _showRegistrationSheet();
  }

  void _showRegistrationSheet() {
    final isDark = widget.isDark;
    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? AppColors.cardDark : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.sp5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.borderDark
                      : AppColors.inputFill,
                  borderRadius: AppRadius.borderRadiusFull,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sp5),

            // Checkmark circle
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle,
                  color: AppColors.success, size: 36),
            ),
            const SizedBox(height: AppSpacing.sp4),

            Text(
              "You're Registered!",
              style: AppTextStyles.headingSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sp2),
            Text(
              widget.event.title,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            Text(
              widget.event.dateFormatted,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sp5),

            // Add to Calendar
            SizedBox(
              width: double.infinity,
              child: AppPrimaryButton(
                label: 'Add to Calendar',
                icon: Icon(Icons.calendar_today,
                    color: Colors.white, size: 18),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            const SizedBox(height: AppSpacing.sp3),

            // Share
            SizedBox(
              width: double.infinity,
              child: AppSecondaryButton(
                label: 'Share with Friends',
                icon: Icon(Icons.share_outlined,
                    color: isDark
                        ? AppColors.primaryLight
                        : AppColors.primary,
                    size: 18),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            const SizedBox(height: AppSpacing.sp3),

            // Close text
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Text(
                'Done',
                style: AppTextStyles.labelMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sp2),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: () => context.push('/events/${widget.event.id}'),
      liftEffect: true,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: AppRadius.borderRadiusXl,
          boxShadow: widget.isDark ? AppShadows.smDark : AppShadows.sm,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner image
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _eventCategoryColor(widget.event),
                    _eventCategoryColor(widget.event).withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  if (widget.event.imageUrl != null)
                    Positioned.fill(
                      child: ClipRRect(
                        child: CachedNetworkImage(
                          imageUrl: widget.event.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => const SizedBox.shrink(),
                          errorWidget: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                    )
                  else
                    Center(
                      child: Icon(Icons.event,
                          color: Colors.white.withValues(alpha: 0.3),
                          size: 64),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? AppColors.primaryLight
                            : AppColors.primary,
                        borderRadius: AppRadius.borderRadiusSm,
                      ),
                      child: Text(
                        widget.event.dateFormatted,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textInverse,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sp4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: AppColors.gold),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.event.dateFormatted} \u00b7 ${widget.event.timeFormatted}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: widget.isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sp2),
                  Text(
                    widget.event.title,
                    style: AppTextStyles.headingSmall.copyWith(
                      color: widget.isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sp1),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 14,
                          color: widget.isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        widget.event.location ?? '',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: widget.isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sp2),
                  Row(
                    children: [
                      // Stacked avatars
                      SizedBox(
                        width: 52,
                        height: 24,
                        child: Stack(
                          children: List.generate(
                            3,
                            (i) => Positioned(
                              left: i * 16.0,
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: widget.isDark
                                    ? AppColors.primaryLight
                                    : AppColors.skyLight,
                                child: Text(
                                  ['G', 'D', 'S'][i],
                                  style:
                                      AppTextStyles.labelSmall.copyWith(
                                    color: widget.isDark
                                        ? AppColors.textInverse
                                        : AppColors.primary,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+${widget.event.registeredCount} attending',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: widget.isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sp3),
                  // Register button
                  SizedBox(
                    width: double.infinity,
                    child: _registered
                        ? AppPrimaryButton(
                            label: '\u2713 Registered',
                            onPressed: null,
                          )
                        : AppPrimaryButton(
                            label: 'Register Now',
                            onPressed: _handleRegister,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


