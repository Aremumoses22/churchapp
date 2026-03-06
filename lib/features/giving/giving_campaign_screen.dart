import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// GIVING CAMPAIGN SCREEN
//
// Fundraiser detail with hero image, goal thermometer with animated fill,
// days remaining countdown, donor list (anonymized), "Give to This Campaign"
// CTA.
// ──────────────────────────────────────────────────────────────────────────────

class GivingCampaignScreen extends StatefulWidget {
  const GivingCampaignScreen({super.key, this.campaignId});

  final String? campaignId;

  @override
  State<GivingCampaignScreen> createState() => _GivingCampaignScreenState();
}

class _GivingCampaignScreenState extends State<GivingCampaignScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _thermometerCtrl;
  late Animation<double> _fillAnim;

  // Mock campaign data
  final _campaign = const _CampaignData(
    title: 'New Youth Center',
    subtitle: 'Building a space for the next generation',
    description:
        "Help us build a state-of-the-art youth center where young people "
        "can grow in faith, develop leadership skills, and build lasting "
        "community. The facility will include a worship hall, mentoring rooms, "
        "a game lounge, and a study area.",
    goalAmount: 250000,
    raisedAmount: 187500,
    daysRemaining: 43,
    donorCount: 312,
    startDate: '1 Dec 2025',
    endDate: '15 Mar 2026',
    heroEmoji: '🏗️',
  );

  final _donors = const [
    _DonorEntry(name: 'Anonymous', amount: 5000, timeAgo: '2h ago'),
    _DonorEntry(name: 'John D.', amount: 2500, timeAgo: '5h ago'),
    _DonorEntry(name: 'Anonymous', amount: 1000, timeAgo: '1d ago'),
    _DonorEntry(name: 'Sarah M.', amount: 500, timeAgo: '1d ago'),
    _DonorEntry(name: 'Anonymous', amount: 250, timeAgo: '2d ago'),
    _DonorEntry(name: 'Grace K.', amount: 100, timeAgo: '2d ago'),
    _DonorEntry(name: 'David L.', amount: 1500, timeAgo: '3d ago'),
    _DonorEntry(name: 'Anonymous', amount: 750, timeAgo: '4d ago'),
  ];

  @override
  void initState() {
    super.initState();
    _thermometerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fillAnim = Tween<double>(
      begin: 0.0,
      end: _campaign.raisedAmount / _campaign.goalAmount,
    ).animate(CurvedAnimation(
      parent: _thermometerCtrl,
      curve: Curves.easeOutCubic,
    ));
    // Start animation after a frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _thermometerCtrl.forward();
    });
  }

  @override
  void dispose() {
    _thermometerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = _campaign.raisedAmount / _campaign.goalAmount;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      body: CustomScrollView(
        slivers: [
          // ── Hero header ─────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: AppGradients.hero),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(_campaign.heroEmoji,
                          style: const TextStyle(fontSize: 56)),
                      const SizedBox(height: AppSpacing.sp2),
                      Text(_campaign.title,
                          style: AppTextStyles.headingLarge
                              .copyWith(color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(_campaign.subtitle,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontalPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppSpacing.sp5),

                // ── Goal thermometer ─────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sp5),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.surface,
                    borderRadius: AppRadius.borderRadiusLg,
                    boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
                  ),
                  child: Column(
                    children: [
                      // Raised / Goal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Raised',
                                  style: AppTextStyles.labelSmall.copyWith(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary)),
                              Text(
                                  '\$${_formatNum(_campaign.raisedAmount.toInt())}',
                                  style: AppTextStyles.headingLarge.copyWith(
                                      color: AppColors.success)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Goal',
                                  style: AppTextStyles.labelSmall.copyWith(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary)),
                              Text(
                                  '\$${_formatNum(_campaign.goalAmount.toInt())}',
                                  style: AppTextStyles.headingMedium.copyWith(
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary)),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.sp4),

                      // Animated progress bar
                      AnimatedBuilder(
                        animation: _fillAnim,
                        builder: (context, _) {
                          return Column(
                            children: [
                              ClipRRect(
                                borderRadius: AppRadius.borderRadiusFull,
                                child: SizedBox(
                                  height: 14,
                                  child: Stack(
                                    children: [
                                      // BG
                                      Container(
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.borderDark
                                              : AppColors.inputFill,
                                        ),
                                      ),
                                      // Fill
                                      FractionallySizedBox(
                                        widthFactor: _fillAnim.value,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.success,
                                                AppColors.success
                                                    .withValues(alpha: 0.75),
                                                AppColors.gold,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sp2),
                              Text(
                                '${(_fillAnim.value * 100).toInt()}% funded',
                                style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.sp4),

                // ── Countdown row ────────────────────────────────────
                Row(
                  children: [
                    _CountdownPill(
                      icon: Icons.timer_outlined,
                      value: '${_campaign.daysRemaining}',
                      label: 'Days Left',
                      isDark: isDark,
                    ),
                    const SizedBox(width: AppSpacing.sp3),
                    _CountdownPill(
                      icon: Icons.people_outline,
                      value: '${_campaign.donorCount}',
                      label: 'Donors',
                      isDark: isDark,
                    ),
                    const SizedBox(width: AppSpacing.sp3),
                    _CountdownPill(
                      icon: Icons.show_chart,
                      value: '${(progress * 100).toInt()}%',
                      label: 'Complete',
                      isDark: isDark,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sp6),

                // ── About ────────────────────────────────────────────
                Text('About This Campaign',
                    style: AppTextStyles.headingSmall.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary)),
                const SizedBox(height: AppSpacing.sp2),
                Text(_campaign.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        height: 1.6)),

                const SizedBox(height: AppSpacing.sp2),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textDisabled),
                    const SizedBox(width: 6),
                    Text(
                        '${_campaign.startDate} — ${_campaign.endDate}',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textDisabled)),
                  ],
                ),

                const SizedBox(height: AppSpacing.sp6),

                // ── Recent donors ────────────────────────────────────
                AppSectionHeader(
                  title: 'Recent Donors',
                  actionLabel: 'View All',
                  onAction: () {},
                ),
                const SizedBox(height: AppSpacing.sp3),

                ..._donors.map((d) => _DonorTile(donor: d, isDark: isDark)),

                const SizedBox(height: AppSpacing.sp8),

                // ── CTA button ───────────────────────────────────────
                AppPrimaryButton(
                  label: 'Give to This Campaign',
                  icon: const Icon(Icons.favorite_outline,
                      color: Colors.white, size: 18),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Opening giving form...'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.borderRadiusMd),
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.sp10),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNum(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}K';
    }
    return '$n';
  }
}

// ── Data classes ────────────────────────────────────────────────────────────

class _CampaignData {
  const _CampaignData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.goalAmount,
    required this.raisedAmount,
    required this.daysRemaining,
    required this.donorCount,
    required this.startDate,
    required this.endDate,
    required this.heroEmoji,
  });

  final String title;
  final String subtitle;
  final String description;
  final double goalAmount;
  final double raisedAmount;
  final int daysRemaining;
  final int donorCount;
  final String startDate;
  final String endDate;
  final String heroEmoji;
}

class _DonorEntry {
  const _DonorEntry({
    required this.name,
    required this.amount,
    required this.timeAgo,
  });

  final String name;
  final int amount;
  final String timeAgo;
}

// ── Widgets ─────────────────────────────────────────────────────────────────

class _CountdownPill extends StatelessWidget {
  const _CountdownPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sp3, horizontal: AppSpacing.sp2),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: AppRadius.borderRadiusMd,
          boxShadow: isDark ? AppShadows.xsDark : AppShadows.xs,
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(value,
                style: AppTextStyles.bodyLargeSemiBold.copyWith(
                    color:
                        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
            Text(label,
                style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _DonorTile extends StatelessWidget {
  const _DonorTile({required this.donor, required this.isDark});

  final _DonorEntry donor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isAnonymous = donor.name == 'Anonymous';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sp2),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isAnonymous
                ? (isDark ? AppColors.borderDark : AppColors.inputFill)
                : AppColors.primary.withValues(alpha: 0.1),
            child: Icon(
              isAnonymous ? Icons.person_off_outlined : Icons.person_outline,
              size: 16,
              color: isAnonymous ? AppColors.textDisabled : AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sp3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donor.name,
                  style: AppTextStyles.labelMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      fontStyle:
                          isAnonymous ? FontStyle.italic : FontStyle.normal),
                ),
                Text(donor.timeAgo,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textDisabled,
                        fontSize: 10)),
              ],
            ),
          ),
          Text('\$${donor.amount}',
              style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.success, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
