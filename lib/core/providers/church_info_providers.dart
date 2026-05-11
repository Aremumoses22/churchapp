import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/church_info.dart';
import '../repositories/church_info_repository.dart';

// ──────────────────────────────────────────────────────────────────────────────
// CHURCH INFO PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

final churchInfoRepositoryProvider = Provider<ApiChurchInfoRepository>((_) {
  return ApiChurchInfoRepository();
});

final churchAboutProvider = FutureProvider<ChurchInfo?>((ref) async {
  final res = await ref.watch(churchInfoRepositoryProvider).getAbout();
  return res.success ? res.data : null;
});

final churchStaffProvider = FutureProvider<List<StaffMember>>((ref) async {
  final res = await ref.watch(churchInfoRepositoryProvider).getStaff();
  return res.data ?? [];
});

final churchCampusesProvider = FutureProvider<List<Campus>>((ref) async {
  final res = await ref.watch(churchInfoRepositoryProvider).getCampuses();
  return res.data ?? [];
});

final churchFaqsProvider = FutureProvider<List<ChurchFaq>>((ref) async {
  final res = await ref.watch(churchInfoRepositoryProvider).getFaqs();
  return res.data ?? [];
});

// ── Contact form notifier ─────────────────────────────────────────────────────

class ContactFormState {
  const ContactFormState({
    this.isLoading = false,
    this.success = false,
    this.error,
  });

  final bool isLoading;
  final bool success;
  final String? error;
}

class ContactFormNotifier extends Notifier<ContactFormState> {
  @override
  ContactFormState build() => const ContactFormState();

  Future<void> send(String subject, String message) async {
    state = const ContactFormState(isLoading: true);
    final res = await ref
        .read(churchInfoRepositoryProvider)
        .sendContact(subject, message);
    if (res.success) {
      state = const ContactFormState(success: true);
    } else {
      state = ContactFormState(error: res.message);
    }
  }

  void reset() => state = const ContactFormState();
}

final contactFormProvider =
    NotifierProvider<ContactFormNotifier, ContactFormState>(
  ContactFormNotifier.new,
);
