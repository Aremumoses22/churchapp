import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// VOLUNTEER SCREEN
//
// Browse volunteer opportunities by ministry (Media, Ushering, Children,
// Worship, etc.), role descriptions, "Sign Up" flow.
// ──────────────────────────────────────────────────────────────────────────────

class VolunteerScreen extends StatefulWidget {
  const VolunteerScreen({super.key});

  @override
  State<VolunteerScreen> createState() => _VolunteerScreenState();
}

class _VolunteerScreenState extends State<VolunteerScreen> {
  int _selectedMinistry = 0;

  static const _ministries = [
    'All',
    'Media',
    'Ushering',
    'Children',
    'Worship',
    'Hospitality',
    'Outreach',
    'Prayer',
  ];

  static const _opportunities = [
    _OpportunityData(
      id: '1',
      title: 'Camera Operator',
      ministry: 'Media',
      description:
          'Operate PTZ and handheld cameras during Sunday services. Training provided for all skill levels.',
      commitment: '2 Sundays/month',
      schedule: 'Sundays 8:00 AM - 1:00 PM',
      spotsLeft: 3,
      totalSpots: 5,
      icon: Icons.videocam_outlined,
      color: Color(0xFF2563EB),
      skills: ['Attention to detail', 'Team player'],
    ),
    _OpportunityData(
      id: '2',
      title: 'Sound Engineer',
      ministry: 'Media',
      description:
          'Mix live audio for worship and spoken word. Experience with digital mixing consoles preferred.',
      commitment: '2 Sundays/month',
      schedule: 'Sundays 7:30 AM - 1:00 PM',
      spotsLeft: 1,
      totalSpots: 3,
      icon: Icons.graphic_eq_outlined,
      color: Color(0xFF2563EB),
      skills: ['Audio experience', 'Technical aptitude'],
    ),
    _OpportunityData(
      id: '3',
      title: 'Welcome Team',
      ministry: 'Ushering',
      description:
          'Be the first smile visitors see! Greet guests, hand out bulletins, and help people find seats.',
      commitment: '1 Sunday/month',
      schedule: 'Sundays 8:30 - 11:00 AM',
      spotsLeft: 6,
      totalSpots: 10,
      icon: Icons.waving_hand_outlined,
      color: Color(0xFFF59E0B),
      skills: ['Friendly personality', 'Punctual'],
    ),
    _OpportunityData(
      id: '4',
      title: 'Parking Attendant',
      ministry: 'Ushering',
      description:
          'Direct traffic and help members find parking. High-visibility vests and two-way radios provided.',
      commitment: '2 Sundays/month',
      schedule: 'Sundays 7:30 - 11:30 AM',
      spotsLeft: 4,
      totalSpots: 8,
      icon: Icons.local_parking_outlined,
      color: Color(0xFFF59E0B),
      skills: ['Outdoor readiness', 'Clear communication'],
    ),
    _OpportunityData(
      id: '5',
      title: 'Sunday School Teacher',
      ministry: 'Children',
      description:
          'Lead engaging Bible lessons for kids ages 4-8. Curriculum and materials provided. Background check required.',
      commitment: '2 Sundays/month',
      schedule: 'Sundays 9:30 - 11:30 AM',
      spotsLeft: 2,
      totalSpots: 6,
      icon: Icons.child_care_outlined,
      color: Color(0xFFEC4899),
      skills: ['Loves children', 'Patient', 'Creative'],
    ),
    _OpportunityData(
      id: '6',
      title: 'Nursery Volunteer',
      ministry: 'Children',
      description:
          'Care for infants and toddlers (0-3) during services. Rocking, feeding, and lots of love!',
      commitment: '1 Sunday/month',
      schedule: 'Sundays 9:00 AM - 12:30 PM',
      spotsLeft: 5,
      totalSpots: 8,
      icon: Icons.baby_changing_station_outlined,
      color: Color(0xFFEC4899),
      skills: ['Gentle spirit', 'CPR certified preferred'],
    ),
    _OpportunityData(
      id: '7',
      title: 'Worship Singer',
      ministry: 'Worship',
      description:
          'Join the vocal team for Sunday worship. Audition required. Wednesday rehearsals mandatory.',
      commitment: 'Weekly rehearsal + 2 Sundays/month',
      schedule: 'Wed 7 PM + Sundays 7:30 AM',
      spotsLeft: 2,
      totalSpots: 4,
      icon: Icons.mic_outlined,
      color: Color(0xFF7C3AED),
      skills: ['Vocal ability', 'Team harmony', 'Committed'],
    ),
    _OpportunityData(
      id: '8',
      title: 'Coffee Bar Host',
      ministry: 'Hospitality',
      description:
          'Serve hot coffee, tea, and pastries in our lobby. Create a warm atmosphere for fellowship.',
      commitment: '1 Sunday/month',
      schedule: 'Sundays 8:00 - 11:00 AM',
      spotsLeft: 4,
      totalSpots: 6,
      icon: Icons.coffee_outlined,
      color: Color(0xFFB45309),
      skills: ['Friendly', 'Food handling basics'],
    ),
    _OpportunityData(
      id: '9',
      title: 'Community Kitchen',
      ministry: 'Outreach',
      description:
          'Help prepare and serve meals for our weekly community kitchen feeding 200+ people.',
      commitment: 'Saturdays (flexible)',
      schedule: 'Saturdays 8:00 AM - 2:00 PM',
      spotsLeft: 8,
      totalSpots: 15,
      icon: Icons.restaurant_outlined,
      color: Color(0xFFDC2626),
      skills: ['Servant heart', 'Physical stamina'],
    ),
    _OpportunityData(
      id: '10',
      title: 'Intercessory Prayer',
      ministry: 'Prayer',
      description:
          'Pray with members who come forward during altar calls. Training in compassionate prayer ministry provided.',
      commitment: '1 Sunday/month',
      schedule: 'Sundays during services',
      spotsLeft: 5,
      totalSpots: 10,
      icon: Icons.volunteer_activism_outlined,
      color: Color(0xFF0891B2),
      skills: ['Mature faith', 'Compassionate listener'],
    ),
  ];

  List<_OpportunityData> get _filtered {
    if (_selectedMinistry == 0) return _opportunities;
    final cat = _ministries[_selectedMinistry];
    return _opportunities.where((o) => o.ministry == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(title: 'Volunteer', showBack: true),
      body: Column(
        children: [
          // ── Stats banner ─────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
            padding: const EdgeInsets.all(AppSpacing.sp4),
            decoration: BoxDecoration(
              gradient: AppGradients.hero,
              borderRadius: AppRadius.borderRadiusLg,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('120+',
                          style: AppTextStyles.headingMedium
                              .copyWith(color: Colors.white)),
                      const SizedBox(height: 2),
                      Text('Active Volunteers',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                    width: 1,
                    height: 36,
                    color: Colors.white.withValues(alpha: 0.3)),
                Expanded(
                  child: Column(
                    children: [
                      Text('8',
                          style: AppTextStyles.headingMedium
                              .copyWith(color: Colors.white)),
                      const SizedBox(height: 2),
                      Text('Ministries',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                    width: 1,
                    height: 36,
                    color: Colors.white.withValues(alpha: 0.3)),
                Expanded(
                  child: Column(
                    children: [
                      Text('40',
                          style: AppTextStyles.headingMedium
                              .copyWith(color: Colors.white)),
                      const SizedBox(height: 2),
                      Text('Open Roles',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Ministry chips ───────────────────────────────────────────
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding),
              itemCount: _ministries.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSpacing.sp2),
              itemBuilder: (context, i) {
                final sel = _selectedMinistry == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMinistry = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sp4),
                    decoration: BoxDecoration(
                      color: sel
                          ? (isDark
                              ? AppColors.primaryLight
                              : AppColors.primary)
                          : (isDark
                              ? AppColors.cardDark
                              : AppColors.inputFill),
                      borderRadius: AppRadius.borderRadiusFull,
                      border: sel
                          ? null
                          : Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.inputBorder),
                    ),
                    child: Center(
                      child: Text(
                        _ministries[i],
                        style: AppTextStyles.labelSmall.copyWith(
                          color: sel
                              ? AppColors.textInverse
                              : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.sp3),

          // ── Opportunities list ───────────────────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: AppEmptyState(
                      icon: Icons.volunteer_activism_outlined,
                      title: 'No Openings',
                      subtitle: 'Check back later for new opportunities',
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontalPadding),
                    itemCount: _filtered.length,
                    itemBuilder: (context, i) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.cardGap),
                      child: _OpportunityCard(
                        data: _filtered[i],
                        isDark: isDark,
                        onSignUp: () =>
                            _showSignUpSheet(context, _filtered[i], isDark),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showSignUpSheet(
      BuildContext context, _OpportunityData opp, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: AppRadius.borderRadiusXlTop,
        ),
        child: Padding(
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
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: opp.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(opp.icon, color: opp.color, size: 28),
              ),
              const SizedBox(height: AppSpacing.sp4),
              Text(opp.title,
                  style: AppTextStyles.headingSmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.sp1),
              Text(opp.ministry,
                  style: AppTextStyles.bodyMedium.copyWith(color: opp.color)),
              const SizedBox(height: AppSpacing.sp4),
              Text(opp.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      height: 1.5),
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sp4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sp3),
                decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.bgDark : AppColors.warmWhite,
                    borderRadius: AppRadius.borderRadiusMd),
                child: Column(
                  children: [
                    _SheetInfoRow(
                        label: 'Commitment', value: opp.commitment, isDark: isDark),
                    const SizedBox(height: AppSpacing.sp2),
                    _SheetInfoRow(
                        label: 'Schedule', value: opp.schedule, isDark: isDark),
                    const SizedBox(height: AppSpacing.sp2),
                    _SheetInfoRow(
                        label: 'Spots Left',
                        value: '${opp.spotsLeft} of ${opp.totalSpots}',
                        isDark: isDark),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sp6),
              AppPrimaryButton(
                label: 'Sign Up to Volunteer',
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'Signed up for ${opp.title}! We will be in touch.'),
                    backgroundColor: AppColors.success,
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
      ),
    );
  }
}

// ── Data ─────────────────────────────────────────────────────────────────────

class _OpportunityData {
  const _OpportunityData({
    required this.id,
    required this.title,
    required this.ministry,
    required this.description,
    required this.commitment,
    required this.schedule,
    required this.spotsLeft,
    required this.totalSpots,
    required this.icon,
    required this.color,
    required this.skills,
  });

  final String id;
  final String title;
  final String ministry;
  final String description;
  final String commitment;
  final String schedule;
  final int spotsLeft;
  final int totalSpots;
  final IconData icon;
  final Color color;
  final List<String> skills;
}

// ── Widgets ─────────────────────────────────────────────────────────────────

class _OpportunityCard extends StatelessWidget {
  const _OpportunityCard({
    required this.data,
    required this.isDark,
    required this.onSignUp,
  });

  final _OpportunityData data;
  final bool isDark;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: onSignUp,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sp4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: AppRadius.borderRadiusLg,
          boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
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
                    color: data.color.withValues(alpha: 0.1),
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  child: Icon(data.icon, color: data.color, size: 22),
                ),
                const SizedBox(width: AppSpacing.sp3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.title,
                          style: AppTextStyles.bodyLargeSemiBold.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(data.ministry,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: data.color, fontSize: 11)),
                    ],
                  ),
                ),
                // Spots badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sp2, vertical: 3),
                  decoration: BoxDecoration(
                    color: data.spotsLeft <= 2
                        ? AppColors.error.withValues(alpha: 0.1)
                        : AppColors.success.withValues(alpha: 0.1),
                    borderRadius: AppRadius.borderRadiusFull,
                  ),
                  child: Text(
                    '${data.spotsLeft} spots',
                    style: AppTextStyles.labelSmall.copyWith(
                      color:
                          data.spotsLeft <= 2 ? AppColors.error : AppColors.success,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sp3),
            Text(data.description,
                style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppSpacing.sp3),
            // Skills chips
            Wrap(
              spacing: AppSpacing.sp2,
              runSpacing: AppSpacing.sp1,
              children: data.skills
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sp2, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.skyDark
                              : AppColors.inputFill,
                          borderRadius: AppRadius.borderRadiusFull,
                        ),
                        child: Text(s,
                            style: AppTextStyles.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textDisabled,
                                fontSize: 10)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.sp3),
            Row(
              children: [
                Icon(Icons.schedule_outlined,
                    size: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textDisabled),
                const SizedBox(width: 4),
                Text(data.commitment,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textDisabled,
                        fontSize: 11)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sp3, vertical: AppSpacing.sp1),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                    borderRadius: AppRadius.borderRadiusFull,
                  ),
                  child: Text('Sign Up',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: Colors.white, fontSize: 11)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetInfoRow extends StatelessWidget {
  const _SheetInfoRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textDisabled)),
        const Spacer(),
        Text(value,
            style: AppTextStyles.labelSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary)),
      ],
    );
  }
}
