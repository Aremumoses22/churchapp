import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/bible.dart';
import '../repositories/bible_repository.dart';

// ──────────────────────────────────────────────────────────────────────────────
// BIBLE PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

final bibleRepositoryProvider = Provider<BibleRepository>((_) {
  return BibleRepository();
});

// ── Bible Reader State ────────────────────────────────────────────────────────

class BibleState {
  const BibleState({
    this.books = const [],
    this.oldTestament = const [],
    this.newTestament = const [],
    this.level = 0,
    this.selectedBook = '',
    this.selectedBookId = '',
    this.selectedChapter = 0,
    this.nightMode = false,
    this.highlightedVerses = const {},
    this.verses = const [],
    this.verseData = const [],
    this.isLoadingChapter = false,
    this.isLoadingBooks = true,
    this.error,
  });

  final List<BibleBook> books;
  final List<String> oldTestament;
  final List<String> newTestament;
  final int level; // 0=books, 1=chapters, 2=verses
  final String selectedBook;
  final String selectedBookId;
  final int selectedChapter;
  final bool nightMode;
  final Set<int> highlightedVerses;
  final List<String> verses;
  final List<BibleVerse> verseData;
  final bool isLoadingChapter;
  final bool isLoadingBooks;
  final String? error;

  BibleState copyWith({
    List<BibleBook>? books,
    List<String>? oldTestament,
    List<String>? newTestament,
    int? level,
    String? selectedBook,
    String? selectedBookId,
    int? selectedChapter,
    bool? nightMode,
    Set<int>? highlightedVerses,
    List<String>? verses,
    List<BibleVerse>? verseData,
    bool? isLoadingChapter,
    bool? isLoadingBooks,
    String? error,
    bool clearError = false,
  }) {
    return BibleState(
      books: books ?? this.books,
      oldTestament: oldTestament ?? this.oldTestament,
      newTestament: newTestament ?? this.newTestament,
      level: level ?? this.level,
      selectedBook: selectedBook ?? this.selectedBook,
      selectedBookId: selectedBookId ?? this.selectedBookId,
      selectedChapter: selectedChapter ?? this.selectedChapter,
      nightMode: nightMode ?? this.nightMode,
      highlightedVerses: highlightedVerses ?? this.highlightedVerses,
      verses: verses ?? this.verses,
      verseData: verseData ?? this.verseData,
      isLoadingChapter: isLoadingChapter ?? this.isLoadingChapter,
      isLoadingBooks: isLoadingBooks ?? this.isLoadingBooks,
      error: clearError ? null : (error ?? this.error),
    );
  }

  int get chapterCount {
    try {
      return books.firstWhere((b) => b.name == selectedBook).chapters;
    } catch (_) {
      return 0;
    }
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class BibleNotifier extends StateNotifier<BibleState> {
  BibleNotifier(this._repo) : super(const BibleState()) {
    _init();
  }

  final BibleRepository _repo;

  Future<void> _init() async {
    try {
      final apiBooks = await _repo.fetchBooks();
      final ot = apiBooks.where((b) => b.isOldTestament).map((b) => b.name).toList();
      final nt = apiBooks.where((b) => !b.isOldTestament).map((b) => b.name).toList();
      if (mounted) {
        state = state.copyWith(
          books: apiBooks,
          oldTestament: ot,
          newTestament: nt,
          isLoadingBooks: false,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isLoadingBooks: false,
          error: 'Failed to load Bible books',
        );
      }
    }
  }

  void selectBook(String book) {
    final bookObj = state.books.firstWhere(
      (b) => b.name == book,
      orElse: () => BibleBook(name: book, chapters: 0, isOldTestament: false),
    );
    state = state.copyWith(
      selectedBook: book,
      selectedBookId: bookObj.id,
      level: 1,
      highlightedVerses: {},
    );
  }

  void selectChapter(int chapter) {
    state = state.copyWith(
      selectedChapter: chapter,
      level: 2,
      verses: const [],
      verseData: const [],
      highlightedVerses: {},
      isLoadingChapter: true,
    );
    _loadChapter(chapter);
  }

  Future<void> _loadChapter(int chapter) async {
    if (state.selectedBookId.isEmpty) {
      if (mounted) state = state.copyWith(isLoadingChapter: false);
      return;
    }
    try {
      final chapterData = await _repo.fetchChapter(state.selectedBookId, chapter);
      if (chapterData.verses.isNotEmpty && mounted) {
        final verses = chapterData.verses.map((v) => v.text).toList();
        final highlighted = chapterData.verses
            .where((v) => v.highlightId != null)
            .map((v) => v.verse)
            .toSet();
        state = state.copyWith(
          verses: verses,
          verseData: chapterData.verses,
          highlightedVerses: highlighted,
          isLoadingChapter: false,
        );
      } else if (mounted) {
        state = state.copyWith(
          verses: const [],
          verseData: const [],
          isLoadingChapter: false,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isLoadingChapter: false,
          error: 'Failed to load chapter',
        );
      }
    }
  }

  void goBack() {
    if (state.level == 2) {
      state = state.copyWith(level: 1, highlightedVerses: {});
    } else if (state.level == 1) {
      state = state.copyWith(level: 0, selectedBook: '', selectedBookId: '');
    }
  }

  void toggleNightMode() =>
      state = state.copyWith(nightMode: !state.nightMode);

  void toggleHighlight(int verseNum) {
    final set = Set<int>.from(state.highlightedVerses);
    final verse = state.verseData.where((v) => v.verse == verseNum).firstOrNull;

    if (set.contains(verseNum)) {
      set.remove(verseNum);
      state = state.copyWith(highlightedVerses: set);
      if (verse?.highlightId != null) {
        _repo.deleteHighlight(verse!.highlightId!);
        final updated = state.verseData.map((v) {
          return v.verse == verseNum ? v.copyWith(clearHighlight: true) : v;
        }).toList();
        state = state.copyWith(verseData: updated);
      }
    } else {
      set.add(verseNum);
      state = state.copyWith(highlightedVerses: set);
      if (verse != null && verse.highlightId == null && verse.id.isNotEmpty) {
        _repo.addHighlight(verseId: verse.id, color: 'yellow').then((hl) {
          if (hl != null && mounted) {
            final updated = state.verseData.map((v) {
              return v.verse == verseNum
                  ? v.copyWith(highlightId: hl.id, highlightColor: hl.color)
                  : v;
            }).toList();
            state = state.copyWith(verseData: updated);
          }
        });
      }
    }
  }

  void clearHighlights() => state = state.copyWith(highlightedVerses: {});
}

final bibleNotifierProvider =
    StateNotifierProvider<BibleNotifier, BibleState>((ref) {
  return BibleNotifier(ref.watch(bibleRepositoryProvider));
});

// ── Devotional Providers ──────────────────────────────────────────────────────

final devotionalProvider = FutureProvider<Devotional?>((ref) async {
  return ref.watch(bibleRepositoryProvider).fetchTodayDevotional();
});

final devotionalStreakProvider = FutureProvider<DevotionalStreak?>((ref) async {
  return ref.watch(bibleRepositoryProvider).fetchStreak();
});

// ── Reading Plan Providers ────────────────────────────────────────────────────

final readingPlansProvider = FutureProvider<List<ReadingPlan>>((ref) async {
  return ref.watch(bibleRepositoryProvider).fetchReadingPlans();
});

final myReadingPlansProvider =
    FutureProvider<List<UserReadingPlan>>((ref) async {
  return ref.watch(bibleRepositoryProvider).fetchMyReadingPlans();
});
