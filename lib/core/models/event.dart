// ──────────────────────────────────────────────────────────────────────────────
// EVENT MODELS — backed by /api/v1/events
// ──────────────────────────────────────────────────────────────────────────────

/// Event categories matching the backend enum.
enum EventCategory {
  worship,
  conference,
  youth,
  prayer,
  outreach,
  fellowship;

  static EventCategory fromString(String value) {
    return EventCategory.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => EventCategory.fellowship,
    );
  }
}

// ── Event Speaker ───────────────────────────────────────────────────────────

class EventSpeaker {
  const EventSpeaker({
    required this.id,
    required this.name,
    this.title,
    this.imageUrl,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final String? title;
  final String? imageUrl;
  final int sortOrder;

  factory EventSpeaker.fromJson(Map<String, dynamic> json) {
    return EventSpeaker(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      title: json['title'] as String?,
      imageUrl: json['imageUrl'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'title': title,
        'imageUrl': imageUrl,
        'sortOrder': sortOrder,
      };
}

// ── Event ───────────────────────────────────────────────────────────────────

class Event {
  const Event({
    required this.id,
    required this.title,
    this.description,
    this.category = EventCategory.fellowship,
    this.imageUrl,
    this.location,
    required this.startDate,
    this.endDate,
    this.isRecurring = false,
    this.recurrenceRule,
    this.registrationRequired = false,
    this.maxCapacity,
    this.registeredCount = 0,
    this.isFeatured = false,
    this.tags = const [],
    this.speakers = const [],
    this.isRegistered = false,
  });

  final String id;
  final String title;
  final String? description;
  final EventCategory category;
  final String? imageUrl;
  final String? location;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isRecurring;
  final String? recurrenceRule;
  final bool registrationRequired;
  final int? maxCapacity;
  final int registeredCount;
  final bool isFeatured;
  final List<String> tags;
  final List<EventSpeaker> speakers;
  final bool isRegistered;

  /// E.g. "Jan 26, 2025"
  String get dateFormatted {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[startDate.month - 1]} ${startDate.day}, ${startDate.year}';
  }

  /// E.g. "10:00 AM"
  String get timeFormatted {
    final hour = startDate.hour;
    final minute = startDate.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$h:$minute $period';
  }

  /// The date key used for calendar grouping (yyyy-MM-dd).
  String get dayKey {
    final m = startDate.month.toString().padLeft(2, '0');
    final d = startDate.day.toString().padLeft(2, '0');
    return '${startDate.year}-$m-$d';
  }

  /// Whether max capacity has been reached.
  bool get isFull =>
      maxCapacity != null && registeredCount >= maxCapacity!;

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      category: json['category'] != null
          ? EventCategory.fromString(json['category'] as String)
          : EventCategory.fellowship,
      imageUrl: json['imageUrl'] as String?,
      location: json['location'] as String?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurrenceRule: json['recurrenceRule'] as String?,
      registrationRequired: json['registrationRequired'] as bool? ?? false,
      maxCapacity: json['maxCapacity'] as int?,
      registeredCount: json['registeredCount'] as int? ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      speakers: (json['speakers'] as List<dynamic>?)
              ?.map((e) => EventSpeaker.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isRegistered: json['isRegistered'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category.name,
        'imageUrl': imageUrl,
        'location': location,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'isRecurring': isRecurring,
        'recurrenceRule': recurrenceRule,
        'registrationRequired': registrationRequired,
        'maxCapacity': maxCapacity,
        'registeredCount': registeredCount,
        'isFeatured': isFeatured,
        'tags': tags,
      };

  Event copyWith({
    String? id,
    String? title,
    String? description,
    EventCategory? category,
    String? imageUrl,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    bool? isRecurring,
    String? recurrenceRule,
    bool? registrationRequired,
    int? maxCapacity,
    int? registeredCount,
    bool? isFeatured,
    List<String>? tags,
    List<EventSpeaker>? speakers,
    bool? isRegistered,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      registrationRequired:
          registrationRequired ?? this.registrationRequired,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      registeredCount: registeredCount ?? this.registeredCount,
      isFeatured: isFeatured ?? this.isFeatured,
      tags: tags ?? this.tags,
      speakers: speakers ?? this.speakers,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }
}
