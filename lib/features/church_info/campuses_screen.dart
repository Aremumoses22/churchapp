import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/church_info.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// CAMPUSES / LOCATIONS SCREEN
// ──────────────────────────────────────────────────────────────────────────────

class CampusesScreen extends ConsumerWidget {
  const CampusesScreen({super.key});

  static const _kColors = [
    Color(0xFF1E40AF),
    Color(0xFF059669),
    Color(0xFF7C3AED),
    Color(0xFFEA580C),
    Color(0xFF0891B2),
  ];


  List<_CampusData> _fromApi(List<Campus> campuses) {
    return campuses.asMap().entries.map((e) {
      final c = e.value;
      final serviceStrings = c.serviceTimes
          .map((s) => '${s.dayOfWeek} ${s.time}${s.label != null ? "  •  ${s.label}" : ""}')
          .toList();
      return _CampusData(
        name: c.name,
        address: c.address,
        city: '',
        phone: c.phone ?? '',
        pastor: '',
        services: serviceStrings,
        description: '',
        color: _kColors[e.key % _kColors.length],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final campusesAsync = ref.watch(churchCampusesProvider);

    final campuses = campusesAsync.when(
      loading: () => null,
      error: (_, _) => <_CampusData>[],
      data: (data) => _fromApi(data),
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      appBar: AppFilledAppBar(title: 'Our Locations', showBack: true),
      body: campuses == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.sp4),

                  Text(
                    'Find a campus near you',
                    style: AppTextStyles.headingSmall.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sp2),
                  Text(
                    'We have ${campuses.length} campus${campuses.length == 1 ? "" : "es"} across the city, each with their own unique community feel.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sp6),

                  ...campuses.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sp4),
                      child: _CampusCard(campus: c, isDark: isDark),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sp8),

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
                          child: const Icon(Icons.language, color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: AppSpacing.sp3),
                        Text('Online Campus', style: AppTextStyles.headingSmall.copyWith(color: Colors.white)),
                        const SizedBox(height: AppSpacing.sp2),
                        Text(
                          'Join us from anywhere in the world.\nLive services stream every Sunday at 10:30 AM.',
                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.85), height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sp4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp6, vertical: AppSpacing.sp3),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.borderRadiusFull),
                          child: Text('Watch Live', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
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
  const _CampusCard({required this.campus, required this.isDark});

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
                  Icon(Icons.map_outlined, size: 40, color: campus.color.withValues(alpha: 0.5)),
                  const SizedBox(height: AppSpacing.sp2),
                  Text('Map View', style: AppTextStyles.bodySmall.copyWith(color: campus.color.withValues(alpha: 0.5))),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sp4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: campus.color, shape: BoxShape.circle)),
                    const SizedBox(width: AppSpacing.sp2),
                    Text(
                      campus.name,
                      style: AppTextStyles.headingSmall.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),

                if (campus.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sp2),
                  Text(
                    campus.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.sp3),

                _InfoRow(icon: Icons.location_on_outlined, text: campus.city.isEmpty ? campus.address : '${campus.address}\n${campus.city}', isDark: isDark),

                if (campus.phone.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sp2),
                  _InfoRow(icon: Icons.phone_outlined, text: campus.phone, isDark: isDark),
                ],

                if (campus.pastor.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sp2),
                  _InfoRow(icon: Icons.person_outline, text: campus.pastor, isDark: isDark),
                ],

                if (campus.services.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sp3),
                  Wrap(
                    spacing: AppSpacing.sp2,
                    runSpacing: AppSpacing.sp2,
                    children: campus.services.map((s) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp3, vertical: AppSpacing.sp1),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.skyDark : AppColors.skyLight,
                          borderRadius: AppRadius.borderRadiusFull,
                        ),
                        child: Text(
                          s,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark ? AppColors.primaryLight : AppColors.primary,
                            fontSize: 11,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: AppSpacing.sp4),

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
                      backgroundColor: isDark ? AppColors.skyDark : AppColors.skyLight,
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
  const _InfoRow({required this.icon, required this.text, required this.isDark});

  final IconData icon;
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: isDark ? AppColors.textSecondaryDark : AppColors.textDisabled),
        const SizedBox(width: AppSpacing.sp2),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
