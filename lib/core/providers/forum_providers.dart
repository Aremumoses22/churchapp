import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/forum.dart';
import '../repositories/forum_repository.dart';

// ──────────────────────────────────────────────────────────────────────────────
// FORUM PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

final forumRepositoryProvider = Provider<ForumRepository>((_) {
  return MockForumRepository();
});

// ── State ────────────────────────────────────────────────────────────────────

class ForumState {
  const ForumState({
    this.categories = const [],
    this.trending = const [],
    this.recentThreads = const [],
    this.searchQuery = '',
  });

  final List<ForumCategory> categories;
  final List<ForumThread> trending;
  final List<ForumThread> recentThreads;
  final String searchQuery;

  ForumState copyWith({
    List<ForumCategory>? categories,
    List<ForumThread>? trending,
    List<ForumThread>? recentThreads,
    String? searchQuery,
  }) {
    return ForumState(
      categories: categories ?? this.categories,
      trending: trending ?? this.trending,
      recentThreads: recentThreads ?? this.recentThreads,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<ForumThread> get filteredThreads {
    if (searchQuery.isEmpty) return recentThreads;
    final q = searchQuery.toLowerCase();
    return recentThreads
        .where((t) =>
            t.title.toLowerCase().contains(q) ||
            t.author.toLowerCase().contains(q) ||
            t.body.toLowerCase().contains(q))
        .toList();
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class ForumNotifier extends StateNotifier<ForumState> {
  ForumNotifier(this._repo) : super(const ForumState()) {
    _init();
  }
  final ForumRepository _repo;

  void _init() {
    state = state.copyWith(
      categories: _repo.getCategories(),
      trending: _repo.getTrendingTopics(),
      recentThreads: _repo.getRecentThreads(),
    );
  }

  void setSearchQuery(String q) => state = state.copyWith(searchQuery: q);
}

final forumNotifierProvider =
    StateNotifierProvider<ForumNotifier, ForumState>((ref) {
  return ForumNotifier(ref.watch(forumRepositoryProvider));
});

// ── Category Thread State ────────────────────────────────────────────────────

class CategoryThreadState {
  const CategoryThreadState({
    this.threads = const [],
    this.meta,
    this.sortIndex = 0,
  });

  final List<ForumThread> threads;
  final ForumCategory? meta;
  final int sortIndex; // 0=Latest, 1=Popular, 2=Unanswered

  CategoryThreadState copyWith({
    List<ForumThread>? threads,
    ForumCategory? meta,
    int? sortIndex,
  }) {
    return CategoryThreadState(
      threads: threads ?? this.threads,
      meta: meta ?? this.meta,
      sortIndex: sortIndex ?? this.sortIndex,
    );
  }
}

class CategoryThreadNotifier extends StateNotifier<CategoryThreadState> {
  CategoryThreadNotifier(this._repo, this.categoryId)
      : super(const CategoryThreadState()) {
    _init();
  }
  final ForumRepository _repo;
  final String categoryId;

  void _init() {
    state = state.copyWith(
      threads: _repo.getThreadsForCategory(categoryId),
      meta: _repo.getCategoryMeta(categoryId),
    );
  }

  void setSortIndex(int index) => state = state.copyWith(sortIndex: index);
}

final categoryThreadNotifierProvider = StateNotifierProvider.family<
    CategoryThreadNotifier, CategoryThreadState, String>((ref, categoryId) {
  return CategoryThreadNotifier(
      ref.watch(forumRepositoryProvider), categoryId);
});

// ── Thread Detail State ──────────────────────────────────────────────────────

class ThreadDetailState {
  const ThreadDetailState({
    this.post,
    this.replies = const [],
    this.isLiked = false,
    this.isBookmarked = false,
    this.likeCount = 67,
  });

  final ForumPost? post;
  final List<ForumReply> replies;
  final bool isLiked;
  final bool isBookmarked;
  final int likeCount;

  ThreadDetailState copyWith({
    ForumPost? post,
    List<ForumReply>? replies,
    bool? isLiked,
    bool? isBookmarked,
    int? likeCount,
  }) {
    return ThreadDetailState(
      post: post ?? this.post,
      replies: replies ?? this.replies,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      likeCount: likeCount ?? this.likeCount,
    );
  }
}

class ThreadDetailNotifier extends StateNotifier<ThreadDetailState> {
  ThreadDetailNotifier(this._repo, this.threadId)
      : super(const ThreadDetailState()) {
    _init();
  }
  final ForumRepository _repo;
  final String threadId;

  void _init() {
    state = state.copyWith(
      post: _repo.getPost(threadId),
      replies: _repo.getReplies(threadId),
    );
  }

  void toggleLike() {
    state = state.copyWith(
      isLiked: !state.isLiked,
      likeCount: state.isLiked ? state.likeCount - 1 : state.likeCount + 1,
    );
  }

  void toggleBookmark() =>
      state = state.copyWith(isBookmarked: !state.isBookmarked);

  void toggleReplyLike(String replyId) {
    final updated = state.replies.map((r) {
      if (r.id == replyId) {
        return r.copyWith(
          isLiked: !r.isLiked,
          likes: r.isLiked ? r.likes - 1 : r.likes + 1,
        );
      }
      return r;
    }).toList();
    state = state.copyWith(replies: updated);
  }

  void addReply(ForumReply reply) {
    state = state.copyWith(replies: [...state.replies, reply]);
  }
}

final threadDetailNotifierProvider = StateNotifierProvider.family<
    ThreadDetailNotifier, ThreadDetailState, String>((ref, threadId) {
  return ThreadDetailNotifier(ref.watch(forumRepositoryProvider), threadId);
});
