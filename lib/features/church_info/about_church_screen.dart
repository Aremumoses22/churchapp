import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/theme.dart';

// ──────────────────────────────────────────────────────────────────────────────
// ABOUT CHURCH SCREEN
// ──────────────────────────────────────────────────────────────────────────────

class AboutChurchScreen extends ConsumerWidget {
  const AboutChurchScreen({super.key});

  static const _kValueIcons = [
    Icons.menu_book_outlined,
    Icons.favorite_outline,
    Icons.groups_outlined,
    Icons.public_outlined,
    Icons.trending_up,
    Icons.star_outline,
    Icons.lightbulb_outline,
  ];
  static const _kValueColors = [
    Color(0xFF1E40AF),
    Color(0xFFDC2626),
    Color(0xFF059669),
    Color(0xFFF59E0B),
    Color(0xFF7C3AED),
    Color(0xFF0891B2),
    Color(0xFFEA580C),
  ];



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final church = ref.watch(churchAboutProvider).value;

    final churchName = church?.name ?? 'Grace Community Church';
    final tagline = church?.tagline ?? 'Est. 1998  •  Reaching the world with love';
    final mission = church?.mission ?? 'To know God, grow in faith, and make Him known to every generation.';
    final vision = church?.vision ?? 'We envision a community transformed by the love of Jesus Christ, where every person discovers their purpose, grows in their faith, and impacts the world around them.';

    final coreValues = church != null && church.coreValues.isNotEmpty
        ? church.coreValues.asMap().entries.map((e) => _CoreValue(
              icon: _kValueIcons[e.key % _kValueIcons.length],
              title: e.value.title,
              subtitle: e.value.description ?? '',
              color: _kValueColors[e.key % _kValueColors.length],
            )).toList()
        : <_CoreValue>[];

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: AppGradients.hero),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenHorizontalPadding, 60,
                      AppSpacing.screenHorizontalPadding, AppSpacing.sp6,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: AppRadius.borderRadiusMd,
                          ),
                          child: const Center(child: Icon(Icons.church, color: Colors.white, size: 32)),
                        ),
                        const SizedBox(height: AppSpacing.sp3),
                        Text(churchName, style: AppTextStyles.headingLarge.copyWith(color: Colors.white)),
                        const SizedBox(height: AppSpacing.sp1),
                        Text(
                          tagline,
                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.sp4),

                  _SectionTitle(title: 'Our Mission', isDark: isDark),
                  const SizedBox(height: AppSpacing.sp3),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sp4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.surface,
                      borderRadius: AppRadius.borderRadiusLg,
                      boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.auto_awesome, color: AppColors.gold, size: 28),
                        const SizedBox(height: AppSpacing.sp3),
                        Text(
                          mission,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            fontStyle: FontStyle.italic,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sp6),

                  _SectionTitle(title: 'Our Vision', isDark: isDark),
                  const SizedBox(height: AppSpacing.sp3),
                  Text(
                    vision,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sp8),

                  _SectionTitle(title: 'Core Values', isDark: isDark),
                  const SizedBox(height: AppSpacing.sp4),
                  ...coreValues.map(
                    (v) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sp3),
                      child: _ValueCard(
                        icon: v.icon,
                        title: v.title,
                        subtitle: v.subtitle,
                        color: v.color,
                        isDark: isDark,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sp6),

                  _SectionTitle(title: 'Service Times', isDark: isDark),
                  const SizedBox(height: AppSpacing.sp3),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sp4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.surface,
                      borderRadius: AppRadius.borderRadiusLg,
                      boxShadow: isDark ? AppShadows.xsDark : AppShadows.xs,
                    ),
                    child: Column(
                      children: [
                        _ServiceTimeRow(day: 'Sunday', times: '8:00 AM  •  10:30 AM  •  6:00 PM', isDark: isDark, isPrimary: true),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sp3),
                          child: Container(height: 0.5, color: isDark ? AppColors.borderDark : AppColors.divider),
                        ),
                        _ServiceTimeRow(day: 'Wednesday', times: '7:00 PM  •  Bible Study & Prayer', isDark: isDark),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sp3),
                          child: Container(height: 0.5, color: isDark ? AppColors.borderDark : AppColors.divider),
                        ),
                        _ServiceTimeRow(day: 'Friday', times: '7:00 PM  •  Youth Service', isDark: isDark),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sp8),

                  if (church != null && church.timeline.isNotEmpty) ...[
                    _SectionTitle(title: 'Our Story', isDark: isDark),
                    const SizedBox(height: AppSpacing.sp4),
                    ...church.timeline.asMap().entries.map(
                      (entry) => _TimelineItem(
                        year: entry.value.year,
                        title: entry.value.title,
                        description: entry.value.description,
                        isLast: entry.key == church.timeline.length - 1,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp8),
                  ],

                  _SectionTitle(title: 'By the Numbers', isDark: isDark),
                  const SizedBox(height: AppSpacing.sp4),
                  Row(
                    children: [
                      Expanded(child: _StatCard(value: '2,500+', label: 'Members', icon: Icons.people_outline, isDark: isDark)),
                      const SizedBox(width: AppSpacing.cardGap),
                      Expanded(child: _StatCard(value: '25+', label: 'Ministries', icon: Icons.volunteer_activism_outlined, isDark: isDark)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                  Row(
                    children: [
                      Expanded(child: _StatCard(value: '3', label: 'Campuses', icon: Icons.church_outlined, isDark: isDark)),
                      const SizedBox(width: AppSpacing.cardGap),
                      Expanded(child: _StatCard(value: '26', label: 'Years', icon: Icons.history_outlined, isDark: isDark)),
                    ],
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
}

// ── Data ─────────────────────────────────────────────────────────────────────

class _CoreValue {
  const _CoreValue({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
}

// ── Widgets ─────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.isDark});

  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.headingSmall.copyWith(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Center(child: Icon(icon, color: color, size: 22)),
          ),
          const SizedBox(width: AppSpacing.sp3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
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

class _ServiceTimeRow extends StatelessWidget {
  const _ServiceTimeRow({
    required this.day,
    required this.times,
    required this.isDark,
    this.isPrimary = false,
  });

  final String day;
  final String times;
  final bool isDark;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            day,
            style: AppTextStyles.labelMedium.copyWith(
              color: isPrimary
                  ? (isDark ? AppColors.primaryLight : AppColors.primary)
                  : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
            ),
          ),
        ),
        Expanded(
          child: Text(
            times,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.year,
    required this.title,
    required this.description,
    required this.isLast,
    required this.isDark,
  });

  final String year;
  final String title;
  final String description;
  final bool isLast;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isDark ? AppColors.borderDark : AppColors.inputBorder,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sp5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(year, style: AppTextStyles.labelSmall.copyWith(color: isDark ? AppColors.primaryLight : AppColors.primary)),
                  const SizedBox(height: 2),
                  Text(title, style: AppTextStyles.labelMedium.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                  const SizedBox(height: AppSpacing.sp1),
                  Text(description, style: AppTextStyles.bodySmall.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.isDark,
  });

  final String value;
  final String label;
  final IconData icon;
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
      child: Column(
        children: [
          Icon(icon, size: 24, color: isDark ? AppColors.textSecondaryDark : AppColors.primary),
          const SizedBox(height: AppSpacing.sp2),
          Text(value, style: AppTextStyles.headingMedium.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
        ],
      ),
    );
  }
}
