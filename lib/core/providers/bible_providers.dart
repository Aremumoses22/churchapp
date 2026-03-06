import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/bible.dart';
import '../repositories/bible_repository.dart';

// ──────────────────────────────────────────────────────────────────────────────
// BIBLE PROVIDERS
// ──────────────────────────────────────────────────────────────────────────────

final bibleRepositoryProvider = Provider<BibleRepository>((_) {
  return MockBibleRepository();
});

// ── State ────────────────────────────────────────────────────────────────────

class BibleState {
  const BibleState({
    this.books = const [],
    this.oldTestament = const [],
    this.newTestament = const [],
    this.level = 0,
    this.selectedBook = '',
    this.selectedChapter = 0,
    this.nightMode = false,
    this.highlightedVerses = const {},
    this.verses = const [],
  });

  final List<BibleBook> books;
  final List<String> oldTestament;
  final List<String> newTestament;
  final int level; // 0=books, 1=chapters, 2=verses
  final String selectedBook;
  final int selectedChapter;
  final bool nightMode;
  final Set<int> highlightedVerses;
  final List<String> verses;

  BibleState copyWith({
    List<BibleBook>? books,
    List<String>? oldTestament,
    List<String>? newTestament,
    int? level,
    String? selectedBook,
    int? selectedChapter,
    bool? nightMode,
    Set<int>? highlightedVerses,
    List<String>? verses,
  }) {
    return BibleState(
      books: books ?? this.books,
      oldTestament: oldTestament ?? this.oldTestament,
      newTestament: newTestament ?? this.newTestament,
      level: level ?? this.level,
      selectedBook: selectedBook ?? this.selectedBook,
      selectedChapter: selectedChapter ?? this.selectedChapter,
      nightMode: nightMode ?? this.nightMode,
      highlightedVerses: highlightedVerses ?? this.highlightedVerses,
      verses: verses ?? this.verses,
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

// ── Notifier ─────────────────────────────────────────────────────────────────

class BibleNotifier extends StateNotifier<BibleState> {
  BibleNotifier(this._repo) : super(const BibleState()) {
    _init();
  }
  final BibleRepository _repo;

  void _init() {
    state = state.copyWith(
      books: _repo.getBooks(),
      oldTestament: _repo.getOldTestamentNames(),
      newTestament: _repo.getNewTestamentNames(),
    );
  }

  void selectBook(String book) {
    state = state.copyWith(
      selectedBook: book,
      level: 1,
      highlightedVerses: {},
    );
  }

  void selectChapter(int chapter) {
    final verses =
        _repo.getVerses(state.selectedBook, chapter);
    state = state.copyWith(
      selectedChapter: chapter,
      level: 2,
      verses: verses,
      highlightedVerses: {},
    );
  }

  void goBack() {
    if (state.level == 2) {
      state = state.copyWith(level: 1, highlightedVerses: {});
    } else if (state.level == 1) {
      state = state.copyWith(level: 0, selectedBook: '');
    }
  }

  void toggleNightMode() =>
      state = state.copyWith(nightMode: !state.nightMode);

  void toggleHighlight(int verseIndex) {
    final set = Set<int>.from(state.highlightedVerses);
    if (set.contains(verseIndex)) {
      set.remove(verseIndex);
    } else {
      set.add(verseIndex);
    }
    state = state.copyWith(highlightedVerses: set);
  }

  void clearHighlights() =>
      state = state.copyWith(highlightedVerses: {});
}

final bibleNotifierProvider =
    StateNotifierProvider<BibleNotifier, BibleState>((ref) {
  return BibleNotifier(ref.watch(bibleRepositoryProvider));
});
