import 'package:flutter/material.dart';

/// Border-radius tokens for the Church App design system.
abstract final class AppRadius {
  // ─── Raw values ────────────────────────────────────────────────────
  /// 4 px – Chips, small tags.
  static const double xs = 4;

  /// 8 px – Input fields, small buttons.
  static const double sm = 8;

  /// 12 px – Buttons, small cards.
  static const double md = 12;

  /// 16 px – Standard cards.
  static const double lg = 16;

  /// 24 px – Feature cards, hero cards.
  static const double xl = 24;

  /// 999 px – Pills, avatars, FABs.
  static const double full = 999;

  // ─── BorderRadius helpers ──────────────────────────────────────────
  static final BorderRadius borderRadiusXs = BorderRadius.circular(xs);
  static final BorderRadius borderRadiusSm = BorderRadius.circular(sm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(md);
  static final BorderRadius borderRadiusLg = BorderRadius.circular(lg);
  static final BorderRadius borderRadiusXl = BorderRadius.circular(xl);
  static final BorderRadius borderRadiusFull = BorderRadius.circular(full);

  /// Top-only xl radius (bottom sheets, overlapping cards).
  static final BorderRadius borderRadiusXlTop = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );

  /// Bottom-only xl radius (hero section curved bottom).
  static final BorderRadius borderRadiusXlBottom = BorderRadius.only(
    bottomLeft: Radius.circular(xl),
    bottomRight: Radius.circular(xl),
  );
}
