import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import '../models/live_service.dart';
import '../services/api_client.dart';

// ──────────────────────────────────────────────────────────────────────────────
// LIVE SERVICE PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

final liveCurrentProvider = FutureProvider<LiveCurrent>((ref) async {
  final res = await ApiClient.instance.dio.get(Endpoints.liveCurrent);
  final raw = res.data as Map<String, dynamic>;
  final data = (raw['data'] as Map<String, dynamic>?) ?? raw;
  return LiveCurrent.fromJson(data);
});
