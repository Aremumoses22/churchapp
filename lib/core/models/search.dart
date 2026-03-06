import 'dart:ui';
import 'package:flutter/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SEARCH MODEL
// ──────────────────────────────────────────────────────────────────────────────

class SearchItem {
  const SearchItem({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.color,
    required this.route,
  });

  final String title;
  final String subtitle;
  final String category;
  final IconData icon;
  final Color color;
  final String route;
}
