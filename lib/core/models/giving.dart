import 'dart:ui';

// ──────────────────────────────────────────────────────────────────────────────
// GIVING MODELS
// ──────────────────────────────────────────────────────────────────────────────

// Legacy UI model (used by the form state).
class SavedCard {
  const SavedCard({
    required this.brand,
    required this.last4,
    required this.color,
  });

  final String brand;
  final String last4;
  final Color color;
}

// ── API models ────────────────────────────────────────────────────────────────

class GivingCategory {
  const GivingCategory({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final String? description;
  final bool isActive;
  final int sortOrder;

  factory GivingCategory.fromJson(Map<String, dynamic> json) {
    return GivingCategory(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }
}

class GivingSummary {
  const GivingSummary({
    this.totalGiven = 0,
    this.thisMonth = 0,
    this.thisYear = 0,
    this.donationCount = 0,
    this.recentDonations = const [],
  });

  final double totalGiven;
  final double thisMonth;
  final double thisYear;
  final int donationCount;
  final List<Donation> recentDonations;

  factory GivingSummary.fromJson(Map<String, dynamic> json) {
    return GivingSummary(
      totalGiven: (json['totalGiven'] as num?)?.toDouble() ?? 0,
      thisMonth: (json['thisMonth'] as num?)?.toDouble() ?? 0,
      thisYear: (json['thisYear'] as num?)?.toDouble() ?? 0,
      donationCount: json['donationCount'] as int? ?? 0,
      recentDonations: (json['recentDonations'] as List?)
              ?.map((e) => Donation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Donation {
  const Donation({
    required this.id,
    required this.amount,
    this.categoryName,
    this.paymentMethod,
    this.status,
    this.notes,
    this.createdAt,
    this.isAnonymous = false,
  });

  final String id;
  final double amount;
  final String? categoryName;
  final String? paymentMethod;
  final String? status;
  final String? notes;
  final String? createdAt;
  final bool isAnonymous;

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      categoryName: json['categoryName'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      status: json['status'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
    );
  }
}

class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.type,
    required this.last4,
    required this.provider,
    this.expiryMonth,
    this.expiryYear,
    this.bankName,
    this.isDefault = false,
  });

  final String id;
  final String type;
  final String last4;
  final String provider;
  final int? expiryMonth;
  final int? expiryYear;
  final String? bankName;
  final bool isDefault;

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'CARD',
      last4: json['last4'] as String? ?? '****',
      provider: json['provider'] as String? ?? '',
      expiryMonth: json['expiryMonth'] as int?,
      expiryYear: json['expiryYear'] as int?,
      bankName: json['bankName'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

class GivingCampaign {
  const GivingCampaign({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.goalAmount = 0,
    this.raisedAmount = 0,
    this.donorCount = 0,
    this.startDate,
    this.endDate,
    this.isActive = true,
  });

  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final double goalAmount;
  final double raisedAmount;
  final int donorCount;
  final String? startDate;
  final String? endDate;
  final bool isActive;

  double get progressPercent =>
      goalAmount > 0 ? (raisedAmount / goalAmount).clamp(0.0, 1.0) : 0.0;

  factory GivingCampaign.fromJson(Map<String, dynamic> json) {
    return GivingCampaign(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      goalAmount: (json['goalAmount'] as num?)?.toDouble() ?? 0,
      raisedAmount: (json['raisedAmount'] as num?)?.toDouble() ?? 0,
      donorCount: json['donorCount'] as int? ?? 0,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class Pledge {
  const Pledge({
    required this.id,
    required this.campaignId,
    required this.totalAmount,
    this.paidAmount = 0,
    this.status,
    this.endDate,
    this.campaignTitle,
  });

  final String id;
  final String campaignId;
  final double totalAmount;
  final double paidAmount;
  final String? status;
  final String? endDate;
  final String? campaignTitle;

  double get progressPercent =>
      totalAmount > 0 ? (paidAmount / totalAmount).clamp(0.0, 1.0) : 0.0;

  factory Pledge.fromJson(Map<String, dynamic> json) {
    return Pledge(
      id: json['id'] as String? ?? '',
      campaignId: json['campaignId'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String?,
      endDate: json['endDate'] as String?,
      campaignTitle: json['campaign']?['title'] as String?,
    );
  }
}

class RecurringDonation {
  const RecurringDonation({
    required this.id,
    required this.amount,
    required this.frequency,
    this.categoryName,
    this.isActive = true,
    this.nextDate,
  });

  final String id;
  final double amount;
  final String frequency;
  final String? categoryName;
  final bool isActive;
  final String? nextDate;

  factory RecurringDonation.fromJson(Map<String, dynamic> json) {
    return RecurringDonation(
      id: json['id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      frequency: json['frequency'] as String? ?? 'MONTHLY',
      categoryName: json['category']?['name'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      nextDate: json['nextDate'] as String?,
    );
  }
}
