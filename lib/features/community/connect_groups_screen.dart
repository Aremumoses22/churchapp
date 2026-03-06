import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/community.dart';
import '../../core/providers/community_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// CONNECT GROUPS SCREEN
//
// Browse small groups by category (Men, Women, Youth, Couples, Bible Study),
// group cards with member count + meeting schedule, "Join Group" button.
// ──────────────────────────────────────────────────────────────────────────────

class ConnectGroupsScreen extends ConsumerStatefulWidget {
  const ConnectGroupsScreen({super.key});

  @override
  ConsumerState<ConnectGroupsScreen> createState() => _ConnectGroupsScreenState();
}

class _ConnectGroupsScreenState extends ConsumerState<ConnectGroupsScreen> {

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cState = ref.watch(communityNotifierProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Connect Groups',
        showBack: true,
      ),
      body: Column(
        children: [
          // ── Category chips ───────────────────────────────────────────────
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontalPadding,
                vertical: AppSpacing.sp2,
              ),
              itemCount: cState.categories.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSpacing.sp2),
              itemBuilder: (context, index) {
                final isSelected = cState.selectedCategory == index;
                return GestureDetector(
                  onTap: () => ref.read(communityNotifierProvider.notifier).selectCategory(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sp4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                              ? AppColors.primaryLight
                              : AppColors.primary)
                          : (isDark
                              ? AppColors.cardDark
                              : AppColors.inputFill),
                      borderRadius: AppRadius.borderRadiusFull,
                      border: isSelected
                          ? null
                          : Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.inputBorder,
                              width: 1,
                            ),
                    ),
                    child: Center(
                      child: Text(
                        cState.categories[index],
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isSelected
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

          const SizedBox(height: AppSpacing.sp2),

          // ── Groups list ──────────────────────────────────────────────────
          Expanded(
            child: cState.filteredGroups.isEmpty
                ? Center(
                    child: AppEmptyState(
                      icon: Icons.group_outlined,
                      title: 'No Groups Found',
                      subtitle:
                          'No groups in this category yet',
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontalPadding,
                    ),
                    itemCount: cState.filteredGroups.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppSpacing.cardGap),
                        child: _GroupCard(
                          group: cState.filteredGroups[index],
                          isDark: isDark,
                          onTap: () {
                            // TODO: navigate to group detail
                          },
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

// ── Widgets ─────────────────────────────────────────────────────────────────

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.isDark,
    required this.onTap,
  });

  final ConnectGroup group;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: onTap,
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
                // Group icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: group.color.withValues(alpha: 0.1),
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.people_outline,
                      color: group.color,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sp3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              group.name,
                              style:
                                  AppTextStyles.bodyLargeSemiBold.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!group.isOpen)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sp2,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: AppRadius.borderRadiusXs,
                              ),
                              child: Text(
                                'FULL',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.error,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Led by ${group.leader}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sp3),

            // Description
            Text(
              group.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: AppSpacing.sp3),

            // Info row
            Row(
              children: [
                _InfoChip(
                  icon: Icons.calendar_today_outlined,
                  label: '${group.meetingDay} ${group.meetingTime}',
                  isDark: isDark,
                ),
                const SizedBox(width: AppSpacing.sp3),
                _InfoChip(
                  icon: Icons.location_on_outlined,
                  label: group.location,
                  isDark: isDark,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sp3),

            // Footer: member count + join button
            Row(
              children: [
                // Member avatars stack
                SizedBox(
                  width: 60,
                  height: 28,
                  child: Stack(
                    children: List.generate(
                      3,
                      (i) => Positioned(
                        left: i * 18.0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: group.color
                                .withValues(alpha: 0.7 - i * 0.2),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.cardDark
                                  : AppColors.surface,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sp2),
                Text(
                  '${group.memberCount}/${group.maxMembers} members',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textDisabled,
                  ),
                ),
                const Spacer(),
                // Join button
                AppTapAnimation(
                  onTap: group.isOpen ? () {} : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sp4,
                      vertical: AppSpacing.sp2,
                    ),
                    decoration: BoxDecoration(
                      color: group.isOpen
                          ? (isDark
                              ? AppColors.primaryLight
                              : AppColors.primary)
                          : (isDark
                              ? AppColors.borderDark
                              : AppColors.inactive),
                      borderRadius: AppRadius.borderRadiusFull,
                    ),
                    child: Text(
                      group.isOpen ? 'Join Group' : 'Waitlist',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: group.isOpen
                            ? AppColors.textInverse
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary),
                      ),
                    ),
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textDisabled,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textDisabled,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
