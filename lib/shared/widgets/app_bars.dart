import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';
import 'app_tap_animation.dart';

// ──────────────────────────────────────────────────────────────────────────────
// TRANSPARENT APP BAR (Home screen — overlays hero gradient)
// ──────────────────────────────────────────────────────────────────────────────

/// Transparent app bar that sits on top of a gradient / image hero.
///
/// Leading: church logo placeholder · Trailing: notification bell + avatar.
class AppTransparentAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const AppTransparentAppBar({
    super.key,
    this.leading,
    this.actions,
  });

  final Widget? leading;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(AppSpacing.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: leading ??
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sp3),
            child: Icon(
              Icons.church_outlined,
              color: AppColors.textInverse,
              size: 28,
            ),
          ),
      actions: actions ??
          [
            const _NotificationBell(),
            const SizedBox(width: AppSpacing.sp2),
            const _MiniAvatar(),
            const SizedBox(width: AppSpacing.sp4),
          ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// FILLED APP BAR (Inner screens)
// ──────────────────────────────────────────────────────────────────────────────

/// Filled app bar with a centred title — used on inner / non-hero screens.
class AppFilledAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppFilledAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBack = false,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(AppSpacing.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark ? AppColors.cardDark : AppColors.surface,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: showBack,
      leading: leading,
      title: Text(
        title,
        style: AppTextStyles.headingMedium.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: isDark ? AppColors.borderDark : AppColors.divider,
        ),
      ),
    );
  }
}

// ─── Internal helper widgets ─────────────────────────────────────────────────

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    return AppTapAnimation(
      onTap: () {
        // TODO: navigate to notifications
      },
      child: const SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: Icon(
            Icons.notifications_outlined,
            color: AppColors.textInverse,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryLight,
        border: Border.all(color: AppColors.textInverse, width: 2),
      ),
      child: const Center(
        child: Text(
          'M',
          style: TextStyle(
            color: AppColors.textInverse,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
