import 'package:cloud_firestore/cloud_firestore.dart';

class StateModel {
  final String? stateId;
  final String stateName;
  final String stateCode;
  final Timestamp? createTime;
  final Timestamp? updateTime;

  const StateModel({
    this.stateId,
    required this.stateName,
    required this.stateCode,
    this.createTime,
    this.updateTime,
  });

  /// fromJson
  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      stateId: json['state_id'] as String?,
      stateName: json['state_name'] as String,
      stateCode: json['state_code'] as String,
      createTime: json['create_time'] as Timestamp?,
      updateTime: json['update_time'] as Timestamp?,
    );
  }

  /// toJson
  Map<String, dynamic> toJson() {
    return {
      'state_id': stateId,
      'state_name': stateName,
      'state_code': stateCode,
      'create_time': createTime,
      'update_time': updateTime,
    };
  }

  /// copyWith
  StateModel copyWith({
    String? stateId,
    String? stateName,
    String? stateCode,
    Timestamp? createTime,
    Timestamp? updateTime,
  }) {
    return StateModel(
      stateId: stateId ?? this.stateId,
      stateName: stateName ?? this.stateName,
      stateCode: stateCode ?? this.stateCode,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }
}
