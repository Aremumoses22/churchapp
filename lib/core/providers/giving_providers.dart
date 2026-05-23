import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/giving.dart';
import '../repositories/giving_repository.dart';

// ──────────────────────────────────────────────────────────────────────────────
// GIVING PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

final givingRepositoryProvider = Provider<GivingRepository>((_) {
  return GivingRepository();
});

// ── API async providers ───────────────────────────────────────────────────────

final givingCategoriesProvider =
    FutureProvider<List<GivingCategory>>((ref) async {
  final res = await ref.watch(givingRepositoryProvider).getCategories();
  if (!res.success) throw Exception(res.message);
  return res.data ?? [];
});

final givingSummaryProvider = FutureProvider<GivingSummary?>((ref) async {
  final res = await ref.watch(givingRepositoryProvider).getSummary();
  return res.success ? res.data : null;
});

final givingCampaignsProvider =
    FutureProvider<List<GivingCampaign>>((ref) async {
  final res = await ref.watch(givingRepositoryProvider).getCampaigns();
  if (!res.success) throw Exception(res.message);
  return res.data;
});

final givingCampaignProvider =
    FutureProvider.family<GivingCampaign?, String>((ref, id) async {
  final res = await ref.watch(givingRepositoryProvider).getCampaign(id);
  if (!res.success) throw Exception(res.message);
  return res.data;
});

final givingPledgesProvider = FutureProvider<List<Pledge>>((ref) async {
  final res = await ref.watch(givingRepositoryProvider).getPledges();
  if (!res.success) throw Exception(res.message);
  return res.data;
});

final givingPaymentMethodsProvider =
    FutureProvider<List<PaymentMethod>>((ref) async {
  final res = await ref.watch(givingRepositoryProvider).getPaymentMethods();
  if (!res.success) throw Exception(res.message);
  return res.data ?? [];
});

final givingRecurringProvider =
    FutureProvider<List<RecurringDonation>>((ref) async {
  final res = await ref.watch(givingRepositoryProvider).getRecurring();
  if (!res.success) throw Exception(res.message);
  return res.data ?? [];
});

final givingHistoryProvider = FutureProvider<List<Donation>>((ref) async {
  final res = await ref.watch(givingRepositoryProvider).getHistory();
  if (!res.success) throw Exception(res.message);
  return res.data;
});

final givingReceiptProvider =
    FutureProvider.family<Donation?, String>((ref, id) async {
  final res = await ref.watch(givingRepositoryProvider).getReceipt(id);
  return res.success ? res.data : null;
});

// ── Giving form state (local UI only) ────────────────────────────────────────

class GivingState {
  const GivingState({
    this.selectedCategoryIndex = 0,
    this.selectedAmount,
    this.isCustom = false,
    this.customAmount = '',
    this.frequency = 0,
    this.paymentMethod = 0,
    this.reminderEnabled = false,
    this.reminderFrequency = 0,
  });

  final int selectedCategoryIndex;
  final int? selectedAmount;
  final bool isCustom;
  final String customAmount;
  final int frequency;
  final int paymentMethod;
  final bool reminderEnabled;
  final int reminderFrequency;

  int get currentAmount {
    if (isCustom) return int.tryParse(customAmount) ?? 0;
    return selectedAmount ?? 0;
  }

  GivingState copyWith({
    int? selectedCategoryIndex,
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
      selectedCategoryIndex:
          selectedCategoryIndex ?? this.selectedCategoryIndex,
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

class GivingNotifier extends StateNotifier<GivingState> {
  GivingNotifier() : super(const GivingState());

  void selectCategory(int index) =>
      state = state.copyWith(selectedCategoryIndex: index);

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

  void reset() => state = const GivingState();
}

final givingNotifierProvider =
    StateNotifierProvider<GivingNotifier, GivingState>((_) => GivingNotifier());
