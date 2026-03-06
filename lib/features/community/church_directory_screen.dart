import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// CHURCH DIRECTORY SCREEN
//
// Searchable member list (opt-in), alphabetical index, avatar + name +
// department, tap to view profile card (bottom sheet).
// ──────────────────────────────────────────────────────────────────────────────

class ChurchDirectoryScreen extends StatefulWidget {
  const ChurchDirectoryScreen({super.key});

  @override
  State<ChurchDirectoryScreen> createState() => _ChurchDirectoryScreenState();
}

class _ChurchDirectoryScreenState extends State<ChurchDirectoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static const _members = [
    _MemberData(
      name: 'Aaron Mitchell',
      department: 'Music Ministry',
      role: 'Worship Leader',
      joinedYear: '2019',
    ),
    _MemberData(
      name: 'Angela Roberts',
      department: 'Children Ministry',
      role: 'Volunteer',
      joinedYear: '2021',
    ),
    _MemberData(
      name: 'Benjamin Cole',
      department: 'Ushering',
      role: 'Head Usher',
      joinedYear: '2018',
    ),
    _MemberData(
      name: 'Caleb Johnson',
      department: 'Media',
      role: 'Sound Engineer',
      joinedYear: '2020',
    ),
    _MemberData(
      name: 'Daniel Okafor',
      department: 'Outreach',
      role: 'Team Lead',
      joinedYear: '2017',
    ),
    _MemberData(
      name: 'Elizabeth Grant',
      department: 'Music Ministry',
      role: 'Choir Member',
      joinedYear: '2022',
    ),
    _MemberData(
      name: 'Grace Williams',
      department: 'Prayer Team',
      role: 'Intercessor',
      joinedYear: '2016',
    ),
    _MemberData(
      name: 'James Patterson',
      department: 'Hospitality',
      role: 'Welcome Team',
      joinedYear: '2023',
    ),
    _MemberData(
      name: 'Marcus Johnson',
      department: "Men's Ministry",
      role: 'Group Leader',
      joinedYear: '2015',
    ),
    _MemberData(
      name: 'Rachel Adams',
      department: "Women's Ministry",
      role: 'Group Leader',
      joinedYear: '2018',
    ),
    _MemberData(
      name: 'Samuel Torres',
      department: 'Youth Ministry',
      role: 'Youth Pastor',
      joinedYear: '2019',
    ),
    _MemberData(
      name: 'Victoria Lee',
      department: 'Administration',
      role: 'Church Secretary',
      joinedYear: '2017',
    ),
  ];

  List<_MemberData> get _filteredMembers {
    if (_searchQuery.isEmpty) return _members;
    final q = _searchQuery.toLowerCase();
    return _members
        .where(
          (m) =>
              m.name.toLowerCase().contains(q) ||
              m.department.toLowerCase().contains(q) ||
              m.role.toLowerCase().contains(q),
        )
        .toList();
  }

  Map<String, List<_MemberData>> get _groupedMembers {
    final map = <String, List<_MemberData>>{};
    for (final m in _filteredMembers) {
      final letter = m.name[0].toUpperCase();
      map.putIfAbsent(letter, () => []).add(m);
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Church Directory',
        showBack: true,
      ),
      body: Column(
        children: [
          // ── Search bar ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(
              AppSpacing.screenHorizontalPadding,
            ),
            child: AppSearchBar(
              controller: _searchController,
              hint: 'Search members...',
              onChanged: (val) => setState(() => _searchQuery = val),
              onClear: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),
          ),

          // ── Member count ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontalPadding,
            ),
            child: Row(
              children: [
                Text(
                  '${_filteredMembers.length} members',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textDisabled,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.people_outline,
                  size: 16,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textDisabled,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sp2),

          // ── List ───────────────────────────────────────────────────────
          Expanded(
            child: _filteredMembers.isEmpty
                ? Center(
                    child: AppEmptyState(
                      icon: Icons.search_off,
                      title: 'No Members Found',
                      subtitle: 'Try a different search term',
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontalPadding,
                    ),
                    itemCount: _groupedMembers.length,
                    itemBuilder: (context, sectionIndex) {
                      final entry =
                          _groupedMembers.entries.elementAt(sectionIndex);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section header
                          Padding(
                            padding: const EdgeInsets.only(
                              top: AppSpacing.sp3,
                              bottom: AppSpacing.sp2,
                            ),
                            child: Text(
                              entry.key,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: isDark
                                    ? AppColors.primaryLight
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                          // Members in section
                          ...entry.value.map((m) => _MemberTile(
                                member: m,
                                isDark: isDark,
                                onTap: () =>
                                    _showMemberProfile(context, m, isDark),
                              )),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showMemberProfile(
    BuildContext context,
    _MemberData member,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MemberProfileCard(
        name: member.name,
        department: member.department,
        role: member.role,
        joinedYear: member.joinedYear,
        isDark: isDark,
      ),
    );
  }
}

// ── Data ─────────────────────────────────────────────────────────────────────

class _MemberData {
  const _MemberData({
    required this.name,
    required this.department,
    required this.role,
    required this.joinedYear,
  });

  final String name;
  final String department;
  final String role;
  final String joinedYear;
}

// ── Widgets ─────────────────────────────────────────────────────────────────

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.isDark,
    required this.onTap,
  });

  final _MemberData member;
  final bool isDark;
  final VoidCallback onTap;

  Color get _departmentColor {
    switch (member.department) {
      case 'Music Ministry':
        return const Color(0xFF7C3AED);
      case 'Children Ministry':
        return const Color(0xFFEC4899);
      case 'Youth Ministry':
        return const Color(0xFFEA580C);
      case 'Prayer Team':
        return const Color(0xFF0891B2);
      case 'Outreach':
        return const Color(0xFF059669);
      case 'Media':
        return const Color(0xFF2563EB);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sp2),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sp3),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.surface,
            borderRadius: AppRadius.borderRadiusMd,
            boxShadow: isDark ? AppShadows.xsDark : AppShadows.xs,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    _departmentColor.withValues(alpha: 0.12),
                child: Text(
                  member.name.split(' ').map((n) => n[0]).join(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: _departmentColor,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sp3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${member.department}  •  ${member.role}',
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
              Icon(
                Icons.chevron_right,
                size: 20,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.inactive,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// MEMBER PROFILE CARD (Bottom Sheet)
//
// Shows someone's public profile: avatar, name, department,
// "Pray for them" button, joined date.
// ──────────────────────────────────────────────────────────────────────────────

class MemberProfileCard extends StatelessWidget {
  const MemberProfileCard({
    super.key,
    required this.name,
    required this.department,
    required this.role,
    required this.joinedYear,
    required this.isDark,
  });

  final String name;
  final String department;
  final String role;
  final String joinedYear;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surface,
        borderRadius: AppRadius.borderRadiusXlTop,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: AppSpacing.sp3),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.inactive,
              borderRadius: AppRadius.borderRadiusFull,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.sp6),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 44,
                  backgroundColor: isDark
                      ? AppColors.primaryLight
                      : AppColors.skyLight,
                  child: Text(
                    name.split(' ').map((n) => n[0]).join(),
                    style: AppTextStyles.headingLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.sp4),

                // Name
                Text(
                  name,
                  style: AppTextStyles.headingMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: AppSpacing.sp1),

                // Role & department
                Text(
                  '$role  •  $department',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: AppSpacing.sp2),

                // Joined
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sp3,
                    vertical: AppSpacing.sp1,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.skyDark
                        : AppColors.skyLight,
                    borderRadius: AppRadius.borderRadiusFull,
                  ),
                  child: Text(
                    'Member since $joinedYear',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.primary,
                      fontSize: 11,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.sp6),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: AppPrimaryButton(
                        label: 'Pray for Them',
                        onPressed: () {},
                        icon: const Icon(Icons.volunteer_activism_outlined, color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sp3),
                    Expanded(
                      child: AppSecondaryButton(
                        label: 'Send Message',
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sp4),

                // Info tiles
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sp4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.bgDark
                        : AppColors.warmWhite,
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  child: Column(
                    children: [
                      _ProfileInfoRow(
                        icon: Icons.groups_outlined,
                        label: 'Connect Group',
                        value: "Men's Fellowship",
                        isDark: isDark,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sp2,
                        ),
                        child: Container(
                          height: 0.5,
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.divider,
                        ),
                      ),
                      _ProfileInfoRow(
                        icon: Icons.church_outlined,
                        label: 'Campus',
                        value: 'Main Campus',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                // Safety spacer
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom +
                      AppSpacing.sp4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
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
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color:
              isDark ? AppColors.textSecondaryDark : AppColors.textDisabled,
        ),
        const SizedBox(width: AppSpacing.sp3),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textDisabled,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.labelSmall.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
