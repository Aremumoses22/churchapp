import 'dart:async';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/chat.dart';
import '../repositories/chat_repository.dart';
import '../theme/app_colors.dart';

// ──────────────────────────────────────────────────────────────────────────────
// CHAT PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

final chatRepositoryProvider = Provider<ChatRepository>((_) {
  return MockChatRepository();
});

// ── Chat List State ──────────────────────────────────────────────────────────

class ChatListState {
  const ChatListState({
    this.chats = const [],
    this.filterIndex = 0,
    this.searchQuery = '',
  });

  final List<ChatPreview> chats;
  final int filterIndex; // 0=All, 1=Direct, 2=Groups
  final String searchQuery;

  ChatListState copyWith({
    List<ChatPreview>? chats,
    int? filterIndex,
    String? searchQuery,
  }) {
    return ChatListState(
      chats: chats ?? this.chats,
      filterIndex: filterIndex ?? this.filterIndex,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<ChatPreview> get filteredChats {
    var list = chats;
    // Filter by type
    if (filterIndex == 1) list = list.where((c) => !c.isGroup).toList();
    if (filterIndex == 2) list = list.where((c) => c.isGroup).toList();
    // Search
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list
          .where((c) =>
              c.name.toLowerCase().contains(q) ||
              c.lastMessage.toLowerCase().contains(q))
          .toList();
    }
    // Sort: pinned first
    list.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return 0;
    });
    return list;
  }
}

class ChatListNotifier extends StateNotifier<ChatListState> {
  ChatListNotifier(this._repo) : super(const ChatListState()) {
    _init();
  }
  final ChatRepository _repo;

  void _init() {
    state = state.copyWith(chats: _repo.getChats());
  }

  void setFilter(int index) => state = state.copyWith(filterIndex: index);
  void setSearchQuery(String q) => state = state.copyWith(searchQuery: q);

  void togglePin(String chatId) {
    final updated = state.chats.map((c) {
      if (c.id == chatId) return c.copyWith(isPinned: !c.isPinned);
      return c;
    }).toList();
    state = state.copyWith(chats: updated);
  }

  void toggleMute(String chatId) {
    final updated = state.chats.map((c) {
      if (c.id == chatId) return c.copyWith(isMuted: !c.isMuted);
      return c;
    }).toList();
    state = state.copyWith(chats: updated);
  }

  void deleteChat(String chatId) {
    state =
        state.copyWith(chats: state.chats.where((c) => c.id != chatId).toList());
  }
}

final chatListNotifierProvider =
    StateNotifierProvider<ChatListNotifier, ChatListState>((ref) {
  return ChatListNotifier(ref.watch(chatRepositoryProvider));
});

// ── Conversation State ───────────────────────────────────────────────────────

class ConversationState {
  const ConversationState({
    this.messages = const [],
    this.isTyping = false,
    this.meta,
  });

  final List<ChatMessage> messages;
  final bool isTyping;
  final ChatMeta? meta;

  ConversationState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    ChatMeta? meta,
  }) {
    return ConversationState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      meta: meta ?? this.meta,
    );
  }
}

class ConversationNotifier extends StateNotifier<ConversationState> {
  ConversationNotifier(this._repo, this.chatId)
      : super(const ConversationState()) {
    _init();
  }
  final ChatRepository _repo;
  final String chatId;
  Timer? _replyTimer;

  void _init() {
    state = state.copyWith(
      messages: _repo.getMessages(chatId),
      meta: _repo.getChatMeta(chatId),
    );
  }

  void sendMessage(String text) {
    final msg = ChatMessage(
      id: 'm${state.messages.length + 1}',
      text: text,
      sender: 'You',
      senderInitials: 'ME',
      senderColor: AppColors.primary,
      time: _formatTime(),
      isMe: true,
    );
    state = state.copyWith(messages: [...state.messages, msg]);

    // Simulate auto-reply
    _replyTimer?.cancel();
    state = state.copyWith(isTyping: true);
    _replyTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final reply = _generateReply(text);
      final meta = state.meta;
      final replyMsg = ChatMessage(
        id: 'm${state.messages.length + 1}',
        text: reply,
        sender: meta?.name ?? 'Friend',
        senderInitials: meta?.initials ?? '??',
        senderColor: meta?.color ?? const Color(0xFF059669),
        time: _formatTime(),
        isMe: false,
      );
      state = state.copyWith(
        messages: [...state.messages, replyMsg],
        isTyping: false,
      );
    });
  }

  String _formatTime() {
    final now = DateTime.now();
    final h = now.hour > 12 ? now.hour - 12 : now.hour;
    final m = now.minute.toString().padLeft(2, '0');
    final p = now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $p';
  }

  String _generateReply(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('pray')) {
      return 'I will definitely be praying for you. God is faithful! 🙏';
    }
    if (lower.contains('thank')) {
      return 'You are so welcome! That is what the church family is for. ❤️';
    }
    if (lower.contains('hello') || lower.contains('hi')) {
      return 'Hey there! Great to hear from you. How are you doing?';
    }
    if (lower.contains('sunday') || lower.contains('service')) {
      return 'Can not wait for Sunday! It is going to be a powerful service. See you there! 🙌';
    }
    if (lower.contains('bible') || lower.contains('scripture')) {
      return 'I love diving into the Word. Have you tried the reading plan in the app?';
    }
    return 'That is wonderful to hear! God is doing amazing things. 🙏';
  }

  @override
  void dispose() {
    _replyTimer?.cancel();
    super.dispose();
  }
}

final conversationNotifierProvider = StateNotifierProvider.family<
    ConversationNotifier, ConversationState, String>((ref, chatId) {
  return ConversationNotifier(ref.watch(chatRepositoryProvider), chatId);
});
