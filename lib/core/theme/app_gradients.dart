import 'package:flutter/material.dart';

/// Pre-defined gradient tokens for the Church App.
abstract final class AppGradients {
  /// Hero gradient — Home screen header.
  ///
  /// Deep Royal Blue → Blue 700, 135° angle.
  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E3A8A), // Deep Royal Blue
      Color(0xFF1E40AF), // Blue 700
    ],
  );

  /// Gold shimmer — Giving screen, donation card.
  static const LinearGradient goldShimmer = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFFBBF24), // Gold
      Color(0xFFF59E0B), // Amber-500
    ],
  );

  /// Verse card gradient — Today's verse overlay.
  ///
  /// Bottom → Top transparency.
  static const LinearGradient verseCard = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Color(0xD91E3A8A), // rgba(30,58,138,0.85)
      Color(0x661E3A8A), // rgba(30,58,138,0.40)
    ],
  );

  /// Verse card gradient for dark mode — slightly lighter.
  static const LinearGradient verseCardDark = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Color(0xD91E3A8A),
      Color(0x662563EB), // Slightly lighter blue
    ],
  );

  /// Hero gradient for dark mode.
  static const LinearGradient heroDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E3A8A),
      Color(0xFF2563EB), // Slightly lighter blue
    ],
  );

  /// Primary to transparent — useful for image overlays.
  static const LinearGradient primaryOverlay = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Color(0xCC1E3A8A), // 80 % opacity
      Colors.transparent,
    ],
  );
}
