import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/giving.dart';
import '../../core/providers/giving_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// GIVING CAMPAIGN SCREEN
//
// Fundraiser detail: goal thermometer with animated fill, days remaining,
// donor count, description. Data loaded from /giving/campaigns/:id.
// ──────────────────────────────────────────────────────────────────────────────

class GivingCampaignScreen extends ConsumerStatefulWidget {
  const GivingCampaignScreen({super.key, this.campaignId});

  final String? campaignId;

  @override
  ConsumerState<GivingCampaignScreen> createState() =>
      _GivingCampaignScreenState();
}

class _GivingCampaignScreenState extends ConsumerState<GivingCampaignScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _thermometerCtrl;
  late Animation<double> _fillAnim;
  double _lastProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _thermometerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fillAnim = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _thermometerCtrl, curve: Curves.easeOutCubic),
    );
  }

  void _startAnimation(double progress) {
    if (progress == _lastProgress) return;
    _lastProgress = progress;
    _fillAnim = Tween<double>(begin: 0.0, end: progress).animate(
      CurvedAnimation(parent: _thermometerCtrl, curve: Curves.easeOutCubic),
    );
    _thermometerCtrl.forward(from: 0.0);
  }

  @override
  void dispose() {
    _thermometerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final id = widget.campaignId ?? '';
    final campaignAsync = ref.watch(givingCampaignProvider(id));

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      body: campaignAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Scaffold(
          appBar: AppFilledAppBar(title: 'Campaign', showBack: true),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 48),
                const SizedBox(height: AppSpacing.sp3),
                Text('Failed to load campaign',
                    style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.sp3),
                AppSecondaryButton(
                  label: 'Retry',
                  onPressed: () =>
                      ref.invalidate(givingCampaignProvider(id)),
                ),
              ],
            ),
          ),
        ),
        data: (campaign) {
          if (campaign == null) {
            return Scaffold(
              appBar: AppFilledAppBar(title: 'Campaign', showBack: true),
              body: const Center(child: Text('Campaign not found')),
            );
          }
          WidgetsBinding.instance.addPostFrameCallback(
              (_) => _startAnimation(campaign.progressPercent));
          return _CampaignBody(
            campaign: campaign,
            fillAnim: _fillAnim,
            thermometerCtrl: _thermometerCtrl,
            isDark: isDark,
          );
        },
      ),
    );
  }
}

// ── Campaign body (extracted so it only builds once data is available) ────────

class _CampaignBody extends StatelessWidget {
  const _CampaignBody({
    required this.campaign,
    required this.fillAnim,
    required this.thermometerCtrl,
    required this.isDark,
  });

  final GivingCampaign campaign;
  final Animation<double> fillAnim;
  final AnimationController thermometerCtrl;
  final bool isDark;

  String _formatNum(double n) {
    if (n >= 1000000) {
      return '${(n / 1000000).toStringAsFixed(n % 1000000 == 0 ? 0 : 1)}M';
    }
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}K';
    }
    return n.toInt().toString();
  }

  int _daysRemaining() {
    if (campaign.endDate == null) return 0;
    try {
      final end = DateTime.parse(campaign.endDate!);
      return end.difference(DateTime.now()).inDays.clamp(0, 9999);
    } catch (_) {
      return 0;
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return 'N/A';
    try {
      final dt = DateTime.parse(iso);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = campaign.progressPercent;
    final days = _daysRemaining();

    return CustomScrollView(
      slivers: [
        // ── Hero header ────────────────────────────────────────────────
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
                    if (campaign.imageUrl != null)
                      ClipRRect(
                        borderRadius: AppRadius.borderRadiusMd,
                        child: Image.network(
                          campaign.imageUrl!,
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Text(
                            '🏗️',
                            style: TextStyle(fontSize: 56),
                          ),
                        ),
                      )
                    else
                      const Text('🏗️', style: TextStyle(fontSize: 56)),
                    const SizedBox(height: AppSpacing.sp2),
                    Text(campaign.title,
                        style: AppTextStyles.headingLarge
                            .copyWith(color: Colors.white),
                        textAlign: TextAlign.center),
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

              // ── Goal thermometer ───────────────────────────────────
              Container(
                padding: const EdgeInsets.all(AppSpacing.sp5),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.surface,
                  borderRadius: AppRadius.borderRadiusLg,
                  boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
                ),
                child: Column(
                  children: [
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
                              '₦${_formatNum(campaign.raisedAmount)}',
                              style: AppTextStyles.headingLarge
                                  .copyWith(color: AppColors.success),
                            ),
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
                              '₦${_formatNum(campaign.goalAmount)}',
                              style: AppTextStyles.headingMedium.copyWith(
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sp4),
                    AnimatedBuilder(
                      animation: fillAnim,
                      builder: (context, _) {
                        return Column(
                          children: [
                            ClipRRect(
                              borderRadius: AppRadius.borderRadiusFull,
                              child: SizedBox(
                                height: 14,
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.borderDark
                                            : AppColors.inputFill,
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: fillAnim.value,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: [
                                            AppColors.success,
                                            AppColors.success
                                                .withValues(alpha: 0.75),
                                            AppColors.gold,
                                          ]),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sp2),
                            Text(
                              '${(fillAnim.value * 100).toInt()}% funded',
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

              // ── Stats row ──────────────────────────────────────────
              Row(
                children: [
                  _StatPill(
                    icon: Icons.timer_outlined,
                    value: '$days',
                    label: 'Days Left',
                    isDark: isDark,
                  ),
                  const SizedBox(width: AppSpacing.sp3),
                  _StatPill(
                    icon: Icons.people_outline,
                    value: '${campaign.donorCount}',
                    label: 'Donors',
                    isDark: isDark,
                  ),
                  const SizedBox(width: AppSpacing.sp3),
                  _StatPill(
                    icon: Icons.show_chart,
                    value: '${(progress * 100).toInt()}%',
                    label: 'Complete',
                    isDark: isDark,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sp6),

              // ── Description ────────────────────────────────────────
              Text('About This Campaign',
                  style: AppTextStyles.headingSmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.sp2),
              Text(
                campaign.description ?? 'No description available.',
                style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    height: 1.6),
              ),

              if (campaign.startDate != null || campaign.endDate != null) ...[
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
                      '${_formatDate(campaign.startDate)} — ${_formatDate(campaign.endDate)}',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textDisabled),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: AppSpacing.sp8),

              // ── CTA ────────────────────────────────────────────────
              AppPrimaryButton(
                label: 'Give to This Campaign',
                icon: const Icon(Icons.favorite_outline,
                    color: Colors.white, size: 18),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: AppSpacing.sp10),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Stat pill widget ─────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  const _StatPill({
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
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary)),
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
