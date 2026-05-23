// ──────────────────────────────────────────────────────────────────────────────
// MEDIA MODELS — Podcasts, Albums, Songs
// ──────────────────────────────────────────────────────────────────────────────

// ── Podcast Episode ───────────────────────────────────────────────────────────

class PodcastEpisode {
  const PodcastEpisode({
    required this.id,
    required this.title,
    this.series,
    this.speaker,
    this.description,
    this.audioUrl,
    this.thumbnailUrl,
    this.durationSeconds,
    this.publishedAt,
    this.progressSeconds = 0,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String? series;
  final String? speaker;
  final String? description;
  final String? audioUrl;
  final String? thumbnailUrl;
  final int? durationSeconds;
  final String? publishedAt;
  final int progressSeconds;
  final bool isCompleted;

  String get durationFormatted {
    if (durationSeconds == null) return '';
    final m = durationSeconds! ~/ 60;
    final s = durationSeconds! % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  factory PodcastEpisode.fromJson(Map<String, dynamic> json) {
    return PodcastEpisode(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      series: json['series'] as String? ??
          (json['sermonSeries'] as Map<String, dynamic>?)?['title'] as String?,
      speaker: json['speaker'] as String? ??
          (json['pastor'] as Map<String, dynamic>?)?['name'] as String?,
      description: json['description'] as String?,
      audioUrl: json['audioUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String? ?? json['imageUrl'] as String?,
      durationSeconds: json['durationSeconds'] as int? ??
          json['duration'] as int?,
      publishedAt: json['publishedAt'] as String? ??
          json['createdAt'] as String?,
      progressSeconds: json['progressSeconds'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

// ── Photo Album ───────────────────────────────────────────────────────────────

class PhotoAlbum {
  const PhotoAlbum({
    required this.id,
    required this.title,
    this.description,
    this.coverUrl,
    this.photoCount = 0,
    this.eventDate,
  });

  final String id;
  final String title;
  final String? description;
  final String? coverUrl;
  final int photoCount;
  final String? eventDate;

  factory PhotoAlbum.fromJson(Map<String, dynamic> json) {
    return PhotoAlbum(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      coverUrl: json['coverUrl'] as String? ?? json['imageUrl'] as String?,
      photoCount: json['photoCount'] as int? ?? 0,
      eventDate: json['eventDate'] as String? ?? json['createdAt'] as String?,
    );
  }
}

// ── Photo ─────────────────────────────────────────────────────────────────────

class AlbumPhoto {
  const AlbumPhoto({
    required this.id,
    required this.url,
    this.albumId,
    this.caption,
    this.createdAt,
  });

  final String id;
  final String url;
  final String? albumId;
  final String? caption;
  final String? createdAt;

  factory AlbumPhoto.fromJson(Map<String, dynamic> json) {
    return AlbumPhoto(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? json['photoUrl'] as String? ?? '',
      albumId: json['albumId'] as String?,
      caption: json['caption'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}

// ── Song ──────────────────────────────────────────────────────────────────────

class Song {
  const Song({
    required this.id,
    required this.title,
    this.artist,
    this.key,
    this.bpm,
    this.lyricsText,
    this.category,
  });

  final String id;
  final String title;
  final String? artist;
  final String? key;
  final int? bpm;
  final String? lyricsText;
  final String? category;

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      artist: json['artist'] as String?,
      key: json['key'] as String? ?? json['musicalKey'] as String?,
      bpm: json['bpm'] as int?,
      lyricsText: json['lyricsText'] as String? ?? json['lyrics'] as String?,
      category: json['category'] as String?,
    );
  }
}
