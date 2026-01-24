import 'package:cloud_firestore/cloud_firestore.dart';

class Inspector {
  final String? inspectorId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? badgeId;
  final String? stationId;
  final String? stationName;
  final bool isActive;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final Timestamp? lastLogin;
  final int? totalInspections;
  final double? passRate;
  final int? avgDaily;

  const Inspector({
    this.inspectorId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.badgeId,
    this.stationId,
    this.stationName,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.lastLogin,
    this.totalInspections,
    this.passRate,
    this.avgDaily,
  });

  factory Inspector.fromJson(Map<String, dynamic> json) {
    Timestamp? parseTimestamp(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value;
      if (value is String) {
        try {
          return Timestamp.fromDate(DateTime.parse(value));
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    return Inspector(
      inspectorId: json['inspector_id'] as String?,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      badgeId: json['badge_id'] as String?,
      stationId: json['station_id'] as String?,
      stationName: json['station_name'] as String?,
      isActive: (json['is_active'] as bool?) ?? true,
      createdAt: parseTimestamp(json['created_at']),
      updatedAt: parseTimestamp(json['updated_at']),
      lastLogin: parseTimestamp(json['last_login']),
      totalInspections: json['total_inspections'] != null
          ? (json['total_inspections'] as num).toInt()
          : null,
      passRate: json['pass_rate'] != null
          ? (json['pass_rate'] as num).toDouble()
          : null,
      avgDaily: json['avg_daily'] != null
          ? (json['avg_daily'] as num).toInt()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inspector_id': inspectorId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'badge_id': badgeId,
      'station_id': stationId,
      'station_name': stationName,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'last_login': lastLogin,
      'total_inspections': totalInspections,
      'pass_rate': passRate,
      'avg_daily': avgDaily,
    };
  }

  Inspector copyWith({
    String? inspectorId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? badgeId,
    String? stationId,
    String? stationName,
    bool? isActive,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    Timestamp? lastLogin,
    int? totalInspections,
    double? passRate,
    int? avgDaily,
  }) {
    return Inspector(
      inspectorId: inspectorId ?? this.inspectorId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      badgeId: badgeId ?? this.badgeId,
      stationId: stationId ?? this.stationId,
      stationName: stationName ?? this.stationName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
      totalInspections: totalInspections ?? this.totalInspections,
      passRate: passRate ?? this.passRate,
      avgDaily: avgDaily ?? this.avgDaily,
    );
  }
}
