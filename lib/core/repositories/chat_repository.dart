import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/chat.dart';
import '../services/api_client.dart';

// ──────────────────────────────────────────────────────────────────────────────
// CHAT REPOSITORY — talks to /chat/* endpoints
// ──────────────────────────────────────────────────────────────────────────────

class ChatRepository {
  ChatRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<List<ChatPreview>> fetchConversations() async {
    final res = await _dio.get(Endpoints.chatConversations);
    final raw = res.data as Map<String, dynamic>;
    final list = (raw['conversations'] as List?) ?? (raw['data'] as List?) ?? [];
    return list
        .map((e) => ChatPreview.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ChatMessage>> fetchMessages(
    String id, {
    required String currentUserId,
    int page = 1,
    int limit = 50,
  }) async {
    final res = await _dio.get(
      Endpoints.chatMessages(id),
      queryParameters: {'page': page, 'limit': limit},
    );
    final raw = res.data as Map<String, dynamic>;
    final list = (raw['messages'] as List?) ?? (raw['data'] as List?) ?? [];
    return list
        .map((e) => ChatMessage.fromJson(
              e as Map<String, dynamic>,
              currentUserId: currentUserId,
            ))
        .toList();
  }

  Future<ChatMessage?> sendMessage(
    String id,
    String content, {
    required String currentUserId,
  }) async {
    final res = await _dio.post(
      Endpoints.chatMessages(id),
      data: {'content': content},
    );
    final raw = res.data as Map<String, dynamic>;
    final msgData = raw['message'] as Map<String, dynamic>?
        ?? raw['data'] as Map<String, dynamic>?;
    return msgData != null
        ? ChatMessage.fromJson(msgData, currentUserId: currentUserId)
        : null;
  }

  Future<void> markAsRead(String id) async {
    await _dio.put(Endpoints.chatMarkRead(id));
  }

  Future<void> togglePin(String id) async {
    await _dio.put(Endpoints.chatPin(id));
  }

  Future<void> toggleMute(String id) async {
    await _dio.put(Endpoints.chatMute(id));
  }

  Future<String> createConversation({
    required String type,
    required List<String> memberIds,
    String? name,
  }) async {
    final res = await _dio.post(
      Endpoints.chatConversations,
      data: {
        'type': type,
        'memberIds': memberIds,
        if (name != null) 'name': name,
      },
    );
    final raw = res.data as Map<String, dynamic>;
    final convo = (raw['conversation'] as Map<String, dynamic>?) ??
        (raw['data'] as Map<String, dynamic>?) ??
        {};
    return convo['id'] as String? ?? '';
  }
}
