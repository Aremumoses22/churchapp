import 'dart:ui';

// ──────────────────────────────────────────────────────────────────────────────
// SERMON MODELS
// ──────────────────────────────────────────────────────────────────────────────

enum DownloadState { none, downloading, downloaded }

class SermonSeries {
  const SermonSeries({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
  });

  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
}

class Sermon {
  const Sermon({
    required this.id,
    required this.title,
    required this.speaker,
    required this.duration,
    required this.date,
    this.series,
    this.downloadState = DownloadState.none,
    this.downloadProgress = 0.0,
  });

  final String id;
  final String title;
  final String speaker;
  final String duration;
  final String date;
  final String? series;
  final DownloadState downloadState;
  final double downloadProgress;

  Sermon copyWith({
    String? id,
    String? title,
    String? speaker,
    String? duration,
    String? date,
    String? series,
    DownloadState? downloadState,
    double? downloadProgress,
  }) {
    return Sermon(
      id: id ?? this.id,
      title: title ?? this.title,
      speaker: speaker ?? this.speaker,
      duration: duration ?? this.duration,
      date: date ?? this.date,
      series: series ?? this.series,
      downloadState: downloadState ?? this.downloadState,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }
}
