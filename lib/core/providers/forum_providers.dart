import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/forum.dart';
import '../repositories/forum_repository.dart';

// ──────────────────────────────────────────────────────────────────────────────
// FORUM PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

final forumRepositoryProvider = Provider<ForumRepository>((_) {
  return ForumRepository();
});

// ── API async providers ───────────────────────────────────────────────────────

final forumCategoriesProvider =
    FutureProvider<List<ForumCategory>>((ref) async {
  final res = await ref.watch(forumRepositoryProvider).fetchCategories();
  if (!res.success) throw Exception(res.message);
  return res.data ?? [];
});

final forumTrendingProvider =
    FutureProvider<List<ForumThread>>((ref) async {
  final res = await ref.watch(forumRepositoryProvider).fetchTrending();
  if (!res.success) throw Exception(res.message);
  return res.data ?? [];
});

final forumRecentProvider =
    FutureProvider<List<ForumThread>>((ref) async {
  final res = await ref.watch(forumRepositoryProvider).fetchRecentThreads();
  if (!res.success) throw Exception(res.message);
  return res.data;
});

final forumCategoryThreadsProvider =
    FutureProvider.family<List<ForumThread>, String>((ref, categoryId) async {
  final res = await ref
      .watch(forumRepositoryProvider)
      .fetchCategoryThreads(categoryId);
  if (!res.success) throw Exception(res.message);
  return res.data;
});

// ── Forum screen search state ─────────────────────────────────────────────────

class ForumState {
  const ForumState({
    this.searchQuery = '',
  });

  final String searchQuery;

  ForumState copyWith({String? searchQuery}) {
    return ForumState(searchQuery: searchQuery ?? this.searchQuery);
  }
}

class ForumNotifier extends StateNotifier<ForumState> {
  ForumNotifier() : super(const ForumState());

  void setSearchQuery(String q) => state = state.copyWith(searchQuery: q);
}

final forumNotifierProvider =
    StateNotifierProvider<ForumNotifier, ForumState>((_) => ForumNotifier());

// ── Category Thread State ─────────────────────────────────────────────────────

class CategoryThreadState {
  const CategoryThreadState({
    this.threads = const [],
    this.isLoading = true,
    this.sortIndex = 0,
    this.error,
  });

  final List<ForumThread> threads;
  final bool isLoading;
  final int sortIndex;
  final String? error;

  CategoryThreadState copyWith({
    List<ForumThread>? threads,
    bool? isLoading,
    int? sortIndex,
    String? error,
    bool clearError = false,
  }) {
    return CategoryThreadState(
      threads: threads ?? this.threads,
      isLoading: isLoading ?? this.isLoading,
      sortIndex: sortIndex ?? this.sortIndex,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CategoryThreadNotifier extends StateNotifier<CategoryThreadState> {
  CategoryThreadNotifier(this._repo, this.categoryId)
      : super(const CategoryThreadState()) {
    _load();
  }

  final ForumRepository _repo;
  final String categoryId;

  Future<void> _load() async {
    try {
      final res = await _repo.fetchCategoryThreads(categoryId);
      if (mounted) {
        state = state.copyWith(threads: res.data, isLoading: false);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load threads',
        );
      }
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _load();
  }

  void setSortIndex(int index) => state = state.copyWith(sortIndex: index);
}

final categoryThreadNotifierProvider = StateNotifierProvider.family<
    CategoryThreadNotifier, CategoryThreadState, String>((ref, categoryId) {
  return CategoryThreadNotifier(ref.watch(forumRepositoryProvider), categoryId);
});

// ── Thread Detail State ───────────────────────────────────────────────────────

class ThreadDetailState {
  const ThreadDetailState({
    this.post,
    this.replies = const [],
    this.isLiked = false,
    this.isBookmarked = false,
    this.likeCount = 0,
    this.isLoading = true,
    this.error,
  });

  final ForumPost? post;
  final List<ForumReply> replies;
  final bool isLiked;
  final bool isBookmarked;
  final int likeCount;
  final bool isLoading;
  final String? error;

  ThreadDetailState copyWith({
    ForumPost? post,
    List<ForumReply>? replies,
    bool? isLiked,
    bool? isBookmarked,
    int? likeCount,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ThreadDetailState(
      post: post ?? this.post,
      replies: replies ?? this.replies,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      likeCount: likeCount ?? this.likeCount,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ThreadDetailNotifier extends StateNotifier<ThreadDetailState> {
  ThreadDetailNotifier(this._repo, this.threadId)
      : super(const ThreadDetailState()) {
    _load();
  }

  final ForumRepository _repo;
  final String threadId;

  Future<void> _load() async {
    try {
      final res = await _repo.fetchThread(threadId);
      if (res.data != null) {
        final detail = res.data!;
        if (mounted) {
          state = state.copyWith(
            post: detail.post,
            replies: detail.replies,
            likeCount: detail.post.likeCount,
            isLiked: detail.post.isLiked,
            isBookmarked: detail.post.isBookmarked,
            isLoading: false,
            clearError: true,
          );
        }
      } else {
        if (mounted) {
          state = state.copyWith(
            isLoading: false,
            error: res.message.isNotEmpty ? res.message : 'Failed to load thread',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  Future<void> toggleLike() async {
    final optimistic = !state.isLiked;
    state = state.copyWith(
      isLiked: optimistic,
      likeCount: optimistic ? state.likeCount + 1 : state.likeCount - 1,
    );
    try {
      final res = await _repo.toggleLike(threadId);
      if (!res.success) {
        state = state.copyWith(
          isLiked: !optimistic,
          likeCount: optimistic ? state.likeCount - 1 : state.likeCount + 1,
        );
      }
    } catch (_) {
      state = state.copyWith(
        isLiked: !optimistic,
        likeCount: optimistic ? state.likeCount - 1 : state.likeCount + 1,
      );
    }
  }

  Future<void> toggleBookmark() async {
    final optimistic = !state.isBookmarked;
    state = state.copyWith(isBookmarked: optimistic);
    try {
      final res = await _repo.toggleBookmark(threadId);
      if (!res.success) state = state.copyWith(isBookmarked: !optimistic);
    } catch (_) {
      state = state.copyWith(isBookmarked: !optimistic);
    }
  }

  Future<void> toggleReplyLike(String replyId) async {
    final idx = state.replies.indexWhere((r) => r.id == replyId);
    if (idx == -1) return;
    final reply = state.replies[idx];
    final optimistic = !reply.isLiked;
    state = state.copyWith(
      replies: state.replies.map((r) {
        if (r.id != replyId) return r;
        return r.copyWith(
          isLiked: optimistic,
          likes: optimistic ? r.likes + 1 : r.likes - 1,
        );
      }).toList(),
    );
    final res = await _repo.toggleReplyLike(replyId);
    if (!res.success) {
      state = state.copyWith(
        replies: state.replies.map((r) {
          if (r.id != replyId) return r;
          return r.copyWith(
            isLiked: !optimistic,
            likes: optimistic ? r.likes - 1 : r.likes + 1,
          );
        }).toList(),
      );
    }
  }

  Future<void> reload() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _load();
  }

  Future<void> addReply(String content) async {
    await _repo.postReply(threadId, content);
    await _load();
  }
}

final threadDetailNotifierProvider = StateNotifierProvider.family<
    ThreadDetailNotifier, ThreadDetailState, String>((ref, threadId) {
  return ThreadDetailNotifier(ref.watch(forumRepositoryProvider), threadId);
});
