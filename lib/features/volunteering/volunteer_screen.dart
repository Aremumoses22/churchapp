import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/volunteer.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// VOLUNTEER SCREEN
//
// Browse volunteer opportunities from GET /volunteer/opportunities.
// Sign up via POST /volunteer/opportunities/:id/signup.
// ──────────────────────────────────────────────────────────────────────────────

class VolunteerScreen extends ConsumerStatefulWidget {
  const VolunteerScreen({super.key});

  @override
  ConsumerState<VolunteerScreen> createState() => _VolunteerScreenState();
}

class _VolunteerScreenState extends ConsumerState<VolunteerScreen> {
  String? _ministryFilter;

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final opportunities = ref.watch(volunteerOpportunitiesProvider);

    // Collect distinct ministries from loaded data
    final ministrySet = <String>{
      for (final o in opportunities)
        if (o.ministry.isNotEmpty) o.ministry,
    };
    final ministries = ['All', ...ministrySet.toList()..sort()];

    final filtered = _ministryFilter == null
        ? opportunities
        : opportunities
            .where((o) => o.ministry == _ministryFilter)
            .toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(title: 'Volunteer', showBack: true),
      body: Column(
        children: [
          // Stats banner
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
                    value: '${opportunities.length}',
                    label: 'Open Roles'),
                Container(
                    width: 1,
                    height: 36,
                    color: Colors.white.withValues(alpha: 0.3)),
                _StatPill(
                    value: '${ministries.length - 1}',
                    label: 'Ministries'),
                Container(
                    width: 1,
                    height: 36,
                    color: Colors.white.withValues(alpha: 0.3)),
                _StatPill(
                    value: '${opportunities.where((o) => !(o.isSignedUp)).length}',
                    label: 'Available'),
              ],
            ),
          ),

          // Ministry chips
          if (ministries.length > 1)
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontalPadding),
                itemCount: ministries.length,
                separatorBuilder: (_, i) =>
                    const SizedBox(width: AppSpacing.sp2),
                itemBuilder: (context, i) {
                  final ministry = ministries[i];
                  final isAll = ministry == 'All';
                  final sel = isAll
                      ? _ministryFilter == null
                      : _ministryFilter == ministry;
                  return GestureDetector(
                    onTap: () => setState(() =>
                        _ministryFilter = isAll ? null : ministry),
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
                          ministry,
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

          // Opportunities list
          Expanded(
            child: opportunities.isEmpty
                ? const AppEmptyState(
                    icon: Icons.volunteer_activism_outlined,
                    title: 'No Openings',
                    subtitle: 'Check back later for new opportunities',
                  )
                : filtered.isEmpty
                    ? const AppEmptyState(
                        icon: Icons.search_off,
                        title: 'No openings in this ministry',
                        subtitle: 'Try another ministry filter',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal:
                                AppSpacing.screenHorizontalPadding),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) => Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppSpacing.cardGap),
                          child: _OpportunityCard(
                            opp: filtered[i],
                            isDark: isDark,
                            icon: _iconForMinistry(filtered[i].ministry),
                            color:
                                _colorForMinistry(filtered[i].ministry),
                            onSignUp: () => _showSignUpSheet(
                                context, filtered[i], isDark),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showSignUpSheet(
      BuildContext ctx, VolunteerOpportunity opp, bool isDark) {
    final color = _colorForMinistry(opp.ministry);
    final icon = _iconForMinistry(opp.ministry);

    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: AppRadius.borderRadiusXlTop,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              AppSpacing.sp6,
              AppSpacing.sp3,
              AppSpacing.sp6,
              MediaQuery.of(sheetCtx).padding.bottom + AppSpacing.sp6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.inactive,
                    borderRadius: AppRadius.borderRadiusFull),
              ),
              const SizedBox(height: AppSpacing.sp5),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: AppSpacing.sp4),
              Text(opp.title,
                  style: AppTextStyles.headingSmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.sp1),
              Text(opp.ministry,
                  style: AppTextStyles.bodyMedium.copyWith(color: color)),
              if (opp.description != null) ...[
                const SizedBox(height: AppSpacing.sp4),
                Text(opp.description!,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        height: 1.5),
                    textAlign: TextAlign.center),
              ],
              const SizedBox(height: AppSpacing.sp4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sp3),
                decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.bgDark
                        : AppColors.warmWhite,
                    borderRadius: AppRadius.borderRadiusMd),
                child: Column(
                  children: [
                    if (opp.commitment != null)
                      _SheetRow(
                          label: 'Commitment',
                          value: opp.commitment!,
                          isDark: isDark),
                    if (opp.schedule != null) ...[
                      const SizedBox(height: AppSpacing.sp2),
                      _SheetRow(
                          label: 'Schedule',
                          value: opp.schedule!,
                          isDark: isDark),
                    ],
                    if (opp.spotsLeft != null) ...[
                      const SizedBox(height: AppSpacing.sp2),
                      _SheetRow(
                          label: 'Spots Left',
                          value: opp.totalSpots != null
                              ? '${opp.spotsLeft} of ${opp.totalSpots}'
                              : '${opp.spotsLeft}',
                          isDark: isDark),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sp6),
              if (opp.isSignedUp)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sp3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.success, size: 18),
                      const SizedBox(width: 8),
                      Text('Already Signed Up',
                          style: AppTextStyles.labelMedium
                              .copyWith(color: AppColors.success)),
                    ],
                  ),
                )
              else
                AppPrimaryButton(
                  label: 'Sign Up to Volunteer',
                  onPressed: () async {
                    Navigator.of(sheetCtx).pop();
                    final ok = await ref
                        .read(volunteerOpportunitiesProvider.notifier)
                        .signUp(opp.id);
                    if (!ctx.mounted) return;
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text(ok
                          ? 'Signed up for ${opp.title}!'
                          : 'Sign-up failed. Please try again.'),
                      backgroundColor:
                          ok ? AppColors.success : AppColors.error,
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
                  onPressed: () => Navigator.of(sheetCtx).pop()),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

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

class _OpportunityCard extends StatelessWidget {
  const _OpportunityCard({
    required this.opp,
    required this.isDark,
    required this.icon,
    required this.color,
    required this.onSignUp,
  });

  final VolunteerOpportunity opp;
  final bool isDark;
  final IconData icon;
  final Color color;
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
                      Text(opp.title,
                          style: AppTextStyles.bodyLargeSemiBold.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(opp.ministry,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: color, fontSize: 11)),
                    ],
                  ),
                ),
                if (opp.spotsLeft != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sp2, vertical: 3),
                    decoration: BoxDecoration(
                      color: (opp.spotsLeft! <= 2)
                          ? AppColors.error.withValues(alpha: 0.1)
                          : AppColors.success.withValues(alpha: 0.1),
                      borderRadius: AppRadius.borderRadiusFull,
                    ),
                    child: Text(
                      '${opp.spotsLeft} spots',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: (opp.spotsLeft! <= 2)
                            ? AppColors.error
                            : AppColors.success,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
            if (opp.description != null) ...[
              const SizedBox(height: AppSpacing.sp3),
              Text(opp.description!,
                  style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
            if (opp.skills.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sp3),
              Wrap(
                spacing: AppSpacing.sp2,
                runSpacing: AppSpacing.sp1,
                children: opp.skills
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
            ],
            const SizedBox(height: AppSpacing.sp3),
            Row(
              children: [
                if (opp.commitment != null) ...[
                  Icon(Icons.schedule_outlined,
                      size: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textDisabled),
                  const SizedBox(width: 4),
                  Text(opp.commitment!,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textDisabled,
                          fontSize: 11)),
                ],
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sp3, vertical: AppSpacing.sp1),
                  decoration: BoxDecoration(
                    color: opp.isSignedUp
                        ? AppColors.success
                        : (isDark
                            ? AppColors.primaryLight
                            : AppColors.primary),
                    borderRadius: AppRadius.borderRadiusFull,
                  ),
                  child: Text(
                    opp.isSignedUp ? 'Signed Up' : 'Sign Up',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow(
      {required this.label, required this.value, required this.isDark});
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
