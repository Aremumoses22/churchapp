import 'package:flutter/material.dart';

/// Typography system for the Church App.
///
/// Every text element must reference a named style from this class —
/// no raw `fontSize` values anywhere in screens.
///
/// **Font family:** Inter (Google Fonts)
/// **Loaded weights:** 400 Regular · 500 Medium · 600 SemiBold · 700 Bold
abstract final class AppTextStyles {
  static const String _fontFamily = 'Inter';

  // ─── Display ───────────────────────────────────────────────────────

  /// 32 px, Bold 700, line-height 40 px — Splash / hero headlines.
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32, // 1.25
    letterSpacing: -0.5,
  );

  /// 28 px, Bold 700, line-height 36 px — Screen titles.
  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 36 / 28, // ~1.286
    letterSpacing: -0.5,
  );

  // ─── Heading ───────────────────────────────────────────────────────

  /// 24 px, Bold 700, line-height 32 px — Section headers.
  static const TextStyle headingLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24, // ~1.333
    letterSpacing: -0.5,
  );

  /// 20 px, SemiBold 600, line-height 28 px — Card titles.
  static const TextStyle headingMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20, // 1.4
  );

  /// 18 px, SemiBold 600, line-height 26 px — Sub-section titles.
  static const TextStyle headingSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 26 / 18, // ~1.444
  );

  // ─── Body ──────────────────────────────────────────────────────────

  /// 16 px, Regular 400, line-height 24 px — Primary body copy.
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16, // 1.5
  );

  /// 14 px, Regular 400, line-height 22 px — Secondary body, list items.
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 22 / 14, // ~1.571
  );

  /// 12 px, Regular 400, line-height 18 px — Captions, timestamps.
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 18 / 12, // 1.5
  );

  // ─── Label ─────────────────────────────────────────────────────────

  /// 16 px, SemiBold 600, line-height 24 px — Buttons, tabs.
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24 / 16, // 1.5
    letterSpacing: 0.2,
  );

  /// 14 px, SemiBold 600, line-height 20 px — Chips, small buttons.
  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14, // ~1.429
    letterSpacing: 0.2,
  );

  /// 12 px, Medium 500, line-height 16 px — Badges, tags.
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12, // ~1.333
    letterSpacing: 0.2,
  );

  // ─── Special styles ────────────────────────────────────────────────

  /// ALL-CAPS label variant (e.g. section labels).
  static const TextStyle labelAllCaps = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 1.0,
  );

  /// Verse text (italic body large).
  static TextStyle verseText = bodyLarge.copyWith(
    fontStyle: FontStyle.italic,
    color: Colors.white,
  );

  /// Body large with SemiBold weight (sermon titles, etc.).
  static TextStyle bodyLargeSemiBold = bodyLarge.copyWith(
    fontWeight: FontWeight.w600,
  );
}
