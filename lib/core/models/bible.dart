// ──────────────────────────────────────────────────────────────────────────────
// BIBLE MODELS
// ──────────────────────────────────────────────────────────────────────────────

class BibleBook {
  const BibleBook({
    required this.name,
    required this.chapters,
    required this.isOldTestament,
    this.id = '',
    this.abbreviation = '',
  });

  final String id;
  final String name;
  final String abbreviation;
  final int chapters;
  final bool isOldTestament;

  factory BibleBook.fromJson(Map<String, dynamic> json) {
    final testament = json['testament'] as String? ?? 'NEW';
    return BibleBook(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      abbreviation: json['abbreviation'] as String? ?? '',
      chapters: json['chapterCount'] as int? ?? 0,
      isOldTestament: testament.toUpperCase() == 'OLD',
    );
  }
}

class BibleVerse {
  const BibleVerse({
    required this.id,
    required this.verse,
    required this.text,
    this.highlightColor,
    this.highlightNote,
    this.highlightId,
  });

  final String id;
  final int verse;
  final String text;
  final String? highlightColor;
  final String? highlightNote;
  final String? highlightId;

  BibleVerse copyWith({
    String? highlightColor,
    String? highlightNote,
    String? highlightId,
    bool clearHighlight = false,
  }) {
    return BibleVerse(
      id: id,
      verse: verse,
      text: text,
      highlightColor: clearHighlight ? null : (highlightColor ?? this.highlightColor),
      highlightNote: clearHighlight ? null : (highlightNote ?? this.highlightNote),
      highlightId: clearHighlight ? null : (highlightId ?? this.highlightId),
    );
  }

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    final hlJson = json['highlight'] as Map<String, dynamic>?;
    return BibleVerse(
      id: json['id'] as String? ?? '',
      verse: json['verse'] as int? ?? 0,
      text: json['text'] as String? ?? '',
      highlightColor: hlJson?['color'] as String?,
      highlightNote: hlJson?['note'] as String?,
      highlightId: hlJson?['id'] as String?,
    );
  }
}

class BibleChapterData {
  const BibleChapterData({
    required this.bookName,
    required this.chapter,
    required this.verses,
  });

  final String bookName;
  final int chapter;
  final List<BibleVerse> verses;

  factory BibleChapterData.fromJson(Map<String, dynamic> json) {
    final bookJson = json['book'] as Map<String, dynamic>?;
    return BibleChapterData(
      bookName: bookJson?['name'] as String? ?? '',
      chapter: json['chapter'] as int? ?? 0,
      verses: (json['verses'] as List?)
              ?.map((v) => BibleVerse.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class BibleHighlight {
  const BibleHighlight({
    required this.id,
    required this.color,
    required this.reference,
    required this.text,
    this.note,
  });

  final String id;
  final String color;
  final String reference;
  final String text;
  final String? note;

  factory BibleHighlight.fromJson(Map<String, dynamic> json) {
    return BibleHighlight(
      id: json['id'] as String? ?? '',
      color: json['color'] as String? ?? 'yellow',
      reference: json['reference'] as String? ?? '',
      text: json['text'] as String? ?? '',
      note: json['note'] as String?,
    );
  }
}

class Devotional {
  const Devotional({
    required this.id,
    required this.date,
    required this.dayOfWeek,
    required this.title,
    required this.scripture,
    required this.scriptureText,
    required this.body,
    required this.reflectionPrompt,
    required this.author,
    required this.readingTime,
    this.isRead = false,
  });

  final String id;
  final String date;
  final String dayOfWeek;
  final String title;
  final String scripture;
  final String scriptureText;
  final String body;
  final String reflectionPrompt;
  final String author;
  final String readingTime;
  final bool isRead;

  Devotional copyWith({bool? isRead}) {
    return Devotional(
      id: id,
      date: date,
      dayOfWeek: dayOfWeek,
      title: title,
      scripture: scripture,
      scriptureText: scriptureText,
      body: body,
      reflectionPrompt: reflectionPrompt,
      author: author,
      readingTime: readingTime,
      isRead: isRead ?? this.isRead,
    );
  }

  static String _formatDate(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate);
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  static String _formatDayOfWeek(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate);
      const days = [
        'Monday', 'Tuesday', 'Wednesday', 'Thursday',
        'Friday', 'Saturday', 'Sunday',
      ];
      return days[dt.weekday - 1];
    } catch (_) {
      return '';
    }
  }

  factory Devotional.fromJson(Map<String, dynamic> json) {
    final readingMins = json['readingTimeMinutes'] as int? ?? 3;
    return Devotional(
      id: json['id'] as String? ?? '',
      date: _formatDate(json['date'] as String?),
      dayOfWeek: _formatDayOfWeek(json['date'] as String?),
      title: json['title'] as String? ?? '',
      scripture: json['scriptureReference'] as String? ?? '',
      scriptureText: json['scriptureText'] as String? ?? '',
      body: json['content'] as String? ?? '',
      reflectionPrompt: json['reflectionQuestion'] as String? ?? '',
      author: json['author'] as String? ?? '',
      readingTime: '$readingMins min read',
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}

class DevotionalStreak {
  const DevotionalStreak({
    required this.currentStreak,
    required this.todayCompleted,
    required this.totalReads,
  });

  final int currentStreak;
  final bool todayCompleted;
  final int totalReads;

  factory DevotionalStreak.fromJson(Map<String, dynamic> json) {
    return DevotionalStreak(
      currentStreak: json['currentStreak'] as int? ?? 0,
      todayCompleted: json['todayCompleted'] as bool? ?? false,
      totalReads: json['totalReads'] as int? ?? 0,
    );
  }
}

class ReadingPlan {
  const ReadingPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.totalDays,
    required this.participantCount,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String description;
  final int totalDays;
  final int participantCount;
  final String? imageUrl;

  factory ReadingPlan.fromJson(Map<String, dynamic> json) {
    return ReadingPlan(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      totalDays: json['totalDays'] as int? ?? 0,
      participantCount: json['participantCount'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class UserReadingPlan {
  const UserReadingPlan({
    required this.plan,
    required this.currentDay,
    required this.completedDays,
    this.enrolledAt,
  });

  final ReadingPlan plan;
  final int currentDay;
  final List<int> completedDays;
  final String? enrolledAt;

  double get progressPercent =>
      plan.totalDays > 0 ? currentDay / plan.totalDays : 0.0;
  int get daysRemaining => plan.totalDays - currentDay;

  factory UserReadingPlan.fromJson(Map<String, dynamic> json) {
    final planJson = json['plan'] as Map<String, dynamic>?;
    final rawCompleted = json['completedDays'] as List?;
    return UserReadingPlan(
      plan: planJson != null
          ? ReadingPlan.fromJson(planJson)
          : const ReadingPlan(
              id: '',
              title: '',
              description: '',
              totalDays: 0,
              participantCount: 0,
            ),
      currentDay: json['currentDay'] as int? ?? 0,
      completedDays:
          rawCompleted?.map((e) => (e as num).toInt()).toList() ?? [],
      enrolledAt: json['enrolledAt'] as String?,
    );
  }
}
