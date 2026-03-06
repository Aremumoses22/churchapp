import 'dart:ui';

// ──────────────────────────────────────────────────────────────────────────────
// GIVING MODELS
// ──────────────────────────────────────────────────────────────────────────────

class SavedCard {
  const SavedCard({
    required this.brand,
    required this.last4,
    required this.color,
  });

  final String brand;
  final String last4;
  final Color color;
}
