import 'package:cloud_firestore/cloud_firestore.dart';

class County {
  final String? countyId;
  final String countyName;
  final String countyLowerName;
  final Timestamp? createTime;
  final Timestamp? updateTime;

  const County({
    this.countyId,
    required this.countyName,
    required this.countyLowerName,
    this.createTime,
    this.updateTime,
  });

  /// Create object from JSON (API / DB)
  factory County.fromJson(Map<String, dynamic> json) {
    return County(
      countyId: json['county_id'] as String?,
      countyName: json['county_name'] as String,
      countyLowerName: json['county_name_lower'] as String,
      createTime: json['create_time'] != null
          ? json['create_time'] as Timestamp
          : null,
      updateTime: json['update_time'] != null
          ? json['update_time'] as Timestamp
          : null,
    );
  }

  /// Convert object to JSON (API / DB)
  Map<String, dynamic> toJson() {
    return {
      'county_id': countyId,
      'county_name': countyName,
      'county_name_lower': countyLowerName,
      'create_time': createTime,
      'update_time': updateTime,
    };
  }

  /// Copy with updated values
  County copyWith({
    String? countyId,
    String? countyName,
    String? countryLowerName,
    Timestamp? createTime,
    Timestamp? updateTime,
  }) {
    return County(
      countyId: countyId ?? this.countyId,
      countyName: countyName ?? this.countyName,
      countyLowerName: countyLowerName ?? this.countyLowerName,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }
}
