import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/church_info.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// PASTORS & LEADERSHIP SCREEN
// ──────────────────────────────────────────────────────────────────────────────

class PastorsScreen extends ConsumerWidget {
  const PastorsScreen({super.key});

  static const _kColors = [
    Color(0xFF1E40AF),
    Color(0xFF7C3AED),
    Color(0xFFEA580C),
    Color(0xFF0891B2),
    Color(0xFF059669),
    Color(0xFFDC2626),
  ];

  static const _staticLeaders = [
    _LeaderData(name: 'Pastor James Wilson', title: 'Senior Pastor', bio: 'Pastor James has served as Senior Pastor for over 15 years. His passion is teaching the Word of God with clarity and helping people discover their God-given purpose.', initial: 'JW', color: Color(0xFF1E40AF)),
    _LeaderData(name: 'Pastor Rachel Adams', title: 'Associate Pastor', bio: 'Pastor Rachel oversees discipleship and pastoral care. She has a heart for building authentic community and mentoring the next generation.', initial: 'RA', color: Color(0xFF7C3AED)),
    _LeaderData(name: 'Pastor Samuel Torres', title: 'Youth Pastor', bio: 'Pastor Sam is passionate about reaching young people with the Gospel. He leads our vibrant youth ministry with energy and purpose.', initial: 'ST', color: Color(0xFFEA580C)),
    _LeaderData(name: 'Pastor Grace Okafor', title: 'Worship Pastor', bio: 'Pastor Grace leads our worship ministry with a deep desire to create spaces where people encounter God through music and praise.', initial: 'GO', color: Color(0xFF0891B2)),
    _LeaderData(name: 'Pastor David Kim', title: 'Outreach Pastor', bio: 'Pastor David coordinates our local and global missions. He believes the church exists to be the hands and feet of Jesus in the world.', initial: 'DK', color: Color(0xFF059669)),
  ];

  static const _staticMinistryLeaders = [
    _MinistryLeaderData(name: 'Marcus Johnson', ministry: "Men's Ministry", initial: 'MJ'),
    _MinistryLeaderData(name: 'Angela Roberts', ministry: "Children's Ministry", initial: 'AR'),
    _MinistryLeaderData(name: 'Tom Bradley', ministry: 'Community Outreach', initial: 'TB'),
    _MinistryLeaderData(name: 'Victoria Lee', ministry: 'Administration', initial: 'VL'),
    _MinistryLeaderData(name: 'Caleb Johnson', ministry: 'Media & Tech', initial: 'CJ'),
  ];

  static String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '??';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  List<_LeaderData> _fromApi(List<StaffMember> staff) {
    return staff.asMap().entries.map((e) {
      final s = e.value;
      return _LeaderData(
        name: s.name,
        title: s.title,
        bio: s.bio ?? '',
        initial: _initials(s.name),
        color: _kColors[e.key % _kColors.length],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final staffAsync = ref.watch(churchStaffProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(title: 'Pastors & Leadership', showBack: true),
      body: staffAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _buildContent(_staticLeaders, _staticMinistryLeaders, isDark),
        data: (staff) {
          final leaders = staff.isEmpty ? _staticLeaders : _fromApi(staff);
          return _buildContent(leaders, staff.isEmpty ? _staticMinistryLeaders : const [], isDark);
        },
      ),
    );
  }

  Widget _buildContent(
    List<_LeaderData> leaders,
    List<_MinistryLeaderData> ministryLeaders,
    bool isDark,
  ) {
    if (leaders.isEmpty) {
      return Center(
        child: AppEmptyState(
          icon: Icons.people_outline,
          title: 'No Leaders Found',
          subtitle: 'Leadership information is not available right now.',
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.sp4),

          _FeaturedLeaderCard(leader: leaders[0], isDark: isDark),

          if (leaders.length > 1) ...[
            const SizedBox(height: AppSpacing.sp6),
            Text(
              'Pastoral Team',
              style: AppTextStyles.headingSmall.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sp4),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                mainAxisSpacing: AppSpacing.cardGap,
                crossAxisSpacing: AppSpacing.cardGap,
              ),
              itemCount: leaders.length - 1,
              itemBuilder: (context, index) => _LeaderCard(leader: leaders[index + 1], isDark: isDark),
            ),
          ],

          if (ministryLeaders.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sp8),
            Text(
              'Ministry Leaders',
              style: AppTextStyles.headingSmall.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sp4),
            ...ministryLeaders.map(
              (l) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sp2),
                child: _MinistryLeaderTile(leader: l, isDark: isDark),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.sp12),
        ],
      ),
    );
  }
}

// ── Data ─────────────────────────────────────────────────────────────────────

class _LeaderData {
  const _LeaderData({
    required this.name,
    required this.title,
    required this.bio,
    required this.initial,
    required this.color,
  });

  final String name;
  final String title;
  final String bio;
  final String initial;
  final Color color;
}

class _MinistryLeaderData {
  const _MinistryLeaderData({
    required this.name,
    required this.ministry,
    required this.initial,
  });

  final String name;
  final String ministry;
  final String initial;
}

// ── Widgets ─────────────────────────────────────────────────────────────────

class _FeaturedLeaderCard extends StatelessWidget {
  const _FeaturedLeaderCard({required this.leader, required this.isDark});

  final _LeaderData leader;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sp6),
      decoration: BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: AppRadius.borderRadiusXl,
        boxShadow: isDark ? AppShadows.mdDark : AppShadows.md,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(leader.initial, style: AppTextStyles.headingLarge.copyWith(color: Colors.white)),
          ),
          const SizedBox(height: AppSpacing.sp4),
          Text(leader.name, style: AppTextStyles.headingMedium.copyWith(color: Colors.white), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sp1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp3, vertical: AppSpacing.sp1),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: AppRadius.borderRadiusFull),
            child: Text(leader.title, style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.9))),
          ),
          if (leader.bio.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sp4),
            Text(
              leader.bio,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.85), height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _LeaderCard extends StatefulWidget {
  const _LeaderCard({required this.leader, required this.isDark});

  final _LeaderData leader;
  final bool isDark;

  @override
  State<_LeaderCard> createState() => _LeaderCardState();
}

class _LeaderCardState extends State<_LeaderCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sp4),
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: AppRadius.borderRadiusLg,
          boxShadow: widget.isDark ? AppShadows.smDark : AppShadows.sm,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: widget.leader.color.withValues(alpha: 0.12),
              child: Text(widget.leader.initial, style: AppTextStyles.headingSmall.copyWith(color: widget.leader.color)),
            ),
            const SizedBox(height: AppSpacing.sp3),
            Text(
              widget.leader.name,
              style: AppTextStyles.labelSmall.copyWith(color: widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              widget.leader.title,
              style: AppTextStyles.bodySmall.copyWith(color: widget.leader.color, fontSize: 11),
              textAlign: TextAlign.center,
            ),
            if (_expanded && widget.leader.bio.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sp2),
              Text(
                widget.leader.bio,
                style: AppTextStyles.bodySmall.copyWith(
                  color: widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  fontSize: 10,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MinistryLeaderTile extends StatelessWidget {
  const _MinistryLeaderTile({required this.leader, required this.isDark});

  final _MinistryLeaderData leader;
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isDark ? AppColors.skyDark : AppColors.skyLight,
            child: Text(leader.initial, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
          ),
          const SizedBox(width: AppSpacing.sp3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(leader.name, style: AppTextStyles.labelSmall.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                Text(
                  leader.ministry,
                  style: AppTextStyles.bodySmall.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 20, color: isDark ? AppColors.textSecondaryDark : AppColors.inactive),
        ],
      ),
    );
  }
}
