import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'app_tap_animation.dart';

// ──────────────────────────────────────────────────────────────────────────────
// STANDARD CARD
// ──────────────────────────────────────────────────────────────────────────────

/// Standard card container — `colorSurface`, `radius-xl`, `shadow-sm`,
/// lifts on tap (translateY –2 px + `shadow-md`).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.width,
    this.height,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppTapAnimation(
      onTap: onTap,
      liftEffect: onTap != null,
      child: Container(
        width: width,
        height: height,
        padding: padding ?? AppSpacing.cardContentPadding,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: AppRadius.borderRadiusXl,
          boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
        ),
        child: child,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// FEATURE CARD (Horizontal — thumbnail + content)
// ──────────────────────────────────────────────────────────────────────────────

/// 120 px horizontal card — left thumbnail 80 × 80 px + right content.
class AppFeatureCard extends StatelessWidget {
  const AppFeatureCard({
    super.key,
    required this.title,
    this.subtitle,
    this.thumbnailUrl,
    this.thumbnailIcon,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final String? thumbnailUrl;
  final Widget? thumbnailIcon;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppTapAnimation(
      onTap: onTap,
      liftEffect: true,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: AppRadius.borderRadiusXl,
          boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
        ),
        child: Row(
          children: [
            // Thumbnail
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sp3),
              child: ClipRRect(
                borderRadius: AppRadius.borderRadiusLg,
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: thumbnailUrl != null
                      ? Image.network(
                          thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderBox(isDark),
                        )
                      : thumbnailIcon ?? _placeholderBox(isDark),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sp3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLargeSemiBold.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.sp1),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sp3),
                child: trailing,
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderBox(bool isDark) => Container(
        color: isDark ? AppColors.skyDark : AppColors.skyLight,
        child: const Icon(Icons.image_outlined, color: AppColors.textDisabled),
      );
}

// ──────────────────────────────────────────────────────────────────────────────
// VERSE CARD
// ──────────────────────────────────────────────────────────────────────────────

/// 160 px gradient card for Today's verse.
///
/// Fades in over 600 ms on first build.
class AppVerseCard extends StatefulWidget {
  const AppVerseCard({
    super.key,
    required this.reference,
    required this.verseText,
    this.onTap,
  });

  final String reference;
  final String verseText;
  final VoidCallback? onTap;

  @override
  State<AppVerseCard> createState() => _AppVerseCardState();
}

class _AppVerseCardState extends State<AppVerseCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            height: 160,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
            padding: const EdgeInsets.all(AppSpacing.sp5),
            decoration: BoxDecoration(
              gradient: isDark ? AppGradients.verseCardDark : AppGradients.verseCard,
              borderRadius: AppRadius.borderRadiusXl,
            ),
            child: Stack(
              children: [
                // Book icon top-right
                const Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 24,
                    color: AppColors.gold,
                  ),
                ),

                // Verse content bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.reference,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sp1),
                      Text(
                        widget.verseText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.verseText,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// EVENT CARD
// ──────────────────────────────────────────────────────────────────────────────

/// 200 px event card with banner image, date badge and content.
class AppEventCard extends StatelessWidget {
  const AppEventCard({
    super.key,
    required this.title,
    required this.date,
    this.location,
    this.imageUrl,
    this.onTap,
    this.width,
  });

  final String title;
  final String date;
  final String? location;
  final String? imageUrl;
  final VoidCallback? onTap;

  /// Provide a fixed width for horizontal-scroll lists (e.g. 220 px).
  final double? width;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppTapAnimation(
      onTap: onTap,
      liftEffect: true,
      child: Container(
        width: width,
        height: 200,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: AppRadius.borderRadiusXl,
          boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.xl),
                    topRight: Radius.circular(AppRadius.xl),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 120,
                    child: imageUrl != null
                        ? Image.network(imageUrl!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _imagePlaceholder(isDark))
                        : _imagePlaceholder(isDark),
                  ),
                ),
                // Date badge
                Positioned(
                  top: AppSpacing.sp2,
                  right: AppSpacing.sp2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sp2, vertical: AppSpacing.sp1),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppRadius.borderRadiusSm,
                    ),
                    child: Text(
                      date,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textInverse,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content area
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sp3, vertical: AppSpacing.sp3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (location != null) ...[
                    const SizedBox(height: AppSpacing.sp1),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.sp1),
                        Expanded(
                          child: Text(
                            location!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder(bool isDark) => Container(
        color: isDark ? AppColors.skyDark : AppColors.skyLight,
        child: const Center(
          child: Icon(Icons.event, size: 32, color: AppColors.textDisabled),
        ),
      );
}

// ──────────────────────────────────────────────────────────────────────────────
// QUICK-ACCESS CARD (2 × 2 grid item)
// ──────────────────────────────────────────────────────────────────────────────

/// 130 px tall card for the Home screen quick-access grid.
class AppQuickAccessCard extends StatelessWidget {
  const AppQuickAccessCard({
    super.key,
    required this.label,
    required this.icon,
    this.subLabel,
    this.onTap,
    this.isLive = false,
    this.iconBackgroundColor,
    this.iconColor,
  });

  final String label;
  final IconData icon;
  final String? subLabel;
  final VoidCallback? onTap;
  final bool isLive;
  final Color? iconBackgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgIcon = iconBackgroundColor ??
        (isDark ? AppColors.skyDark : AppColors.skyLight);
    final fgIcon = iconColor ??
        (isDark ? AppColors.primaryLight : AppColors.primary);

    return AppTapAnimation(
      onTap: onTap,
      liftEffect: true,
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(AppSpacing.sp4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: AppRadius.borderRadiusXl,
          boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isLive ? AppColors.primary : bgIcon,
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.sp2),
                  child: Icon(icon, size: 24,
                      color: isLive ? AppColors.textInverse : fgIcon),
                ),
                const Spacer(),
                // Label
                Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                if (subLabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subLabel!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),

            // LIVE badge
            if (isLive)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: AppRadius.borderRadiusFull,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.textInverse,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textInverse,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// GIVING AMOUNT CHIP
// ──────────────────────────────────────────────────────────────────────────────

/// Selectable chip for the Giving screen amount presets.
///
/// Min width 100 px, height 48 px, `radius-full`, animated background crossfade.
class AppGivingAmountChip extends StatelessWidget {
  const AppGivingAmountChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return AppTapAnimation(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        constraints: const BoxConstraints(minWidth: 100),
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : (isDark ? AppColors.skyDark : AppColors.skyLight),
          border: isSelected
              ? null
              : Border.all(color: primaryColor, width: 1.5),
          borderRadius: AppRadius.borderRadiusFull,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected
                  ? AppColors.textInverse
                  : primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
