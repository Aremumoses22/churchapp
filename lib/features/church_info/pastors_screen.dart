import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// PASTORS & LEADERSHIP SCREEN
//
// Grid of leader cards (photo, name, title, bio), tap to expand bio.
// ──────────────────────────────────────────────────────────────────────────────

class PastorsScreen extends StatelessWidget {
  const PastorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Pastors & Leadership',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sp4),

            // ── Senior Pastor (featured) ──────────────────────────────
            _FeaturedLeaderCard(
              leader: _leaders[0],
              isDark: isDark,
            ),

            const SizedBox(height: AppSpacing.sp6),

            // ── Pastoral Team ─────────────────────────────────────────
            Text(
              'Pastoral Team',
              style: AppTextStyles.headingSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sp4),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                mainAxisSpacing: AppSpacing.cardGap,
                crossAxisSpacing: AppSpacing.cardGap,
              ),
              itemCount: _leaders.length - 1,
              itemBuilder: (context, index) {
                return _LeaderCard(
                  leader: _leaders[index + 1],
                  isDark: isDark,
                );
              },
            ),

            const SizedBox(height: AppSpacing.sp8),

            // ── Ministry Leaders ──────────────────────────────────────
            Text(
              'Ministry Leaders',
              style: AppTextStyles.headingSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sp4),
            ..._ministryLeaders.map(
              (l) => Padding(
                padding:
                    const EdgeInsets.only(bottom: AppSpacing.sp2),
                child: _MinistryLeaderTile(
                  leader: l,
                  isDark: isDark,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sp12),
          ],
        ),
      ),
    );
  }

  static const _leaders = [
    _LeaderData(
      name: 'Pastor James Wilson',
      title: 'Senior Pastor',
      bio:
          'Pastor James has served as Senior Pastor for over 15 years. His passion is teaching the Word of God with clarity and helping people discover their God-given purpose. He holds a Master of Divinity from Fuller Theological Seminary.',
      initial: 'JW',
      color: Color(0xFF1E40AF),
    ),
    _LeaderData(
      name: 'Pastor Rachel Adams',
      title: 'Associate Pastor',
      bio:
          'Pastor Rachel oversees discipleship and pastoral care. She has a heart for building authentic community and mentoring the next generation.',
      initial: 'RA',
      color: Color(0xFF7C3AED),
    ),
    _LeaderData(
      name: 'Pastor Samuel Torres',
      title: 'Youth Pastor',
      bio:
          'Pastor Sam is passionate about reaching young people with the Gospel. He leads our vibrant youth ministry with energy and purpose.',
      initial: 'ST',
      color: Color(0xFFEA580C),
    ),
    _LeaderData(
      name: 'Pastor Grace Okafor',
      title: 'Worship Pastor',
      bio:
          'Pastor Grace leads our worship ministry with a deep desire to create spaces where people encounter God through music and praise.',
      initial: 'GO',
      color: Color(0xFF0891B2),
    ),
    _LeaderData(
      name: 'Pastor David Kim',
      title: 'Outreach Pastor',
      bio:
          'Pastor David coordinates our local and global missions. He believes the church exists to be the hands and feet of Jesus in the world.',
      initial: 'DK',
      color: Color(0xFF059669),
    ),
  ];

  static const _ministryLeaders = [
    _MinistryLeaderData(
      name: 'Marcus Johnson',
      ministry: "Men's Ministry",
      initial: 'MJ',
    ),
    _MinistryLeaderData(
      name: 'Angela Roberts',
      ministry: "Children's Ministry",
      initial: 'AR',
    ),
    _MinistryLeaderData(
      name: 'Tom Bradley',
      ministry: 'Community Outreach',
      initial: 'TB',
    ),
    _MinistryLeaderData(
      name: 'Victoria Lee',
      ministry: 'Administration',
      initial: 'VL',
    ),
    _MinistryLeaderData(
      name: 'Caleb Johnson',
      ministry: 'Media & Tech',
      initial: 'CJ',
    ),
  ];
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
  const _FeaturedLeaderCard({
    required this.leader,
    required this.isDark,
  });

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
            child: Text(
              leader.initial,
              style: AppTextStyles.headingLarge
                  .copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: AppSpacing.sp4),
          Text(
            leader.name,
            style: AppTextStyles.headingMedium
                .copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sp1),
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
              leader.title,
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sp4),
          Text(
            leader.bio,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LeaderCard extends StatefulWidget {
  const _LeaderCard({
    required this.leader,
    required this.isDark,
  });

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
          boxShadow:
              widget.isDark ? AppShadows.smDark : AppShadows.sm,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor:
                  widget.leader.color.withValues(alpha: 0.12),
              child: Text(
                widget.leader.initial,
                style: AppTextStyles.headingSmall.copyWith(
                  color: widget.leader.color,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sp3),
            Text(
              widget.leader.name,
              style: AppTextStyles.labelSmall.copyWith(
                color: widget.isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              widget.leader.title,
              style: AppTextStyles.bodySmall.copyWith(
                color: widget.leader.color,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
            if (_expanded) ...[
              const SizedBox(height: AppSpacing.sp2),
              Text(
                widget.leader.bio,
                style: AppTextStyles.bodySmall.copyWith(
                  color: widget.isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
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
  const _MinistryLeaderTile({
    required this.leader,
    required this.isDark,
  });

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
            backgroundColor:
                isDark ? AppColors.skyDark : AppColors.skyLight,
            child: Text(
              leader.initial,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sp3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leader.name,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  leader.ministry,
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
    );
  }
}
