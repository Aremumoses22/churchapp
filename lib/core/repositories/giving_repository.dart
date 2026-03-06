import 'dart:ui';

import '../models/giving.dart';

// ──────────────────────────────────────────────────────────────────────────────
// GIVING REPOSITORY
// ──────────────────────────────────────────────────────────────────────────────

abstract class GivingRepository {
  List<String> getCategories();
  List<int> getAmountPresets();
  List<SavedCard> getSavedCards();
}

class MockGivingRepository implements GivingRepository {
  @override
  List<String> getCategories() =>
      const ['Tithe', 'Offering', 'Building Fund', 'Missions', 'Special Seed'];

  @override
  List<int> getAmountPresets() => const [1000, 5000, 10000, 50000];

  @override
  List<SavedCard> getSavedCards() => const [
        SavedCard(
            brand: 'Visa', last4: '4532', color: Color(0xFF1A1F71)),
        SavedCard(
            brand: 'Mastercard', last4: '8791', color: Color(0xFFEB001B)),
      ];
}
