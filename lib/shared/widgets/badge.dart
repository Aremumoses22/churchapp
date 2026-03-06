import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

// ──────────────────────────────────────────────────────────────────────────────
// BADGE
// ──────────────────────────────────────────────────────────────────────────────

/// Small notification / premium badge.
///
/// Min 20 × 20 px · `radius-full` · positioned absolute top-right of parent.
///
/// Wrap a widget with [AppBadge] and provide a [count] or set [showDot] for a
/// simple red dot.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.child,
    this.count,
    this.showDot = false,
    this.color,
  });

  /// The widget to attach the badge to.
  final Widget child;

  /// If non-null and > 0, shows the count inside the badge.
  final int? count;

  /// If true and [count] is null, shows a small red dot.
  final bool showDot;

  /// Override badge background (default `colorError` for notification,
  /// use `AppColors.gold` for premium).
  final Color? color;

  bool get _visible => showDot || (count != null && count! > 0);

  @override
  Widget build(BuildContext context) {
    if (!_visible) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -4,
          right: -4,
          child: count != null && count! > 0
              ? _CountBadge(count: count!, color: color ?? AppColors.error)
              : _DotBadge(color: color ?? AppColors.error),
        ),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.color});
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.borderRadiusFull,
      ),
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textInverse,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _DotBadge extends StatelessWidget {
  const _DotBadge({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 1.5),
      ),
    );
  }
}
