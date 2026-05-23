import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/community.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// GROUP DETAIL SCREEN
// ──────────────────────────────────────────────────────────────────────────────

class GroupDetailScreen extends ConsumerStatefulWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  bool? _isMember; // null = not yet initialized from API
  bool _isLoading = false;

  Future<void> _toggleMembership(GroupDetail group) async {
    if (_isLoading) return;
    final repo = ref.read(communityRepositoryProvider);
    setState(() => _isLoading = true);
    try {
      final joining = !(_isMember ?? group.isMember);
      if (joining) {
        await repo.joinGroup(widget.groupId);
      } else {
        await repo.leaveGroup(widget.groupId);
      }
      setState(() => _isMember = joining);
      ref.invalidate(groupDetailProvider(widget.groupId));
    } catch (_) {
      // silently ignore; the button will revert
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final groupAsync = ref.watch(groupDetailProvider(widget.groupId));

    return groupAsync.when(
      loading: () => Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
        appBar: AppFilledAppBar(title: 'Group', showBack: true),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
        appBar: AppFilledAppBar(title: 'Group', showBack: true),
        body: Center(
          child: AppEmptyState(
            icon: Icons.group_outlined,
            title: 'Group Not Found',
            subtitle: 'This group could not be loaded.',
          ),
        ),
      ),
      data: (group) {
        if (group == null) {
          return Scaffold(
            backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
            appBar: AppFilledAppBar(title: 'Group', showBack: true),
            body: Center(
              child: AppEmptyState(
                icon: Icons.group_outlined,
                title: 'Group Not Found',
                subtitle: 'This group could not be loaded.',
              ),
            ),
          );
        }

        final isMember = _isMember ?? group.isMember;

        return Scaffold(
          backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
          body: CustomScrollView(
            slivers: [
              // ── Hero Header ───────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: group.color,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [group.color, group.color.withValues(alpha: 0.7)],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenHorizontalPadding,
                          60,
                          AppSpacing.screenHorizontalPadding,
                          AppSpacing.sp4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sp3,
                                vertical: AppSpacing.sp1,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: AppRadius.borderRadiusFull,
                              ),
                              child: Text(
                                group.category.toUpperCase().replaceAll('_', ' '),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sp2),
                            Text(
                              group.name,
                              style: AppTextStyles.headingLarge
                                  .copyWith(color: Colors.white),
                            ),
                            if (group.leader.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.sp1),
                              Text(
                                'Led by ${group.leader}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Body ─────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Quick info tiles ─────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _QuickInfoTile(
                              icon: Icons.calendar_today_outlined,
                              label: 'Meets',
                              value: '${group.meetingDay} ${group.meetingTime}',
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.cardGap),
                          Expanded(
                            child: _QuickInfoTile(
                              icon: Icons.location_on_outlined,
                              label: 'Location',
                              value: group.location.isNotEmpty
                                  ? group.location
                                  : 'TBD',
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.cardGap),
                          Expanded(
                            child: _QuickInfoTile(
                              icon: Icons.people_outline,
                              label: 'Members',
                              value: '${group.memberCount} / ${group.maxMembers}',
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.sp6),

                      // ── About ─────────────────────────────────────────────
                      if (group.description.isNotEmpty) ...[
                        Text(
                          'About',
                          style: AppTextStyles.headingSmall.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sp2),
                        Text(
                          group.description,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sp6),
                      ],

                      // ── Join / Leave button ────────────────────────────────
                      if (group.isOpen || isMember)
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : isMember
                                ? AppSecondaryButton(
                                    label: 'Leave Group',
                                    onPressed: () => _toggleMembership(group),
                                    isFullWidth: true,
                                  )
                                : AppPrimaryButton(
                                    label: 'Join This Group',
                                    onPressed: () => _toggleMembership(group),
                                    isFullWidth: true,
                                    icon: const Icon(
                                      Icons.group_add_outlined,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),

                      const SizedBox(height: AppSpacing.sp6),

                      // ── Members ───────────────────────────────────────────
                      if (group.members.isNotEmpty) ...[
                        AppSectionHeader(
                          title: 'Members (${group.memberCount})',
                          actionLabel: 'See All',
                          onAction: () {},
                        ),
                        const SizedBox(height: AppSpacing.sp3),
                        SizedBox(
                          height: 80,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: group.members.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: AppSpacing.sp3),
                            itemBuilder: (context, index) {
                              final member = group.members[index];
                              final initial = member.name.isNotEmpty
                                  ? member.name[0].toUpperCase()
                                  : '?';
                              return _MemberChip(
                                name: member.name,
                                initial: initial,
                                isDark: isDark,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sp6),
                      ],

                      const SizedBox(height: AppSpacing.sp12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────────────────────

class _QuickInfoTile extends StatelessWidget {
  const _QuickInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surface,
        borderRadius: AppRadius.borderRadiusMd,
        boxShadow: isDark ? AppShadows.xsDark : AppShadows.xs,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.textSecondaryDark : AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.sp1),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textDisabled,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.labelSmall.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MemberChip extends StatelessWidget {
  const _MemberChip({
    required this.name,
    required this.initial,
    required this.isDark,
  });

  final String name;
  final String initial;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: isDark ? AppColors.primaryLight : AppColors.skyLight,
          child: Text(
            initial,
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
          ),
        ),
        const SizedBox(height: AppSpacing.sp1),
        Text(
          name,
          style: AppTextStyles.bodySmall.copyWith(
            color:
                isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
