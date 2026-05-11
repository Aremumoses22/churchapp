import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/forum.dart';
import '../repositories/forum_repository.dart';

// ──────────────────────────────────────────────────────────────────────────────
// FORUM PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

final forumRepositoryProvider = Provider<MockForumRepository>((_) {
  return MockForumRepository();
});

final apiForumRepositoryProvider = Provider<ApiForumRepository>((_) {
  return ApiForumRepository();
});

// ── API async providers ───────────────────────────────────────────────────────

final forumCategoriesProvider =
    FutureProvider<List<ForumCategory>>((ref) async {
  final res = await ref.watch(apiForumRepositoryProvider).fetchCategories();
  if (res.success && (res.data?.isNotEmpty ?? false)) return res.data!;
  // Fallback to mock when server is unavailable
  return ref.read(forumRepositoryProvider).getCategories();
});

final forumTrendingProvider =
    FutureProvider<List<ForumThread>>((ref) async {
  final res = await ref.watch(apiForumRepositoryProvider).fetchTrending();
  if (res.success && (res.data?.isNotEmpty ?? false)) return res.data!;
  return ref.read(forumRepositoryProvider).getTrendingTopics();
});

final forumRecentProvider =
    FutureProvider<List<ForumThread>>((ref) async {
  final res =
      await ref.watch(apiForumRepositoryProvider).fetchRecentThreads();
  if (res.success && res.data.isNotEmpty) return res.data;
  return ref.read(forumRepositoryProvider).getRecentThreads();
});

final forumCategoryThreadsProvider =
    FutureProvider.family<List<ForumThread>, String>((ref, categoryId) async {
  final res = await ref
      .watch(apiForumRepositoryProvider)
      .fetchCategoryThreads(categoryId);
  if (res.success && res.data.isNotEmpty) return res.data;
  return ref
      .read(forumRepositoryProvider)
      .getThreadsForCategory(categoryId);
});

// ── Local form state ─────────────────────────────────────────────────────────

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

class ForumNotifier extends StateNotifier<ForumState> {
  ForumNotifier(this._repo) : super(const ForumState()) {
    _init();
  }
  final MockForumRepository _repo;

  void _init() {
    state = state.copyWith(
      categories: _repo.getCategories(),
      trending: _repo.getTrendingTopics(),
      recentThreads: _repo.getRecentThreads(),
    );
  }

  void setSearchQuery(String q) => state = state.copyWith(searchQuery: q);

  void updateFromApi({
    List<ForumCategory>? categories,
    List<ForumThread>? trending,
    List<ForumThread>? recentThreads,
  }) {
    state = state.copyWith(
      categories: categories,
      trending: trending,
      recentThreads: recentThreads,
    );
  }
}

final forumNotifierProvider =
    StateNotifierProvider<ForumNotifier, ForumState>((ref) {
  return ForumNotifier(ref.watch(forumRepositoryProvider));
});

// ── Category Thread State ─────────────────────────────────────────────────────

class CategoryThreadState {
  const CategoryThreadState({
    this.threads = const [],
    this.meta,
    this.sortIndex = 0,
  });

  final List<ForumThread> threads;
  final ForumCategory? meta;
  final int sortIndex;

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
  final MockForumRepository _repo;
  final String categoryId;

  void _init() {
    state = state.copyWith(
      threads: _repo.getThreadsForCategory(categoryId),
      meta: _repo.getCategoryMeta(categoryId),
    );
  }

  void setSortIndex(int index) => state = state.copyWith(sortIndex: index);

  void updateThreads(List<ForumThread> threads) =>
      state = state.copyWith(threads: threads);
}

final categoryThreadNotifierProvider = StateNotifierProvider.family<
    CategoryThreadNotifier, CategoryThreadState, String>((ref, categoryId) {
  return CategoryThreadNotifier(
      ref.watch(forumRepositoryProvider), categoryId);
});

// ── Thread Detail State ───────────────────────────────────────────────────────

class ThreadDetailState {
  const ThreadDetailState({
    this.post,
    this.replies = const [],
    this.isLiked = false,
    this.isBookmarked = false,
    this.likeCount = 0,
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
  ThreadDetailNotifier(this._mockRepo, this._apiRepo, this.threadId)
      : super(const ThreadDetailState()) {
    _init();
  }
  final MockForumRepository _mockRepo;
  final ApiForumRepository _apiRepo;
  final String threadId;

  void _init() {
    // Seed with mock data immediately, then load from API
    final mockPost = _mockRepo.getPost(threadId);
    final mockReplies = _mockRepo.getReplies(threadId);
    state = state.copyWith(
      post: mockPost,
      replies: mockReplies,
      likeCount: mockPost.likeCount,
    );
    _loadFromApi();
  }

  Future<void> _loadFromApi() async {
    final postRes = await _apiRepo.fetchThread(threadId);
    if (postRes.success && postRes.data != null) {
      final post = postRes.data!;
      state = state.copyWith(
        post: post,
        likeCount: post.likeCount,
        isLiked: post.isLiked,
        isBookmarked: post.isBookmarked,
      );
    }
    final repliesRes = await _apiRepo.fetchReplies(threadId);
    if (repliesRes.success && repliesRes.data.isNotEmpty) {
      state = state.copyWith(replies: repliesRes.data);
    }
  }

  Future<void> toggleLike() async {
    final optimistic = !state.isLiked;
    state = state.copyWith(
      isLiked: optimistic,
      likeCount: optimistic ? state.likeCount + 1 : state.likeCount - 1,
    );
    final res = await _apiRepo.toggleLike(threadId);
    if (!res.success) {
      // Revert on failure
      state = state.copyWith(
        isLiked: !optimistic,
        likeCount: optimistic ? state.likeCount - 1 : state.likeCount + 1,
      );
    }
  }

  Future<void> toggleBookmark() async {
    final optimistic = !state.isBookmarked;
    state = state.copyWith(isBookmarked: optimistic);
    final res = await _apiRepo.toggleBookmark(threadId);
    if (!res.success) state = state.copyWith(isBookmarked: !optimistic);
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
    final res = await _apiRepo.toggleReplyLike(replyId);
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

  Future<void> addReply(String content) async {
    await _apiRepo.postReply(threadId, content);
    await _loadFromApi();
  }
}

final threadDetailNotifierProvider = StateNotifierProvider.family<
    ThreadDetailNotifier, ThreadDetailState, String>((ref, threadId) {
  return ThreadDetailNotifier(
    ref.watch(forumRepositoryProvider),
    ref.watch(apiForumRepositoryProvider),
    threadId,
  );
});
