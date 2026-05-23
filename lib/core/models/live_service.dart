// ──────────────────────────────────────────────────────────────────────────────
// LIVE SERVICE MODEL
// ──────────────────────────────────────────────────────────────────────────────

class LiveService {
  const LiveService({
    required this.id,
    required this.title,
    required this.status,
    required this.viewerCount,
    this.description,
    this.streamUrl,
    this.scheduledAt,
  });

  final String id;
  final String title;
  final String status; // SCHEDULED | LIVE | ENDED
  final int viewerCount;
  final String? description;
  final String? streamUrl;
  final String? scheduledAt;

  bool get isLive => status == 'LIVE';

  factory LiveService.fromJson(Map<String, dynamic> json) {
    return LiveService(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Live Service',
      status: json['status'] as String? ?? 'SCHEDULED',
      viewerCount: json['viewerCount'] as int? ?? 0,
      description: json['description'] as String?,
      streamUrl: json['streamUrl'] as String?,
      scheduledAt: json['scheduledAt'] as String?,
    );
  }
}

class LiveCurrent {
  const LiveCurrent({
    required this.isLive,
    this.current,
    this.upcoming = const [],
  });

  final bool isLive;
  final LiveService? current;
  final List<LiveService> upcoming;

  factory LiveCurrent.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current'] as Map<String, dynamic>?;
    final upcomingJson = (json['upcoming'] as List?)
            ?.map((e) => LiveService.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return LiveCurrent(
      isLive: json['isLive'] as bool? ?? false,
      current: currentJson != null ? LiveService.fromJson(currentJson) : null,
      upcoming: upcomingJson,
    );
  }
}
