import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/chat.dart';
import '../repositories/chat_repository.dart';
import '../theme/app_colors.dart';
import 'auth_providers.dart';

// ──────────────────────────────────────────────────────────────────────────────
// CHAT PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

final chatRepositoryProvider = Provider<ChatRepository>((_) {
  return ChatRepository();
});

// ── Chat List State ──────────────────────────────────────────────────────────

class ChatListState {
  const ChatListState({
    this.chats = const [],
    this.filterIndex = 0,
    this.searchQuery = '',
    this.isLoading = true,
    this.error,
  });

  final List<ChatPreview> chats;
  final int filterIndex; // 0=All, 1=Direct, 2=Groups
  final String searchQuery;
  final bool isLoading;
  final String? error;

  ChatListState copyWith({
    List<ChatPreview>? chats,
    int? filterIndex,
    String? searchQuery,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ChatListState(
      chats: chats ?? this.chats,
      filterIndex: filterIndex ?? this.filterIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  List<ChatPreview> get filteredChats {
    var list = chats;
    if (filterIndex == 1) list = list.where((c) => !c.isGroup).toList();
    if (filterIndex == 2) list = list.where((c) => c.isGroup).toList();
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list
          .where((c) =>
              c.name.toLowerCase().contains(q) ||
              c.lastMessage.toLowerCase().contains(q))
          .toList();
    }
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
    _load();
  }

  final ChatRepository _repo;

  Future<void> _load() async {
    try {
      final chats = await _repo.fetchConversations();
      if (mounted) state = state.copyWith(chats: chats, isLoading: false);
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load conversations',
        );
      }
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _load();
  }

  void setFilter(int index) => state = state.copyWith(filterIndex: index);
  void setSearchQuery(String q) => state = state.copyWith(searchQuery: q);

  void togglePin(String chatId) {
    final updated = state.chats.map((c) {
      if (c.id == chatId) return c.copyWith(isPinned: !c.isPinned);
      return c;
    }).toList();
    state = state.copyWith(chats: updated);
    _repo.togglePin(chatId);
  }

  void toggleMute(String chatId) {
    final updated = state.chats.map((c) {
      if (c.id == chatId) return c.copyWith(isMuted: !c.isMuted);
      return c;
    }).toList();
    state = state.copyWith(chats: updated);
    _repo.toggleMute(chatId);
  }

  void deleteChat(String chatId) {
    state = state.copyWith(
        chats: state.chats.where((c) => c.id != chatId).toList());
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
    this.isLoading = true,
    this.isTyping = false,
    this.error,
    this.meta,
  });

  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isTyping;
  final String? error;
  final ChatMeta? meta;

  ConversationState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isTyping,
    String? error,
    bool clearError = false,
    ChatMeta? meta,
  }) {
    return ConversationState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isTyping: isTyping ?? this.isTyping,
      error: clearError ? null : (error ?? this.error),
      meta: meta ?? this.meta,
    );
  }
}

class ConversationNotifier extends StateNotifier<ConversationState> {
  ConversationNotifier(
    this._repo,
    this.chatId,
    this._currentUserId, {
    ChatMeta? initialMeta,
  })  : _initialMeta = initialMeta,
        super(const ConversationState()) {
    _load();
  }

  final ChatRepository _repo;
  final String chatId;
  final String _currentUserId;
  final ChatMeta? _initialMeta;

  static const _newIds = {'new', 'new-group'};

  Future<void> _load() async {
    if (_newIds.contains(chatId)) {
      if (mounted) state = state.copyWith(isLoading: false, meta: _initialMeta);
      return;
    }
    try {
      final messages = await _repo.fetchMessages(
        chatId,
        currentUserId: _currentUserId,
      );
      await _repo.markAsRead(chatId);
      if (mounted) {
        state = state.copyWith(
          messages: messages,
          isLoading: false,
          meta: _initialMeta,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load messages',
          meta: _initialMeta,
        );
      }
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _load();
  }

  void sendMessage(String text) {
    if (_newIds.contains(chatId)) return;

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final msg = ChatMessage(
      id: tempId,
      text: text,
      sender: 'You',
      senderInitials: 'ME',
      senderColor: AppColors.primary,
      time: _formatTime(),
      isMe: true,
    );
    state = state.copyWith(messages: [...state.messages, msg]);

    _repo.sendMessage(chatId, text, currentUserId: _currentUserId).then((sent) {
      if (sent != null && mounted) {
        final updated = state.messages.where((m) => m.id != tempId).toList();
        state = state.copyWith(messages: [...updated, sent]);
      }
    });
  }

  String _formatTime() {
    final now = DateTime.now();
    final h = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final m = now.minute.toString().padLeft(2, '0');
    final p = now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $p';
  }
}

final conversationNotifierProvider = StateNotifierProvider.family<
    ConversationNotifier, ConversationState, String>((ref, chatId) {
  final currentUserId = ref.watch(authNotifierProvider).user?.id ?? '';

  // Look up ChatMeta from already-loaded chat list (read, not watch, to avoid cascade rebuilds)
  ChatMeta? initialMeta;
  try {
    final preview = ref
        .read(chatListNotifierProvider)
        .chats
        .firstWhere((c) => c.id == chatId);
    initialMeta = ChatMeta(
      name: preview.name,
      initials: preview.initials,
      color: preview.avatarColor,
      isOnline: preview.isOnline,
      isGroup: preview.isGroup,
    );
  } catch (_) {}

  return ConversationNotifier(
    ref.watch(chatRepositoryProvider),
    chatId,
    currentUserId,
    initialMeta: initialMeta,
  );
});
