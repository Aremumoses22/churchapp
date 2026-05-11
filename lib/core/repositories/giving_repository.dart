import 'dart:ui';

import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/giving.dart';
import '../services/api_client.dart';

// ──────────────────────────────────────────────────────────────────────────────
// GIVING REPOSITORY
//
// Covers GET/POST /giving/* endpoints
// See API_INTEGRATION_GUIDE.md § 10
// ──────────────────────────────────────────────────────────────────────────────

abstract class GivingRepository {
  // Legacy form helpers (kept for mock compatibility)
  List<String> getFormCategories();
  List<int> getAmountPresets();
  List<SavedCard> getSavedCards();
}

class MockGivingRepository implements GivingRepository {
  @override
  List<String> getFormCategories() =>
      const ['Tithe', 'Offering', 'Building Fund', 'Missions', 'Special Seed'];

  @override
  List<int> getAmountPresets() => const [1000, 5000, 10000, 50000];

  @override
  List<SavedCard> getSavedCards() => const [
        SavedCard(brand: 'Visa', last4: '4532', color: Color(0xFF1A1F71)),
        SavedCard(brand: 'Mastercard', last4: '8791', color: Color(0xFFEB001B)),
      ];
}

// ── Real API repository ───────────────────────────────────────────────────────

class ApiGivingRepository implements GivingRepository {
  ApiGivingRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  // Legacy helpers — returns empty list so UI can fallback to API providers
  @override
  List<String> getFormCategories() => [];
  @override
  List<int> getAmountPresets() => const [1000, 5000, 10000, 50000];
  @override
  List<SavedCard> getSavedCards() => [];

  // ── Categories ────────────────────────────────────────────────────────────
  Future<ApiResponse<List<GivingCategory>>> getCategories() async {
    try {
      final res = await _dio.get(Endpoints.givingCategories);
      final raw = res.data as Map<String, dynamic>;
      final list = (raw['data'] as List?) ?? [];
      return ApiResponse<List<GivingCategory>>(
        success: raw['success'] as bool? ?? true,
        message: raw['message'] as String? ?? '',
        data: list
            .map((e) => GivingCategory.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return _err(e);
    }
  }

  // ── Summary ───────────────────────────────────────────────────────────────
  Future<ApiResponse<GivingSummary>> getSummary() async {
    try {
      final res = await _dio.get(Endpoints.givingSummary);
      return ApiResponse<GivingSummary>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => GivingSummary.fromJson(d as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _err(e);
    }
  }

  // ── Donate ────────────────────────────────────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> donate({
    required double amount,
    required String categoryId,
    required String paymentMethod,
    String? campaignId,
    bool isAnonymous = false,
    String? notes,
  }) async {
    try {
      final res = await _dio.post(Endpoints.givingDonate, data: {
        'amount': amount,
        'categoryId': categoryId,
        'paymentMethod': paymentMethod,
        if (campaignId != null) 'campaignId': campaignId,
        'isAnonymous': isAnonymous,
        if (notes != null) 'notes': notes,
      });
      return ApiResponse<Map<String, dynamic>>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => d as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _err(e);
    }
  }

  // ── Verify ────────────────────────────────────────────────────────────────
  Future<ApiResponse<void>> verifyTransaction(String reference) async {
    try {
      final res = await _dio
          .post(Endpoints.givingVerify, data: {'reference': reference});
      return ApiResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return _err(e);
    }
  }

  // ── History ───────────────────────────────────────────────────────────────
  Future<PaginatedResponse<Donation>> getHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get(
        Endpoints.givingHistory,
        queryParameters: {'page': page, 'limit': limit},
      );
      return PaginatedResponse<Donation>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: Donation.fromJson,
      );
    } on DioException catch (_) {
      return const PaginatedResponse(
        success: false,
        message: 'Failed to load history',
        data: [],
        meta: PaginationMeta(page: 1, limit: 20, total: 0, totalPages: 0),
      );
    }
  }

  // ── Payment Methods ───────────────────────────────────────────────────────
  Future<ApiResponse<List<PaymentMethod>>> getPaymentMethods() async {
    try {
      final res = await _dio.get(Endpoints.givingPaymentMethods);
      final raw = res.data as Map<String, dynamic>;
      final list = (raw['data'] as List?) ?? [];
      return ApiResponse<List<PaymentMethod>>(
        success: raw['success'] as bool? ?? true,
        message: raw['message'] as String? ?? '',
        data: list
            .map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return _err(e);
    }
  }

  Future<ApiResponse<void>> deletePaymentMethod(String id) async {
    try {
      final res =
          await _dio.delete(Endpoints.givingPaymentMethod(id));
      return ApiResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return _err(e);
    }
  }

  // ── Campaigns ─────────────────────────────────────────────────────────────
  Future<PaginatedResponse<GivingCampaign>> getCampaigns({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get(
        Endpoints.givingCampaigns,
        queryParameters: {'page': page, 'limit': limit},
      );
      return PaginatedResponse<GivingCampaign>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: GivingCampaign.fromJson,
      );
    } on DioException catch (_) {
      return const PaginatedResponse(
        success: false,
        message: 'Failed to load campaigns',
        data: [],
        meta: PaginationMeta(page: 1, limit: 20, total: 0, totalPages: 0),
      );
    }
  }

  Future<ApiResponse<GivingCampaign>> getCampaign(String id) async {
    try {
      final res = await _dio.get(Endpoints.givingCampaign(id));
      return ApiResponse<GivingCampaign>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: (d) => GivingCampaign.fromJson(d as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _err(e);
    }
  }

  // ── Pledges ───────────────────────────────────────────────────────────────
  Future<PaginatedResponse<Pledge>> getPledges({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get(
        Endpoints.givingPledges,
        queryParameters: {'page': page, 'limit': limit},
      );
      return PaginatedResponse<Pledge>.fromJson(
        res.data as Map<String, dynamic>,
        fromJsonT: Pledge.fromJson,
      );
    } on DioException catch (_) {
      return const PaginatedResponse(
        success: false,
        message: 'Failed to load pledges',
        data: [],
        meta: PaginationMeta(page: 1, limit: 20, total: 0, totalPages: 0),
      );
    }
  }

  Future<ApiResponse<void>> createPledge({
    required String campaignId,
    required double totalAmount,
    String? endDate,
  }) async {
    try {
      final res = await _dio.post(Endpoints.givingPledges, data: {
        'campaignId': campaignId,
        'totalAmount': totalAmount,
        if (endDate != null) 'endDate': endDate,
      });
      return ApiResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return _err(e);
    }
  }

  Future<ApiResponse<void>> payPledge({
    required String pledgeId,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      final res = await _dio.post(
        Endpoints.givingPledgePay(pledgeId),
        data: {'amount': amount, 'paymentMethod': paymentMethod},
      );
      return ApiResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return _err(e);
    }
  }

  Future<ApiResponse<void>> cancelPledge(String id) async {
    try {
      final res = await _dio.delete(Endpoints.givingPledgeItem(id));
      return ApiResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return _err(e);
    }
  }

  // ── Recurring ─────────────────────────────────────────────────────────────
  Future<ApiResponse<List<RecurringDonation>>> getRecurring() async {
    try {
      final res = await _dio.get(Endpoints.givingRecurring);
      final raw = res.data as Map<String, dynamic>;
      final list = (raw['data'] as List?) ?? [];
      return ApiResponse<List<RecurringDonation>>(
        success: raw['success'] as bool? ?? true,
        message: raw['message'] as String? ?? '',
        data: list
            .map((e) =>
                RecurringDonation.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return _err(e);
    }
  }

  Future<ApiResponse<void>> cancelRecurring(String id) async {
    try {
      final res = await _dio.delete(Endpoints.givingRecurringItem(id));
      return ApiResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return _err(e);
    }
  }

  ApiResponse<T> _err<T>(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) return ApiResponse<T>.fromJson(data);
    return ApiResponse<T>(
      success: false,
      message: e.message ?? 'An error occurred',
    );
  }
}
