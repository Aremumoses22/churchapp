// ──────────────────────────────────────────────────────────────────────────────
// CHURCH INFO MODELS
// ──────────────────────────────────────────────────────────────────────────────

class ChurchInfo {
  const ChurchInfo({
    required this.id,
    required this.name,
    this.tagline,
    this.mission,
    this.vision,
    this.phone,
    this.email,
    this.website,
    this.address,
    this.logoUrl,
    this.coverImageUrl,
    this.socialLinks,
    this.coreValues = const [],
    this.timeline = const [],
  });

  final String id;
  final String name;
  final String? tagline;
  final String? mission;
  final String? vision;
  final String? phone;
  final String? email;
  final String? website;
  final String? address;
  final String? logoUrl;
  final String? coverImageUrl;
  final SocialLinks? socialLinks;
  final List<ChurchCoreValue> coreValues;
  final List<ChurchTimelineItem> timeline;

  factory ChurchInfo.fromJson(Map<String, dynamic> json) {
    return ChurchInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      tagline: json['tagline'] as String?,
      mission: json['mission'] as String?,
      vision: json['vision'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      address: json['address'] as String?,
      logoUrl: json['logoUrl'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      socialLinks: json['socialLinks'] != null
          ? SocialLinks.fromJson(json['socialLinks'] as Map<String, dynamic>)
          : null,
      coreValues: (json['coreValues'] as List?)
              ?.map((e) => ChurchCoreValue.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      timeline: (json['timeline'] as List?)
              ?.map((e) =>
                  ChurchTimelineItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ChurchTimelineItem {
  const ChurchTimelineItem({
    required this.year,
    required this.title,
    required this.description,
  });

  final String year;
  final String title;
  final String description;

  factory ChurchTimelineItem.fromJson(Map<String, dynamic> json) {
    return ChurchTimelineItem(
      year: json['year'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class SocialLinks {
  const SocialLinks({
    this.facebook,
    this.instagram,
    this.youtube,
    this.twitter,
  });

  final String? facebook;
  final String? instagram;
  final String? youtube;
  final String? twitter;

  factory SocialLinks.fromJson(Map<String, dynamic> json) {
    return SocialLinks(
      facebook: json['facebook'] as String?,
      instagram: json['instagram'] as String?,
      youtube: json['youtube'] as String?,
      twitter: json['twitter'] as String?,
    );
  }
}

class ChurchCoreValue {
  const ChurchCoreValue({
    required this.title,
    this.description,
    this.iconUrl,
  });

  final String title;
  final String? description;
  final String? iconUrl;

  factory ChurchCoreValue.fromJson(Map<String, dynamic> json) {
    return ChurchCoreValue(
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      iconUrl: json['iconUrl'] as String?,
    );
  }
}

class StaffMember {
  const StaffMember({
    required this.id,
    required this.name,
    required this.title,
    this.bio,
    this.imageUrl,
    this.email,
    this.phone,
  });

  final String id;
  final String name;
  final String title;
  final String? bio;
  final String? imageUrl;
  final String? email;
  final String? phone;

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      bio: json['bio'] as String?,
      imageUrl: json['imageUrl'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }
}

class Campus {
  const Campus({
    required this.id,
    required this.name,
    required this.address,
    this.lat,
    this.lng,
    this.phone,
    this.imageUrl,
    this.isPrimary = false,
    this.serviceTimes = const [],
  });

  final String id;
  final String name;
  final String address;
  final double? lat;
  final double? lng;
  final String? phone;
  final String? imageUrl;
  final bool isPrimary;
  final List<ServiceTime> serviceTimes;

  factory Campus.fromJson(Map<String, dynamic> json) {
    return Campus(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      phone: json['phone'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isPrimary: json['isPrimary'] as bool? ?? false,
      serviceTimes: (json['serviceTimes'] as List?)
              ?.map((e) => ServiceTime.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ServiceTime {
  const ServiceTime({
    required this.dayOfWeek,
    required this.time,
    this.label,
  });

  final String dayOfWeek;
  final String time;
  final String? label;

  factory ServiceTime.fromJson(Map<String, dynamic> json) {
    return ServiceTime(
      dayOfWeek: json['dayOfWeek'] as String? ?? '',
      time: json['time'] as String? ?? '',
      label: json['label'] as String?,
    );
  }
}

class ChurchFaq {
  const ChurchFaq({
    required this.id,
    required this.question,
    required this.answer,
    this.category,
    this.sortOrder = 0,
  });

  final String id;
  final String question;
  final String answer;
  final String? category;
  final int sortOrder;

  factory ChurchFaq.fromJson(Map<String, dynamic> json) {
    return ChurchFaq(
      id: json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      category: json['category'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }
}
