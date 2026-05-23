import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/home_feed.dart';
import '../repositories/home_feed_repository.dart';

// ──────────────────────────────────────────────────────────────────────────────
// HOME FEED PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

final homeFeedRepositoryProvider = Provider<HomeFeedRepository>((_) {
  return HomeFeedRepository();
});

final homeFeedProvider = FutureProvider<HomeFeed?>((ref) async {
  final res = await ref.watch(homeFeedRepositoryProvider).getFeed();
  return res.success ? res.data : null;
});
