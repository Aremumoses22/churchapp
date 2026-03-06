import 'dart:ui';

import '../models/sermon.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SERMON REPOSITORY
// ──────────────────────────────────────────────────────────────────────────────

abstract class SermonRepository {
  List<Sermon> getSermons();
  List<SermonSeries> getSeries();
  String get nowPlayingTitle;
  String get nowPlayingSpeaker;
  double get nowPlayingProgress;
}

class MockSermonRepository implements SermonRepository {
  @override
  String get nowPlayingTitle => 'The Power of Faith';

  @override
  String get nowPlayingSpeaker => 'Pastor James';

  @override
  double get nowPlayingProgress => 0.35;

  @override
  List<SermonSeries> getSeries() => const [
        SermonSeries(
            id: 's1',
            title: 'Faith Series',
            subtitle: '6 sermons',
            emoji: '\u{1F525}',
            color: Color(0xFF1E40AF)),
        SermonSeries(
            id: 's2',
            title: 'Grace & Mercy',
            subtitle: '4 sermons',
            emoji: '\u{1F54A}\u{FE0F}',
            color: Color(0xFF7C3AED)),
        SermonSeries(
            id: 's3',
            title: 'Worship',
            subtitle: '5 sermons',
            emoji: '\u{1F3B5}',
            color: Color(0xFFF59E0B)),
        SermonSeries(
            id: 's4',
            title: 'New Beginnings',
            subtitle: '3 sermons',
            emoji: '\u{1F331}',
            color: Color(0xFF10B981)),
        SermonSeries(
            id: 's5',
            title: 'Family Matters',
            subtitle: '8 sermons',
            emoji: '\u{1F46A}',
            color: Color(0xFFEF4444)),
      ];

  @override
  List<Sermon> getSermons() => const [
        Sermon(
          id: '1',
          title: 'The Power of Faith',
          speaker: 'Pastor James',
          duration: '42 min',
          series: 'Faith Series',
          date: 'Feb 23, 2026',
          downloadState: DownloadState.downloaded,
        ),
        Sermon(
          id: '2',
          title: 'Walking in Grace',
          speaker: 'Pastor James',
          duration: '38 min',
          series: 'Grace & Mercy',
          date: 'Feb 16, 2026',
        ),
        Sermon(
          id: '3',
          title: 'The Heart of Worship',
          speaker: 'Pastor Sarah',
          duration: '45 min',
          series: 'Worship',
          date: 'Feb 9, 2026',
          downloadState: DownloadState.downloading,
          downloadProgress: 0.65,
        ),
        Sermon(
          id: '4',
          title: 'Building Strong Foundations',
          speaker: 'Guest: Bishop Thomas',
          duration: '51 min',
          date: 'Feb 2, 2026',
        ),
        Sermon(
          id: '5',
          title: 'Love Without Limits',
          speaker: 'Pastor James',
          duration: '39 min',
          series: 'Faith Series',
          date: 'Jan 26, 2026',
          downloadState: DownloadState.downloaded,
        ),
        Sermon(
          id: '6',
          title: 'Pressing Forward',
          speaker: 'Pastor Sarah',
          duration: '44 min',
          series: 'New Beginnings',
          date: 'Jan 19, 2026',
        ),
      ];
}
