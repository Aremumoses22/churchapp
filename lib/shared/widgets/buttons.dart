import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'app_tap_animation.dart';

// ──────────────────────────────────────────────────────────────────────────────
// PRIMARY BUTTON
// ──────────────────────────────────────────────────────────────────────────────

/// Full-width primary CTA.
///
/// Height 52 px · `colorPrimary` background · `labelLarge` white text ·
/// `radius-md (12 px)` · press scale 0.96 · disabled opacity 0.4.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppTapAnimation(
      onTap: (onPressed != null && !isLoading) ? onPressed : null,
      child: Container(
        height: 52,
        width: isFullWidth ? double.infinity : null,
        padding: isFullWidth ? null : const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
        decoration: BoxDecoration(
          color: onPressed != null
              ? (isDark ? AppColors.primaryLight : AppColors.primary)
              : (isDark ? AppColors.primaryLight : AppColors.primary)
                  .withValues(alpha: 0.4),
          borderRadius: AppRadius.borderRadiusMd,
          boxShadow: isDark ? AppShadows.smDark : AppShadows.sm,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.textInverse,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisSize:
                      isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      icon!,
                      const SizedBox(width: AppSpacing.sp2),
                    ],
                    Text(
                      label,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textInverse,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// SECONDARY BUTTON (Outlined)
// ──────────────────────────────────────────────────────────────────────────────

/// Outlined button with `colorPrimary` border.
///
/// Height 52 px · transparent background (fills to `colorSkyLight` on press) ·
/// `colorPrimary` text · `radius-md`.
class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return AppTapAnimation(
      onTap: (onPressed != null && !isLoading) ? onPressed : null,
      child: Container(
        height: 52,
        width: isFullWidth ? double.infinity : null,
        padding: isFullWidth ? null : const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: AppRadius.borderRadiusMd,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: borderColor,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisSize:
                      isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      icon!,
                      const SizedBox(width: AppSpacing.sp2),
                    ],
                    Text(
                      label,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: borderColor,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// GHOST BUTTON (Text only)
// ──────────────────────────────────────────────────────────────────────────────

/// Text-only button — no background, no border, no shadow.
class AppGhostButton extends StatelessWidget {
  const AppGhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        color ?? (isDark ? AppColors.primaryLight : AppColors.primary);

    return AppTapAnimation(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sp2,
          vertical: AppSpacing.sp1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: AppSpacing.sp1),
            ],
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// ICON BUTTON (Circular)
// ──────────────────────────────────────────────────────────────────────────────

/// 40 × 40 circular icon button with subtle background.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 40,
    this.iconSize = 20,
    this.backgroundColor,
    this.iconColor,
    this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg =
        backgroundColor ?? (isDark ? AppColors.cardDark : AppColors.skyLight);
    final fg =
        iconColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary);

    return Semantics(
      label: semanticLabel,
      button: true,
      child: AppTapAnimation(
        onTap: onPressed,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
          child: Center(child: Icon(icon, size: iconSize, color: fg)),
        ),
      ),
    );
  }
}
