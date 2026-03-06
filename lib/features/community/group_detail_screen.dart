import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// GROUP DETAIL SCREEN
//
// Detailed view of a connect group: info header, members list with avatars,
// meeting location/time, group chat preview, resources/materials.
// ──────────────────────────────────────────────────────────────────────────────

class GroupDetailScreen extends StatelessWidget {
  const GroupDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      body: CustomScrollView(
        slivers: [
          // ── Hero Header ────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF1E40AF),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon:
                    const Icon(Icons.share_outlined, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
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
                            "MEN'S GROUP",
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sp2),
                        Text(
                          "Men's Fellowship",
                          style: AppTextStyles.headingLarge
                              .copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: AppSpacing.sp1),
                        Text(
                          'Led by Marcus Johnson',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Body ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(
                AppSpacing.screenHorizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Quick info cards ────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _QuickInfoTile(
                          icon: Icons.calendar_today_outlined,
                          label: 'Meets',
                          value: 'Saturdays 8 AM',
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.cardGap),
                      Expanded(
                        child: _QuickInfoTile(
                          icon: Icons.location_on_outlined,
                          label: 'Location',
                          value: 'Room 201',
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.cardGap),
                      Expanded(
                        child: _QuickInfoTile(
                          icon: Icons.people_outline,
                          label: 'Members',
                          value: '24 / 30',
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sp6),

                  // ── About ──────────────────────────────────────────────
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
                    'A brotherhood of men pursuing faith, accountability, and purpose together. We meet weekly for Bible study, prayer, and honest conversation about the challenges of life and faith.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sp6),

                  // ── Join button ────────────────────────────────────────
                  AppPrimaryButton(
                    label: 'Join This Group',
                    onPressed: () {},
                    isFullWidth: true,
                    icon: const Icon(Icons.group_add_outlined, color: Colors.white, size: 18),
                  ),

                  const SizedBox(height: AppSpacing.sp6),

                  // ── Members ────────────────────────────────────────────
                  AppSectionHeader(
                    title: 'Members (24)',
                    actionLabel: 'See All',
                    onAction: () {},
                  ),
                  const SizedBox(height: AppSpacing.sp3),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _memberNames.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppSpacing.sp3),
                      itemBuilder: (context, index) {
                        return _MemberChip(
                          name: _memberNames[index],
                          initial: _memberNames[index][0],
                          isDark: isDark,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sp6),

                  // ── Upcoming Meetings ─────────────────────────────────
                  AppSectionHeader(
                    title: 'Upcoming Meetings',
                    actionLabel: 'Calendar',
                    onAction: () {},
                  ),
                  const SizedBox(height: AppSpacing.sp3),
                  _MeetingCard(
                    title: 'Weekly Fellowship',
                    date: 'This Saturday, Dec 28',
                    time: '8:00 - 9:30 AM',
                    topic: 'Chapter 5: Walking in Purpose',
                    isDark: isDark,
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                  _MeetingCard(
                    title: 'Weekly Fellowship',
                    date: 'Saturday, Jan 4',
                    time: '8:00 - 9:30 AM',
                    topic: 'Chapter 6: Armor of God',
                    isDark: isDark,
                  ),

                  const SizedBox(height: AppSpacing.sp6),

                  // ── Resources ─────────────────────────────────────────
                  AppSectionHeader(
                    title: 'Resources',
                    actionLabel: 'View All',
                    onAction: () {},
                  ),
                  const SizedBox(height: AppSpacing.sp3),
                  _ResourceItem(
                    icon: Icons.menu_book_outlined,
                    title: 'Study Guide Week 12',
                    subtitle: 'PDF  •  2.4 MB',
                    isDark: isDark,
                  ),
                  _ResourceItem(
                    icon: Icons.play_circle_outline,
                    title: 'Session Recording - Week 11',
                    subtitle: 'Video  •  45 min',
                    isDark: isDark,
                  ),
                  _ResourceItem(
                    icon: Icons.note_outlined,
                    title: 'Prayer Journal Template',
                    subtitle: 'PDF  •  1.1 MB',
                    isDark: isDark,
                  ),

                  const SizedBox(height: AppSpacing.sp6),

                  // ── Recent Discussion ─────────────────────────────────
                  AppSectionHeader(
                    title: 'Recent Discussion',
                    actionLabel: 'Open Chat',
                    onAction: () {},
                  ),
                  const SizedBox(height: AppSpacing.sp3),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sp4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cardDark
                          : AppColors.surface,
                      borderRadius: AppRadius.borderRadiusLg,
                      boxShadow:
                          isDark ? AppShadows.xsDark : AppShadows.xs,
                    ),
                    child: Column(
                      children: [
                        _ChatBubble(
                          name: 'Marcus',
                          message:
                              'Great session today! Remember to read chapters 5-6 before next week.',
                          time: '2h ago',
                          isDark: isDark,
                        ),
                        const SizedBox(height: AppSpacing.sp3),
                        _ChatBubble(
                          name: 'James',
                          message:
                              'Thanks Marcus! Really appreciated the discussion on purpose.',
                          time: '1h ago',
                          isDark: isDark,
                        ),
                        const SizedBox(height: AppSpacing.sp3),
                        _ChatBubble(
                          name: 'Daniel',
                          message: 'See everyone Saturday! Bringing snacks',
                          time: '45m ago',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sp12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _memberNames = [
    'Marcus',
    'James',
    'Daniel',
    'Samuel',
    'Elijah',
    'Noah',
    'Caleb',
    'Aaron',
  ];
}

// ── Widgets ─────────────────────────────────────────────────────────────────

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
            color:
                isDark ? AppColors.textSecondaryDark : AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.sp1),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textDisabled,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.labelSmall.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimary,
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
          backgroundColor:
              isDark ? AppColors.primaryLight : AppColors.skyLight,
          child: Text(
            initial,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sp1),
        Text(
          name,
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _MeetingCard extends StatelessWidget {
  const _MeetingCard({
    required this.title,
    required this.date,
    required this.time,
    required this.topic,
    required this.isDark,
  });

  final String title;
  final String date;
  final String time;
  final String topic;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surface,
        borderRadius: AppRadius.borderRadiusMd,
        boxShadow: isDark ? AppShadows.xsDark : AppShadows.xs,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? AppColors.skyDark : AppColors.skyLight,
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Center(
              child: Icon(
                Icons.event_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sp3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$time  •  $topic',
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
    );
  }
}

class _ResourceItem extends StatelessWidget {
  const _ResourceItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sp2),
      child: AppTapAnimation(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sp3),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.surface,
            borderRadius: AppRadius.borderRadiusSm,
            border: Border.all(
              color: isDark
                  ? AppColors.borderDark
                  : AppColors.inputBorder,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sp3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textDisabled,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.download_outlined,
                size: 18,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textDisabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.name,
    required this.message,
    required this.time,
    required this.isDark,
  });

  final String name;
  final String message;
  final String time;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor:
              isDark ? AppColors.primaryLight : AppColors.skyLight,
          child: Text(
            name[0],
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sp2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sp2),
                  Text(
                    time,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textDisabled,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                message,
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
    );
  }
}
