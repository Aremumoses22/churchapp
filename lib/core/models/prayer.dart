// ──────────────────────────────────────────────────────────────────────────────
// PRAYER REQUEST MODELS
// ──────────────────────────────────────────────────────────────────────────────

class PrayerRequest {
  const PrayerRequest({
    required this.id,
    required this.title,
    this.details,
    this.isPublic = true,
    this.prayerCount = 0,
    this.status,
    this.authorName,
    this.createdAt,
    this.hasPrayed = false,
  });

  final String id;
  final String title;
  final String? details;
  final bool isPublic;
  final int prayerCount;
  final String? status;
  final String? authorName;
  final String? createdAt;
  final bool hasPrayed;

  PrayerRequest copyWith({int? prayerCount, bool? hasPrayed}) {
    return PrayerRequest(
      id: id,
      title: title,
      details: details,
      isPublic: isPublic,
      prayerCount: prayerCount ?? this.prayerCount,
      status: status,
      authorName: authorName,
      createdAt: createdAt,
      hasPrayed: hasPrayed ?? this.hasPrayed,
    );
  }

  factory PrayerRequest.fromJson(Map<String, dynamic> json) {
    return PrayerRequest(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      details: json['details'] as String?,
      isPublic: json['isPublic'] as bool? ?? true,
      prayerCount: json['prayerCount'] as int? ?? 0,
      status: json['status'] as String?,
      authorName: (json['author'] as Map<String, dynamic>?)?['name'] as String?,
      createdAt: json['createdAt'] as String?,
      hasPrayed: json['hasPrayed'] as bool? ?? false,
    );
  }
}
