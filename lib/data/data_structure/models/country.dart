class County {
  final String? countyId;
  final String countyName;
  final String countyLowerName;
  final DateTime? createTime;
  final DateTime? updateTime;

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
          ? DateTime.parse(json['create_time'])
          : null,
      updateTime: json['update_time'] != null
          ? DateTime.parse(json['update_time'])
          : null,
    );
  }

  /// Convert object to JSON (API / DB)
  Map<String, dynamic> toJson() {
    return {
      'county_id': countyId,
      'county_name': countyName,
      'county_name_lower': countyLowerName,
      'create_time': createTime?.toIso8601String(),
      'update_time': updateTime?.toIso8601String(),
    };
  }

  /// Copy with updated values
  County copyWith({
    String? countyId,
    String? countyName,
    String? countryLowerName,
    DateTime? createTime,
    DateTime? updateTime,
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
