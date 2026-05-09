import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// EVENT DETAIL SCREEN — Section 10.5
//
// Hero image, overlapping white card, category tag, description,
// sticky registration footer.
// ──────────────────────────────────────────────────────────────────────────────

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _registered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Hero image ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 240,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl:
                            'https://picsum.photos/seed/event_${widget.eventId}/800/480',
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          decoration: BoxDecoration(
                            gradient: isDark
                                ? AppGradients.heroDark
                                : AppGradients.hero,
                          ),
                          child: Center(
                            child: Icon(Icons.event,
                                color: Colors.white.withValues(alpha: 0.3),
                                size: 80),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            gradient: isDark
                                ? AppGradients.heroDark
                                : AppGradients.hero,
                          ),
                          child: Center(
                            child: Icon(Icons.event,
                                color: Colors.white.withValues(alpha: 0.3),
                                size: 80),
                          ),
                        ),
                      ),
                      // Back + Share overlays
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sp4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _circleButton(Icons.arrow_back,
                                  () => context.pop()),
                              _circleButton(Icons.share, () {}),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Content card (overlaps hero –24px) ──────────────────
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.sp4,
                      AppSpacing.sp6,
                      AppSpacing.sp4,
                      100, // space for sticky footer
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            borderRadius: AppRadius.borderRadiusFull,
                          ),
                          child: Text('Conference',
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.gold)),
                        ),
                        const SizedBox(height: AppSpacing.sp3),

                        // Title
                        Text(
                          'Worship Conference 2026',
                          style: AppTextStyles.displayMedium.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sp4),

                        // Date row
                        _infoRow(
                          Icons.calendar_today,
                          'Sunday, February 23 \u00b7 10:00 AM',
                          isDark,
                        ),
                        const SizedBox(height: AppSpacing.sp2),

                        // Location row
                        _infoRow(
                          Icons.location_on,
                          'Grace Cathedral, Victoria Island',
                          isDark,
                          isLink: true,
                        ),

                        const SizedBox(height: AppSpacing.sp4),
                        const AppDivider(),
                        const SizedBox(height: AppSpacing.sp4),

                        // About
                        Text(
                          'About this Event',
                          style: AppTextStyles.headingSmall.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sp3),
                        Text(
                          'Join us for an extraordinary day of worship, prayer, and the Word. '
                          'This year\'s conference brings together anointed ministers and worship leaders '
                          'from across the nation for a powerful encounter with God.\n\n'
                          'Come expecting transformation, healing, and a fresh outpouring of the Holy Spirit. '
                          'There will be sessions for adults, youth, and children.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.sp4),
                        const AppDivider(),
                        const SizedBox(height: AppSpacing.sp4),

                        // Speakers
                        Text(
                          'Speakers',
                          style: AppTextStyles.headingSmall.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sp3),
                        _speakerTile('Pastor James', 'Lead Pastor', isDark),
                        const SizedBox(height: AppSpacing.sp2),
                        _speakerTile(
                            'Minister Grace', 'Worship Leader', isDark),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Sticky registration footer ──────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.surface,
                boxShadow: isDark ? AppShadows.lgDark : AppShadows.lg,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '215 attending',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: _registered
                        ? AppPrimaryButton(
                            label: '\u2713 Registered',
                            onPressed: null,
                            isFullWidth: true,
                          )
                        : AppPrimaryButton(
                            label: 'Register Now',
                            onPressed: () =>
                                setState(() => _registered = true),
                            isFullWidth: true,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, bool isDark,
      {bool isLink = false}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.gold),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isLink
                  ? (isDark ? AppColors.primaryLight : AppColors.primary)
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary),
              decoration: isLink ? TextDecoration.underline : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _speakerTile(String name, String role, bool isDark) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: isDark ? AppColors.primaryLight : AppColors.skyLight,
          child: Text(
            name[0],
            style: AppTextStyles.labelMedium.copyWith(
              color: isDark ? AppColors.textInverse : AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sp3),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: AppTextStyles.bodyLargeSemiBold.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                )),
            Text(role,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                )),
          ],
        ),
      ],
    );
  }
}
