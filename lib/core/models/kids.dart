// ──────────────────────────────────────────────────────────────────────────────
// KIDS CHECK-IN MODELS
// ──────────────────────────────────────────────────────────────────────────────

class KidsChild {
  const KidsChild({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    this.allergies,
    this.medicalNotes,
    this.photoUrl,
    this.currentCheckIn,
  });

  final String id;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String? allergies;
  final String? medicalNotes;
  final String? photoUrl;
  final KidsActiveCheckIn? currentCheckIn;

  String get fullName => '$firstName $lastName';

  String get initials =>
      '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
          .toUpperCase();

  int get age {
    final now = DateTime.now();
    int years = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      years--;
    }
    return years;
  }

  bool get hasAllergies =>
      allergies != null &&
      allergies!.isNotEmpty &&
      allergies!.toLowerCase() != 'none';

  factory KidsChild.fromJson(Map<String, dynamic> json) {
    return KidsChild(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'] as String) ?? DateTime(2000)
          : DateTime(2000),
      allergies: json['allergies'] as String?,
      medicalNotes: json['medicalNotes'] as String?,
      photoUrl: json['photoUrl'] as String?,
      currentCheckIn: json['currentCheckIn'] != null
          ? KidsActiveCheckIn.fromJson(
              json['currentCheckIn'] as Map<String, dynamic>)
          : null,
    );
  }
}

class KidsActiveCheckIn {
  const KidsActiveCheckIn({
    required this.id,
    required this.securityCode,
    this.roomName,
  });

  final String id;
  final String securityCode;
  final String? roomName;

  factory KidsActiveCheckIn.fromJson(Map<String, dynamic> json) {
    return KidsActiveCheckIn(
      id: json['id'] as String? ?? '',
      securityCode: json['securityCode'] as String? ?? '',
      roomName: (json['room'] as Map<String, dynamic>?)?['name'] as String?,
    );
  }
}

class KidsRoom {
  const KidsRoom({
    required this.id,
    required this.name,
    required this.ageGroup,
    required this.capacity,
    required this.currentCount,
  });

  final String id;
  final String name;
  final String ageGroup;
  final int capacity;
  final int currentCount;

  bool get isFull => currentCount >= capacity;

  factory KidsRoom.fromJson(Map<String, dynamic> json) {
    return KidsRoom(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      ageGroup: json['ageGroup'] as String? ?? '',
      capacity: json['capacity'] as int? ?? 0,
      currentCount: json['currentCount'] as int? ?? 0,
    );
  }
}

class KidsCheckInResult {
  const KidsCheckInResult({
    required this.id,
    required this.securityCode,
    required this.qrCode,
    this.child,
    required this.room,
  });

  final String id;
  final String securityCode;
  final String qrCode;
  final KidsChild? child;
  final KidsRoom room;

  factory KidsCheckInResult.fromJson(Map<String, dynamic> json) {
    return KidsCheckInResult(
      id: json['id'] as String? ?? '',
      securityCode: json['securityCode'] as String? ?? '',
      qrCode: json['qrCode'] as String? ?? '',
      child: json['child'] != null
          ? KidsChild.fromJson(json['child'] as Map<String, dynamic>)
          : null,
      room: KidsRoom.fromJson(
          (json['room'] as Map<String, dynamic>?) ?? {}),
    );
  }
}
