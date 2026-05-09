// ──────────────────────────────────────────────────────────────────────────────
// SERMON MODELS — backed by /api/v1/sermons
// ──────────────────────────────────────────────────────────────────────────────

enum DownloadState { none, downloading, downloaded }

// ── Sermon Series ───────────────────────────────────────────────────────────

class SermonSeries {
  const SermonSeries({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.sortOrder = 0,
    this.sermonCount = 0,
    this.sermons = const [],
  });

  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? startDate;
  final String? endDate;
  final bool isActive;
  final int sortOrder;
  final int sermonCount;
  final List<Sermon> sermons;

  factory SermonSeries.fromJson(Map<String, dynamic> json) {
    return SermonSeries(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      sortOrder: json['sortOrder'] as int? ?? 0,
      sermonCount: json['sermonCount'] as int? ??
          (json['sermons'] as List?)?.length ??
          0,
      sermons: (json['sermons'] as List<dynamic>?)
              ?.map((e) => Sermon.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'startDate': startDate,
        'endDate': endDate,
        'isActive': isActive,
        'sortOrder': sortOrder,
      };
}

// ── Sermon ──────────────────────────────────────────────────────────────────

class Sermon {
  const Sermon({
    required this.id,
    required this.title,
    required this.speaker,
    this.description,
    this.date,
    this.duration,
    this.audioUrl,
    this.videoUrl,
    this.thumbnailUrl,
    this.scriptureRef,
    this.tags = const [],
    this.likeCount = 0,
    this.playCount = 0,
    this.isFeatured = false,
    this.seriesId,
    this.series,
    this.isSaved = false,
    this.downloadState = DownloadState.none,
    this.downloadProgress = 0.0,
  });

  final String id;
  final String title;
  final String speaker;
  final String? description;
  final String? date;
  final int? duration; // seconds
  final String? audioUrl;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? scriptureRef;
  final List<String> tags;
  final int likeCount;
  final int playCount;
  final bool isFeatured;
  final String? seriesId;
  final SermonSeries? series;
  final bool isSaved;
  // Local-only download state
  final DownloadState downloadState;
  final double downloadProgress;

  /// Formatted duration string (e.g. "42 min")
  String get durationFormatted {
    if (duration == null) return '';
    final mins = (duration! / 60).ceil();
    return '$mins min';
  }

  /// Formatted date string
  String get dateFormatted {
    if (date == null) return '';
    try {
      final d = DateTime.parse(date!);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) {
      return date!;
    }
  }

  factory Sermon.fromJson(Map<String, dynamic> json) {
    return Sermon(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      speaker: json['speaker'] as String? ?? '',
      description: json['description'] as String?,
      date: json['date'] as String?,
      duration: json['duration'] as int?,
      audioUrl: json['audioUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      scriptureRef: json['scriptureRef'] as String?,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      likeCount: json['likeCount'] as int? ?? 0,
      playCount: json['playCount'] as int? ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      seriesId: json['seriesId'] as String?,
      series: json['series'] != null
          ? SermonSeries.fromJson(json['series'] as Map<String, dynamic>)
          : null,
      isSaved: json['isSaved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'speaker': speaker,
        'description': description,
        'date': date,
        'duration': duration,
        'audioUrl': audioUrl,
        'videoUrl': videoUrl,
        'thumbnailUrl': thumbnailUrl,
        'scriptureRef': scriptureRef,
        'tags': tags,
        'likeCount': likeCount,
        'playCount': playCount,
        'isFeatured': isFeatured,
        'seriesId': seriesId,
      };

  Sermon copyWith({
    String? id,
    String? title,
    String? speaker,
    String? description,
    String? date,
    int? duration,
    String? audioUrl,
    String? videoUrl,
    String? thumbnailUrl,
    String? scriptureRef,
    List<String>? tags,
    int? likeCount,
    int? playCount,
    bool? isFeatured,
    String? seriesId,
    SermonSeries? series,
    bool? isSaved,
    DownloadState? downloadState,
    double? downloadProgress,
  }) {
    return Sermon(
      id: id ?? this.id,
      title: title ?? this.title,
      speaker: speaker ?? this.speaker,
      description: description ?? this.description,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      audioUrl: audioUrl ?? this.audioUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      scriptureRef: scriptureRef ?? this.scriptureRef,
      tags: tags ?? this.tags,
      likeCount: likeCount ?? this.likeCount,
      playCount: playCount ?? this.playCount,
      isFeatured: isFeatured ?? this.isFeatured,
      seriesId: seriesId ?? this.seriesId,
      series: series ?? this.series,
      isSaved: isSaved ?? this.isSaved,
      downloadState: downloadState ?? this.downloadState,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }
}

// ── Sermon Notes ────────────────────────────────────────────────────────────

class SermonNote {
  const SermonNote({
    required this.id,
    required this.sermonId,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String sermonId;
  final String content;
  final String? createdAt;
  final String? updatedAt;

  factory SermonNote.fromJson(Map<String, dynamic> json) {
    return SermonNote(
      id: json['id'] as String,
      sermonId: json['sermonId'] as String,
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sermonId': sermonId,
        'content': content,
      };
}

// ── Stream Info ─────────────────────────────────────────────────────────────

class SermonStreamInfo {
  const SermonStreamInfo({
    required this.audioUrl,
    this.videoUrl,
  });

  final String audioUrl;
  final String? videoUrl;

  factory SermonStreamInfo.fromJson(Map<String, dynamic> json) {
    return SermonStreamInfo(
      audioUrl: json['audioUrl'] as String? ?? '',
      videoUrl: json['videoUrl'] as String?,
    );
  }
}
