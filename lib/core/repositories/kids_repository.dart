import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/kids.dart';
import '../services/api_client.dart';

// ──────────────────────────────────────────────────────────────────────────────
// KIDS REPOSITORY
// ──────────────────────────────────────────────────────────────────────────────

class KidsRepository {
  KidsRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;
  final Dio _dio;

  Future<List<KidsChild>> fetchChildren() async {
    final res = await _dio.get(Endpoints.kidsChildren);
    final list = (res.data as Map)['data'] as List? ?? [];
    return list
        .map((e) => KidsChild.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<KidsRoom>> fetchRooms() async {
    final res = await _dio.get(Endpoints.kidsRooms);
    final list = (res.data as Map)['data'] as List? ?? [];
    return list
        .map((e) => KidsRoom.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<KidsChild> registerChild({
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    String? allergies,
  }) async {
    final res = await _dio.post(
      Endpoints.kidsChildren,
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth,
        if (allergies != null && allergies.isNotEmpty) 'allergies': allergies,
      },
    );
    return KidsChild.fromJson(
        (res.data as Map)['data'] as Map<String, dynamic>);
  }

  Future<KidsCheckInResult> checkIn({
    required String childId,
    required String roomId,
  }) async {
    final res = await _dio.post(
      Endpoints.kidsCheckin,
      data: {'childId': childId, 'roomId': roomId},
    );
    return KidsCheckInResult.fromJson(
        (res.data as Map)['data'] as Map<String, dynamic>);
  }
}
