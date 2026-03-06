import 'package:flutter/material.dart';

/// All color tokens for the Church App design system.
///
/// Never hardcode hex values in widgets — always reference these constants.
abstract final class AppColors {
  // ─── Primary Palette ───────────────────────────────────────────────
  /// App bar, CTAs, active nav tab, headers.
  static const Color primary = Color(0xFF1E3A8A);

  /// Hover / pressed state of primary.
  static const Color primaryLight = Color(0xFF2D4EAF);

  /// Deep tones, dark-mode primary.
  static const Color primaryDark = Color(0xFF152B6B);

  /// Accents, badges, giving icon, premium highlights.
  static const Color gold = Color(0xFFFBBF24);

  /// Gold hover state.
  static const Color goldLight = Color(0xFFFCD34D);

  // ─── Secondary Palette ─────────────────────────────────────────────
  /// Card backgrounds, tinted surfaces.
  static const Color skyLight = Color(0xFFE0F2FE);

  /// Main background (light mode).
  static const Color warmWhite = Color(0xFFFAFAFA);

  /// Cards, modals, sheets.
  static const Color surface = Color(0xFFFFFFFF);

  // ─── Text Colors ───────────────────────────────────────────────────
  /// Headings, main body text.
  static const Color textPrimary = Color(0xFF111827);

  /// Subtitles, captions, placeholders.
  static const Color textSecondary = Color(0xFF6B7280);

  /// Disabled inputs, inactive labels.
  static const Color textDisabled = Color(0xFF9CA3AF);

  /// Text on dark / primary backgrounds.
  static const Color textInverse = Color(0xFFFFFFFF);

  // ─── Semantic Colors ───────────────────────────────────────────────
  /// Success states, giving confirmed.
  static const Color success = Color(0xFF10B981);

  /// Errors, destructive actions.
  static const Color error = Color(0xFFEF4444);

  /// Warnings, reminder badges.
  static const Color warning = Color(0xFFF59E0B);

  /// Info banners, tooltips.
  static const Color info = Color(0xFF3B82F6);

  // ─── Dark Mode Overrides ───────────────────────────────────────────
  /// Dark mode background.
  static const Color bgDark = Color(0xFF0B1220);

  /// Dark mode card surface.
  static const Color cardDark = Color(0xFF111827);

  /// Dark mode dividers / borders.
  static const Color borderDark = Color(0xFF1F2937);

  /// Dark mode skyLight replacement (slate-800).
  static const Color skyDark = Color(0xFF1E293B);

  /// Dark mode text primary.
  static const Color textPrimaryDark = Color(0xFFF9FAFB);

  /// Dark mode text secondary.
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  // ─── Neutral / Utility ─────────────────────────────────────────────
  /// Light divider / border.
  static const Color divider = Color(0xFFF3F4F6);

  /// Input default border (light mode).
  static const Color inputBorder = Color(0xFFE5E7EB);

  /// Inactive page dot / chip background.
  static const Color inactive = Color(0xFFD1D5DB);

  /// Search bar / input fill (light).
  static const Color inputFill = Color(0xFFF3F4F6);
}
