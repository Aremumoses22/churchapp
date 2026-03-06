import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'app_tap_animation.dart';

// ──────────────────────────────────────────────────────────────────────────────
// PRAYER FAB
// ──────────────────────────────────────────────────────────────────────────────

/// Floating Action Button for the prayer request.
///
/// 56 × 56 px · `colorGold` · white praying-hands icon · `shadow-lg` ·
/// positioned bottom-right above the bottom nav (bottom: 80 px, right: 16 px).
///
/// Press animation: scale 0.92 → spring back.
class AppPrayerFab extends StatelessWidget {
  const AppPrayerFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      bottom: 80,
      right: AppSpacing.sp4,
      child: Semantics(
        label: 'Submit a prayer request',
        button: true,
        child: AppTapAnimation(
          onTap: onPressed,
          scaleDown: 0.92,
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
              boxShadow: isDark ? AppShadows.lgDark : AppShadows.lg,
            ),
            child: const Center(
              child: Icon(
                Icons.volunteer_activism,
                color: AppColors.textInverse,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
