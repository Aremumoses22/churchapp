// ──────────────────────────────────────────────────────────────────────────────
// HOME FEED MODEL
// ──────────────────────────────────────────────────────────────────────────────

class HomeFeed {
  const HomeFeed({
    this.greeting,
    this.verseOfTheDay,
    this.latestSermon,
    this.upcomingEvents = const [],
    this.announcements = const [],
    this.prayerRequests = const [],
    this.activeCampaigns = const [],
  });

  final String? greeting;
  final VerseOfTheDay? verseOfTheDay;
  final Map<String, dynamic>? latestSermon;
  final List<Map<String, dynamic>> upcomingEvents;
  final List<Map<String, dynamic>> announcements;
  final List<Map<String, dynamic>> prayerRequests;
  final List<FeedCampaign> activeCampaigns;

  factory HomeFeed.fromJson(Map<String, dynamic> json) {
    return HomeFeed(
      greeting: json['greeting'] as String?,
      verseOfTheDay: json['verseOfTheDay'] != null
          ? VerseOfTheDay.fromJson(
              json['verseOfTheDay'] as Map<String, dynamic>)
          : null,
      latestSermon: json['latestSermon'] as Map<String, dynamic>?,
      upcomingEvents: (json['upcomingEvents'] as List?)
              ?.cast<Map<String, dynamic>>() ??
          [],
      announcements: (json['announcements'] as List?)
              ?.cast<Map<String, dynamic>>() ??
          [],
      prayerRequests:
          (json['prayerRequests'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      activeCampaigns: (json['activeCampaigns'] as List?)
              ?.map((e) => FeedCampaign.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class VerseOfTheDay {
  const VerseOfTheDay({
    required this.reference,
    required this.text,
  });

  final String reference;
  final String text;

  factory VerseOfTheDay.fromJson(Map<String, dynamic> json) {
    return VerseOfTheDay(
      reference: json['reference'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );
  }
}

class FeedCampaign {
  const FeedCampaign({
    required this.id,
    required this.title,
    required this.goalAmount,
    required this.raisedAmount,
  });

  final String id;
  final String title;
  final double goalAmount;
  final double raisedAmount;

  double get progressPercent =>
      goalAmount > 0 ? (raisedAmount / goalAmount).clamp(0.0, 1.0) : 0.0;

  factory FeedCampaign.fromJson(Map<String, dynamic> json) {
    return FeedCampaign(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      goalAmount: (json['goalAmount'] as num?)?.toDouble() ?? 0.0,
      raisedAmount: (json['raisedAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
