import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SHIMMER SKELETON LOADER
// ──────────────────────────────────────────────────────────────────────────────

/// A shimmer-animated placeholder that matches the shape of the widget
/// it will replace once data has loaded.
///
/// Colour: `#E5E7EB` (light) / `#1F2937` (dark).
/// Animation: gradient sweeps left → right, 1.5 s loop.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.borderDark : AppColors.inputBorder;
    final highlightColor =
        isDark ? const Color(0xFF2D3748) : const Color(0xFFF3F4F6);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? AppRadius.borderRadiusMd,
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(1.0 + 2.0 * _controller.value, 0),
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// SKELETON PRESETS
// ──────────────────────────────────────────────────────────────────────────────

/// Pre-configured skeleton shapes for common screen elements.
class SkeletonPresets {
  SkeletonPresets._();

  /// 160 × full-width verse card skeleton.
  static Widget verseCard() => Padding(
        padding: AppSpacing.screenPadding,
        child: ShimmerBox(
          width: double.infinity,
          height: 160,
          borderRadius: AppRadius.borderRadiusXl,
        ),
      );

  /// 100 × full-width sermon / feature card skeleton.
  static Widget featureCard() => Padding(
        padding: AppSpacing.screenPadding,
        child: ShimmerBox(
          width: double.infinity,
          height: 100,
          borderRadius: AppRadius.borderRadiusXl,
        ),
      );

  /// 130 px square card for quick-access grid.
  static Widget quickAccessCard() => ShimmerBox(
        width: double.infinity,
        height: 130,
        borderRadius: AppRadius.borderRadiusXl,
      );

  /// 200 × 220 px event card (horizontal scroll).
  static Widget eventCard() => ShimmerBox(
        width: 220,
        height: 200,
        borderRadius: AppRadius.borderRadiusXl,
      );

  /// 48 px full-width search bar skeleton.
  static Widget searchBar() => Padding(
        padding: AppSpacing.screenPadding,
        child: ShimmerBox(
          width: double.infinity,
          height: 48,
          borderRadius: AppRadius.borderRadiusFull,
        ),
      );

  /// 36 × 80 px filter chip skeleton.
  static Widget filterChip() => ShimmerBox(
        width: 80,
        height: 36,
        borderRadius: AppRadius.borderRadiusFull,
      );

  /// Row of filter chip skeletons.
  static Widget filterChipRow({int count = 4}) => SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: AppSpacing.screenPadding,
          itemCount: count,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sp2),
          itemBuilder: (_, __) => filterChip(),
        ),
      );

  /// 2 × 2 grid of quick-access card skeletons.
  static Widget quickAccessGrid() => Padding(
        padding: AppSpacing.screenPadding,
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.cardGap,
          crossAxisSpacing: AppSpacing.cardGap,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1,
          children: List.generate(4, (_) => quickAccessCard()),
        ),
      );

  /// Horizontal scroll row of event card skeletons.
  static Widget eventCardRow({int count = 3}) => SizedBox(
        height: 200,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: AppSpacing.screenPadding,
          itemCount: count,
          separatorBuilder: (_, __) =>
              const SizedBox(width: AppSpacing.cardGap),
          itemBuilder: (_, __) => eventCard(),
        ),
      );

  /// Payment option skeleton (72 px tall).
  static Widget paymentOption() => Padding(
        padding: AppSpacing.screenPadding,
        child: ShimmerBox(
          width: double.infinity,
          height: 72,
          borderRadius: AppRadius.borderRadiusLg,
        ),
      );
}
