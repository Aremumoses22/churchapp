// ──────────────────────────────────────────────────────────────────────────────
// VOLUNTEER MODELS
// ──────────────────────────────────────────────────────────────────────────────

// ── Volunteer Opportunity ─────────────────────────────────────────────────────

class VolunteerOpportunity {
  const VolunteerOpportunity({
    required this.id,
    required this.title,
    required this.ministry,
    this.description,
    this.commitment,
    this.schedule,
    this.spotsLeft,
    this.totalSpots,
    this.skills = const [],
    this.isSignedUp = false,
  });

  final String id;
  final String title;
  final String ministry;
  final String? description;
  final String? commitment;
  final String? schedule;
  final int? spotsLeft;
  final int? totalSpots;
  final List<String> skills;
  final bool isSignedUp;

  VolunteerOpportunity copyWith({bool? isSignedUp}) {
    return VolunteerOpportunity(
      id: id,
      title: title,
      ministry: ministry,
      description: description,
      commitment: commitment,
      schedule: schedule,
      spotsLeft: spotsLeft,
      totalSpots: totalSpots,
      skills: skills,
      isSignedUp: isSignedUp ?? this.isSignedUp,
    );
  }

  factory VolunteerOpportunity.fromJson(Map<String, dynamic> json) {
    return VolunteerOpportunity(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      ministry: json['ministry'] as String? ?? json['department'] as String? ?? '',
      description: json['description'] as String?,
      commitment: json['commitment'] as String?,
      schedule: json['schedule'] as String?,
      spotsLeft: json['spotsLeft'] as int? ?? json['availableSpots'] as int?,
      totalSpots: json['totalSpots'] as int? ?? json['maxVolunteers'] as int?,
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isSignedUp: json['isSignedUp'] as bool? ?? false,
    );
  }
}

// ── Roster Shift ──────────────────────────────────────────────────────────────

class RosterShift {
  const RosterShift({
    required this.id,
    required this.role,
    required this.ministry,
    this.serviceDate,
    this.serviceName,
    this.teamLead,
    this.status,
    this.canCheckIn = false,
    this.checkedIn = false,
  });

  final String id;
  final String role;
  final String ministry;
  final String? serviceDate;
  final String? serviceName;
  final String? teamLead;
  final String? status;
  final bool canCheckIn;
  final bool checkedIn;

  bool get isPast {
    if (serviceDate == null) return false;
    try {
      return DateTime.parse(serviceDate!).isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  RosterShift copyWith({bool? checkedIn}) {
    return RosterShift(
      id: id,
      role: role,
      ministry: ministry,
      serviceDate: serviceDate,
      serviceName: serviceName,
      teamLead: teamLead,
      status: status,
      canCheckIn: canCheckIn,
      checkedIn: checkedIn ?? this.checkedIn,
    );
  }

  factory RosterShift.fromJson(Map<String, dynamic> json) {
    return RosterShift(
      id: json['id'] as String? ?? '',
      role: json['role'] as String? ??
          (json['opportunity'] as Map<String, dynamic>?)?['title'] as String? ??
          '',
      ministry: json['ministry'] as String? ??
          (json['opportunity'] as Map<String, dynamic>?)?['ministry'] as String? ??
          '',
      serviceDate: json['serviceDate'] as String? ?? json['date'] as String?,
      serviceName: json['serviceName'] as String? ?? json['service'] as String?,
      teamLead: json['teamLead'] as String? ??
          (json['leader'] as Map<String, dynamic>?)?['name'] as String?,
      status: json['status'] as String?,
      canCheckIn: json['canCheckIn'] as bool? ?? false,
      checkedIn: json['checkedIn'] as bool? ?? false,
    );
  }
}
