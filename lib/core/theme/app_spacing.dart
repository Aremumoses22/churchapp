import 'package:flutter/material.dart';

/// Spacing scale – all values are multiples of 4 px.
///
/// Usage: `SizedBox(height: AppSpacing.sp4)` or
///        `EdgeInsets.all(AppSpacing.sp4)`.
abstract final class AppSpacing {
  // ─── Base scale ────────────────────────────────────────────────────
  /// 4 px – Icon padding, micro gaps.
  static const double sp1 = 4;

  /// 8 px – Tight element gaps.
  static const double sp2 = 8;

  /// 12 px – Related element gaps.
  static const double sp3 = 12;

  /// 16 px – Standard padding, card inner padding.
  static const double sp4 = 16;

  /// 20 px – Section gaps.
  static const double sp5 = 20;

  /// 24 px – Large section padding.
  static const double sp6 = 24;

  /// 32 px – Screen-level top / bottom padding.
  static const double sp8 = 32;

  /// 40 px – Hero sections.
  static const double sp10 = 40;

  /// 48 px – Bottom nav clearance.
  static const double sp12 = 48;

  // ─── Screen layout constants ───────────────────────────────────────
  /// Horizontal padding for all screens.
  static const double screenHorizontalPadding = 16;

  /// Bottom navigation bar height (excluding safe area).
  static const double bottomNavHeight = 64;

  /// App bar height (excluding status bar).
  static const double appBarHeight = 56;

  /// Card inner padding (all sides).
  static const double cardPadding = 16;

  /// Vertical gap between cards in a list.
  static const double cardGap = 12;

  /// Gap between major sections.
  static const double sectionGap = 24;

  // ─── Helpers ───────────────────────────────────────────────────────
  /// Standard screen padding (16 px horizontal).
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenHorizontalPadding,
  );

  /// Card content padding (16 px all sides).
  static const EdgeInsets cardContentPadding = EdgeInsets.all(cardPadding);
}
