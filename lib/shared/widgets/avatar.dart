import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

// ──────────────────────────────────────────────────────────────────────────────
// AVATAR
// ──────────────────────────────────────────────────────────────────────────────

/// Circle avatar with 4 sizes.
///
/// Falls back to initials on a `colorPrimary` background when no image is
/// provided.  Optionally renders a white border for use on coloured surfaces.
enum AvatarSize {
  sm(32),
  md(48),
  lg(72),
  xl(100);

  const AvatarSize(this.diameter);
  final double diameter;
}

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = AvatarSize.md,
    this.showBorder = false,
    this.borderColor,
    this.onTap,
  });

  final String? imageUrl;

  /// One or two characters shown when there is no image.
  final String? initials;
  final AvatarSize size;
  final bool showBorder;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final diameter = size.diameter;
    final fontSize = diameter * 0.38;
    final border = showBorder
        ? Border.all(
            color: borderColor ?? AppColors.textInverse,
            width: size == AvatarSize.xl ? 3 : 2,
          )
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
          border: border,
          image: imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: imageUrl == null
            ? Center(
                child: Text(
                  (initials ?? '?').toUpperCase(),
                  style: TextStyle(
                    color: AppColors.textInverse,
                    fontWeight: FontWeight.w600,
                    fontSize: fontSize,
                    height: 1,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
