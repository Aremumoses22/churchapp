import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/giving.dart';
import '../repositories/giving_repository.dart';

// ──────────────────────────────────────────────────────────────────────────────
// GIVING PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

final givingRepositoryProvider = Provider<GivingRepository>((_) {
  return MockGivingRepository();
});

// ── State ────────────────────────────────────────────────────────────────────

class GivingState {
  const GivingState({
    this.categories = const [],
    this.amountPresets = const [],
    this.savedCards = const [],
    this.selectedCategory = 0,
    this.selectedAmount,
    this.isCustom = false,
    this.customAmount = '',
    this.frequency = 0,
    this.paymentMethod = 0,
    this.reminderEnabled = false,
    this.reminderFrequency = 0,
  });

  final List<String> categories;
  final List<int> amountPresets;
  final List<SavedCard> savedCards;
  final int selectedCategory;
  final int? selectedAmount;
  final bool isCustom;
  final String customAmount;
  final int frequency; // 0=One-time, 1=Weekly, 2=Monthly
  final int paymentMethod;
  final bool reminderEnabled;
  final int reminderFrequency;

  int get currentAmount {
    if (isCustom) return int.tryParse(customAmount) ?? 0;
    return selectedAmount ?? 0;
  }

  GivingState copyWith({
    List<String>? categories,
    List<int>? amountPresets,
    List<SavedCard>? savedCards,
    int? selectedCategory,
    int? selectedAmount,
    bool clearSelectedAmount = false,
    bool? isCustom,
    String? customAmount,
    int? frequency,
    int? paymentMethod,
    bool? reminderEnabled,
    int? reminderFrequency,
  }) {
    return GivingState(
      categories: categories ?? this.categories,
      amountPresets: amountPresets ?? this.amountPresets,
      savedCards: savedCards ?? this.savedCards,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedAmount: clearSelectedAmount
          ? null
          : (selectedAmount ?? this.selectedAmount),
      isCustom: isCustom ?? this.isCustom,
      customAmount: customAmount ?? this.customAmount,
      frequency: frequency ?? this.frequency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderFrequency: reminderFrequency ?? this.reminderFrequency,
    );
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class GivingNotifier extends StateNotifier<GivingState> {
  GivingNotifier(this._repo) : super(const GivingState()) {
    _init();
  }
  final GivingRepository _repo;

  void _init() {
    state = state.copyWith(
      categories: _repo.getCategories(),
      amountPresets: _repo.getAmountPresets(),
      savedCards: _repo.getSavedCards(),
    );
  }

  void selectCategory(int index) =>
      state = state.copyWith(selectedCategory: index);

  void selectAmount(int amount) => state = state.copyWith(
        selectedAmount: amount,
        isCustom: false,
      );

  void enableCustom() =>
      state = state.copyWith(isCustom: true, clearSelectedAmount: true);

  void setCustomAmount(String val) =>
      state = state.copyWith(customAmount: val);

  void setFrequency(int f) => state = state.copyWith(frequency: f);

  void setPaymentMethod(int m) => state = state.copyWith(paymentMethod: m);

  void toggleReminder() =>
      state = state.copyWith(reminderEnabled: !state.reminderEnabled);

  void setReminderFrequency(int f) =>
      state = state.copyWith(reminderFrequency: f);

  void reset() => state = GivingState(
        categories: _repo.getCategories(),
        amountPresets: _repo.getAmountPresets(),
        savedCards: _repo.getSavedCards(),
      );
}

final givingNotifierProvider =
    StateNotifierProvider<GivingNotifier, GivingState>((ref) {
  return GivingNotifier(ref.watch(givingRepositoryProvider));
});
