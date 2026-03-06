import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// CAMPUSES / LOCATIONS SCREEN
//
// List view of branches, each with address, service times,
// directions button, campus pastor.
// ──────────────────────────────────────────────────────────────────────────────

class CampusesScreen extends StatelessWidget {
  const CampusesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(
        title: 'Our Locations',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sp4),

            // ── Header text ───────────────────────────────────────────
            Text(
              'Find a campus near you',
              style: AppTextStyles.headingSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sp2),
            Text(
              'We have 3 campuses across the city, each with their own unique community feel. All campuses share the same teaching and worship experience.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: AppSpacing.sp6),

            // ── Campus cards ──────────────────────────────────────────
            ..._campuses.map(
              (c) => Padding(
                padding:
                    const EdgeInsets.only(bottom: AppSpacing.sp4),
                child: _CampusCard(campus: c, isDark: isDark),
              ),
            ),

            const SizedBox(height: AppSpacing.sp8),

            // ── Online campus ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sp5),
              decoration: BoxDecoration(
                gradient: AppGradients.hero,
                borderRadius: AppRadius.borderRadiusLg,
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.language,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sp3),
                  Text(
                    'Online Campus',
                    style: AppTextStyles.headingSmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sp2),
                  Text(
                    'Join us from anywhere in the world.\nLive services stream every Sunday at 10:30 AM.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sp4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sp6,
                      vertical: AppSpacing.sp3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.borderRadiusFull,
                    ),
                    child: Text(
                      'Watch Live',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sp12),
          ],
        ),
      ),
    );
  }

  static const _campuses = [
    _CampusData(
      name: 'Main Campus',
      address: '1234 Grace Avenue, Downtown',
      city: 'Springfield, IL 62701',
      phone: '(555) 123-4567',
      pastor: 'Pastor James Wilson',
      services: ['Sunday 8:00 AM', 'Sunday 10:30 AM', 'Sunday 6:00 PM'],
      description:
          'Our flagship campus in the heart of downtown. Home to our main worship center, youth center, and community outreach programs.',
      color: Color(0xFF1E40AF),
    ),
    _CampusData(
      name: 'Northside Campus',
      address: '5678 Maple Drive',
      city: 'Springfield, IL 62704',
      phone: '(555) 234-5678',
      pastor: 'Pastor Rachel Adams',
      services: ['Sunday 9:00 AM', 'Sunday 11:00 AM'],
      description:
          'A growing community on the north side, known for its family-friendly atmosphere and strong children ministry.',
      color: Color(0xFF059669),
    ),
    _CampusData(
      name: 'Westside Campus',
      address: '9012 Oak Street',
      city: 'Springfield, IL 62707',
      phone: '(555) 345-6789',
      pastor: 'Pastor David Kim',
      services: ['Sunday 10:00 AM', 'Wednesday 7:00 PM'],
      description:
          'Our newest campus serving the west side community with a focus on outreach and community engagement.',
      color: Color(0xFF7C3AED),
    ),
  ];
}

// ── Data ─────────────────────────────────────────────────────────────────────

class _CampusData {
  const _CampusData({
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
    required this.pastor,
    required this.services,
    required this.description,
    required this.color,
  });

  final String name;
  final String address;
  final String city;
  final String phone;
  final String pastor;
  final List<String> services;
  final String description;
  final Color color;
}

// ── Widgets ─────────────────────────────────────────────────────────────────

class _CampusCard extends StatelessWidget {
  const _CampusCard({
    required this.campus,
    required this.isDark,
  });

  final _CampusData campus;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surface,
        borderRadius: AppRadius.borderRadiusLg,
        boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Map placeholder ─────────────────────────────────────────
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: campus.color.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 40,
                    color: campus.color.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppSpacing.sp2),
                  Text(
                    'Map View',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: campus.color.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Info ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sp4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: campus.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sp2),
                    Text(
                      campus.name,
                      style: AppTextStyles.headingSmall.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sp2),

                Text(
                  campus.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: AppSpacing.sp3),

                // Address
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  text: '${campus.address}\n${campus.city}',
                  isDark: isDark,
                ),

                const SizedBox(height: AppSpacing.sp2),

                // Phone
                _InfoRow(
                  icon: Icons.phone_outlined,
                  text: campus.phone,
                  isDark: isDark,
                ),

                const SizedBox(height: AppSpacing.sp2),

                // Pastor
                _InfoRow(
                  icon: Icons.person_outline,
                  text: campus.pastor,
                  isDark: isDark,
                ),

                const SizedBox(height: AppSpacing.sp3),

                // Service times
                Wrap(
                  spacing: AppSpacing.sp2,
                  runSpacing: AppSpacing.sp2,
                  children: campus.services.map((s) {
                    return Container(
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
                        s,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
                          fontSize: 11,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppSpacing.sp4),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: AppPrimaryButton(
                        label: 'Get Directions',
                        onPressed: () {},
                        icon: const Icon(Icons.directions_outlined, color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sp3),
                    AppIconButton(
                      icon: Icons.phone_outlined,
                      onPressed: () {},
                      backgroundColor: isDark
                          ? AppColors.skyDark
                          : AppColors.skyLight,
                      iconColor: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    required this.isDark,
  });

  final IconData icon;
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textDisabled,
        ),
        const SizedBox(width: AppSpacing.sp2),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
