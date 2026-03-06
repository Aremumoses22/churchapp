import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SPIRITUAL JOURNEY / TIMELINE SCREEN
//
// Personal milestones: date joined, baptism, groups joined, giving milestones,
// sermons watched — visualized as a vertical timeline.
// ──────────────────────────────────────────────────────────────────────────────

class SpiritualJourneyScreen extends StatelessWidget {
  const SpiritualJourneyScreen({super.key});

  static final _milestones = <_MilestoneData>[
    _MilestoneData(
      date: DateTime(2024, 1, 14),
      title: 'Joined Grace Community',
      subtitle: 'Became a member of the church family',
      icon: Icons.church_outlined,
      color: const Color(0xFF1E3A8A),
      type: 'membership',
    ),
    _MilestoneData(
      date: DateTime(2024, 2, 4),
      title: 'First Sermon',
      subtitle: 'Watched "The Heart of Worship" by Pastor James',
      icon: Icons.play_circle_outline,
      color: const Color(0xFF2563EB),
      type: 'sermon',
    ),
    _MilestoneData(
      date: DateTime(2024, 3, 10),
      title: 'Joined a Connect Group',
      subtitle: 'Young Adults — Faith Builders',
      icon: Icons.groups_outlined,
      color: const Color(0xFF059669),
      type: 'group',
    ),
    _MilestoneData(
      date: DateTime(2024, 4, 7),
      title: 'First Tithe',
      subtitle: 'Gave your first offering of \$50',
      icon: Icons.favorite_outline,
      color: const Color(0xFFF59E0B),
      type: 'giving',
    ),
    _MilestoneData(
      date: DateTime(2024, 5, 19),
      title: 'Water Baptism',
      subtitle: 'Publicly declared your faith in Christ',
      icon: Icons.water_drop_outlined,
      color: const Color(0xFF7C3AED),
      type: 'baptism',
      isHighlight: true,
    ),
    _MilestoneData(
      date: DateTime(2024, 6, 2),
      title: '10 Sermons Watched',
      subtitle: 'Growing in the Word consistently',
      icon: Icons.headphones_outlined,
      color: const Color(0xFF2563EB),
      type: 'sermon',
    ),
    _MilestoneData(
      date: DateTime(2024, 7, 21),
      title: 'Started Volunteering',
      subtitle: 'Joined the Media Team as Camera Operator',
      icon: Icons.volunteer_activism_outlined,
      color: const Color(0xFF10B981),
      type: 'volunteer',
    ),
    _MilestoneData(
      date: DateTime(2024, 9, 15),
      title: '\$500 in Total Giving',
      subtitle: 'Faithful stewardship milestone',
      icon: Icons.stars_outlined,
      color: const Color(0xFFF59E0B),
      type: 'giving',
    ),
    _MilestoneData(
      date: DateTime(2024, 11, 3),
      title: 'Bible Reading Plan Completed',
      subtitle: 'Finished "30 Days of Psalms"',
      icon: Icons.menu_book_outlined,
      color: const Color(0xFF7C3AED),
      type: 'reading',
    ),
    _MilestoneData(
      date: DateTime(2025, 1, 12),
      title: '1 Year Anniversary',
      subtitle: 'One year of walking with Grace Community',
      icon: Icons.celebration_outlined,
      color: const Color(0xFFEC4899),
      type: 'membership',
      isHighlight: true,
    ),
    _MilestoneData(
      date: DateTime(2025, 3, 8),
      title: '50 Sermons Watched',
      subtitle: 'Deep in the Word of God',
      icon: Icons.headphones_outlined,
      color: const Color(0xFF2563EB),
      type: 'sermon',
    ),
    _MilestoneData(
      date: DateTime(2025, 6, 22),
      title: 'Led a Connect Group',
      subtitle: 'Stepped up as small group facilitator',
      icon: Icons.record_voice_over_outlined,
      color: const Color(0xFF059669),
      type: 'group',
    ),
    _MilestoneData(
      date: DateTime(2025, 12, 25),
      title: '\$2,000 in Total Giving',
      subtitle: 'Generous heart, eternal impact',
      icon: Icons.diamond_outlined,
      color: const Color(0xFFF59E0B),
      type: 'giving',
      isHighlight: true,
    ),
  ];

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reversed = _milestones.reversed.toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(title: 'My Journey', showBack: true),
      body: Column(
        children: [
          // ── Stats header ─────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
            padding: const EdgeInsets.all(AppSpacing.sp4),
            decoration: BoxDecoration(
              gradient: AppGradients.hero,
              borderRadius: AppRadius.borderRadiusLg,
            ),
            child: Row(
              children: [
                _StatPill(
                    value: '${_milestones.length}',
                    label: 'Milestones'),
                _StatDivider(),
                _StatPill(
                    value: '2 yrs',
                    label: 'Member'),
                _StatDivider(),
                _StatPill(
                    value: '50+',
                    label: 'Sermons'),
              ],
            ),
          ),

          // ── Timeline ─────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontalPadding,
                  0,
                  AppSpacing.screenHorizontalPadding,
                  AppSpacing.sp12),
              itemCount: reversed.length,
              itemBuilder: (context, i) {
                final m = reversed[i];
                final isLast = i == reversed.length - 1;

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline rail
                      SizedBox(
                        width: 44,
                        child: Column(
                          children: [
                            Container(
                              width: m.isHighlight ? 18 : 12,
                              height: m.isHighlight ? 18 : 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: m.color,
                                border: m.isHighlight
                                    ? Border.all(
                                        color: m.color
                                            .withValues(alpha: 0.3),
                                        width: 3)
                                    : null,
                                boxShadow: m.isHighlight
                                    ? [
                                        BoxShadow(
                                          color: m.color
                                              .withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        )
                                      ]
                                    : null,
                              ),
                            ),
                            if (!isLast)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.inputBorder,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Milestone card
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.sp4),
                          child: Container(
                            padding:
                                const EdgeInsets.all(AppSpacing.sp4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.cardDark
                                  : AppColors.surface,
                              borderRadius: AppRadius.borderRadiusMd,
                              boxShadow: m.isHighlight
                                  ? (isDark
                                      ? AppShadows.mdDark
                                      : AppShadows.md)
                                  : (isDark
                                      ? AppShadows.xsDark
                                      : AppShadows.xs),
                              border: m.isHighlight
                                  ? Border.all(
                                      color:
                                          m.color.withValues(alpha: 0.3),
                                      width: 1.5)
                                  : null,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: m.color
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            AppRadius.borderRadiusSm,
                                      ),
                                      child: Icon(m.icon,
                                          size: 18, color: m.color),
                                    ),
                                    const SizedBox(
                                        width: AppSpacing.sp3),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(m.title,
                                              style: AppTextStyles
                                                  .labelMedium
                                                  .copyWith(
                                                      color: isDark
                                                          ? AppColors
                                                              .textPrimaryDark
                                                          : AppColors
                                                              .textPrimary)),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${_monthNames[m.date.month - 1]} ${m.date.day}, ${m.date.year}',
                                            style: AppTextStyles
                                                .bodySmall
                                                .copyWith(
                                                    color: m.color,
                                                    fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (m.isHighlight)
                                      Icon(Icons.star,
                                          size: 18,
                                          color: AppColors.gold),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sp2),
                                Text(m.subtitle,
                                    style: AppTextStyles.bodySmall
                                        .copyWith(
                                            color: isDark
                                                ? AppColors
                                                    .textSecondaryDark
                                                : AppColors
                                                    .textSecondary,
                                            height: 1.4)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data ─────────────────────────────────────────────────────────────────────

class _MilestoneData {
  const _MilestoneData({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.type,
    this.isHighlight = false,
  });

  final DateTime date;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String type;
  final bool isHighlight;
}

// ── Helper widgets ──────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  const _StatPill({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: AppTextStyles.headingMedium
                  .copyWith(color: Colors.white)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 11)),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1,
        height: 36,
        color: Colors.white.withValues(alpha: 0.3));
  }
}
