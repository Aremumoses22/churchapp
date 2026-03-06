import 'package:flutter/material.dart';

/// Elevation & shadow tokens (4 levels).
abstract final class AppShadows {
  // ─── Light mode shadows ────────────────────────────────────────────

  /// Extra-small – input focus rings.
  static const List<BoxShadow> xs = [
    BoxShadow(
      color: Color(0x0D000000), // rgba(0,0,0,0.05)
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  /// Small – default cards.
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x14000000), // rgba(0,0,0,0.08)
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  /// Medium – elevated cards, nav bar.
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1F000000), // rgba(0,0,0,0.12)
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
  ];

  /// Large – modals, bottom sheets.
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x2E000000), // rgba(0,0,0,0.18)
      offset: Offset(0, 8),
      blurRadius: 32,
    ),
  ];

  // ─── Dark mode shadows (50 % reduced opacity) ─────────────────────

  static const List<BoxShadow> xsDark = [
    BoxShadow(
      color: Color(0x07000000),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static const List<BoxShadow> smDark = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  static const List<BoxShadow> mdDark = [
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
  ];

  static const List<BoxShadow> lgDark = [
    BoxShadow(
      color: Color(0x17000000),
      offset: Offset(0, 8),
      blurRadius: 32,
    ),
  ];

  // ─── Upward shadow (bottom nav) ────────────────────────────────────

  /// Medium shadow cast **upward** — used on the bottom navigation bar.
  static const List<BoxShadow> mdUp = [
    BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, -4),
      blurRadius: 16,
    ),
  ];

  static const List<BoxShadow> mdUpDark = [
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, -4),
      blurRadius: 16,
    ),
  ];
}
