import 'package:cloud_firestore/cloud_firestore.dart';

import 'country.dart';

class InspactionStation {
  final String? sId;
  final String? stationId;
  final String stationName;
  // final String? stationNameLower;

  // final String? stationRegEmail;
  final String? stationContactNumber;
  // final String? stationTelNo;

  final String? stationAddress;
  final String? stationZipCode;

  final County? sCountyDetails;
  final List<dynamic>? stationDocumentIdList;

  final double? stationLatitude;
  final double? stationLongitude;

  final bool? stationRegApprovalStatus;
  final bool? stationAvailabilityStatus;
  final bool? stationDocumentsVerificationStatus;
  final bool? stationActivationStatus;
  final int? maxInspectors;

  // final String? startTime;
  // final String? endTime;

  final Timestamp? createTime;
  final Timestamp? updateTime;

  final String? stationDescription;
  final Map<String, dynamic>? workingHours;

  const InspactionStation({
    this.sId,
    this.stationId,
    required this.stationName,
    // this.stationNameLower,
    // this.stationRegEmail,
    this.stationContactNumber,
    // this.stationTelNo,
    this.stationAddress,
    this.stationZipCode,
    this.sCountyDetails,
    this.stationDocumentIdList,
    this.stationLatitude,
    this.stationLongitude,
    this.stationRegApprovalStatus,
    this.stationAvailabilityStatus = false,
    this.stationDocumentsVerificationStatus,
    this.stationActivationStatus = false,
    this.maxInspectors,
    // this.startTime,
    // this.endTime,
    this.createTime,
    this.updateTime,
    this.stationDescription,
    this.workingHours,
  });

  /// -----------------------------
  /// From JSON
  /// -----------------------------
  factory InspactionStation.fromJson(Map<String, dynamic> json) {
    return InspactionStation(
      sId: json['sId'],
      stationId: json['station_id'],
      stationName: json['station_name'] as String,
      // stationNameLower: json['station_name_lower'],

      // stationRegEmail: json['station_reg_email'],
      stationContactNumber: json['station_contact_number'],

      // stationTelNo: json['station_tel_no'],
      stationAddress: json['station_address'],
      stationZipCode: json['station_zip_code'],

      sCountyDetails: json['s_county_details'] != null ? County.fromJson(json['s_county_details']!) : null,
      stationDocumentIdList: (json['station_document_id_list'] as List?)?.toList(),

      stationLatitude: json['station_latitude'] != null ? (json['station_latitude'] as num).toDouble() : null,
      stationLongitude: json['station_longitude'] != null ? (json['station_longitude'] as num).toDouble() : null,

      stationRegApprovalStatus: json['station_reg_approval_status'],
      stationAvailabilityStatus: json['station_availability_status'],
      stationDocumentsVerificationStatus: json['station_documents_verification_status'],
      stationActivationStatus: json['station_activation_status'],
      maxInspectors: json['max_inspectors'] != null ? (json['max_inspectors'] as num).toInt() : null,

      // startTime:
      // json['start_time'] != null
      //     ? json['start_time']
      //     : null,
      // endTime:
      // json['end_time'] != null
      //     ? json['end_time']
      //     : null,
      createTime: json['create_time'] != null ? (json['create_time'] as Timestamp) : null,
      updateTime: json['update_time'] != null ? (json['update_time'] as Timestamp) : null,
      stationDescription: json['station_description'],
      workingHours: (json['working_hours'] as Map?)?.map((k, v) => MapEntry(k as String, v)),
    );
  }

  /// -----------------------------
  /// To JSON
  /// -----------------------------
  Map<String, dynamic> toJson() {
    return {
      'sId': sId,
      'station_id': stationId,
      'station_name': stationName,
      // 'station_name_lower': stationNameLower,
      // 'station_reg_email': stationRegEmail,
      'station_contact_number': stationContactNumber,
      // 'station_tel_no': stationTelNo,
      'station_address': stationAddress,
      'station_zip_code': stationZipCode,
      's_county_details': sCountyDetails != null ? sCountyDetails!.toJson() : null,
      'station_document_id_list': stationDocumentIdList,
      'station_latitude': stationLatitude,
      'station_longitude': stationLongitude,
      'station_reg_approval_status': stationRegApprovalStatus,
      'station_availability_status': stationAvailabilityStatus,
      'station_documents_verification_status': stationDocumentsVerificationStatus,
      'station_activation_status': stationActivationStatus,
      'max_inspectors': maxInspectors,
      // 'start_time': startTime,
      // 'end_time': endTime,
      'create_time': createTime?.toDate(),
      'update_time': updateTime?.toDate(),
      'station_description': stationDescription,
      'working_hours': workingHours,
    };
  }

  /// -----------------------------
  /// copyWith
  /// -----------------------------
  InspactionStation copyWith({
    String? sId,
    String? stationId,
    String? stationName,
    // String? stationNameLower,
    // String? stationRegEmail,
    String? stationContactNumber,
    // String? stationTelNo,
    String? stationAddress,
    String? stationZipCode,
    County? sCountyDetails,
    List<dynamic>? stationDocumentIdList,
    double? stationLatitude,
    double? stationLongitude,
    bool? stationRegApprovalStatus,
    bool? stationAvailabilityStatus,
    bool? stationDocumentsVerificationStatus,
    bool? stationActivationStatus,
    int? maxInspectors,
    // String? startTime,
    // String? endTime,
    Timestamp? createTime,
    Timestamp? updateTime,

    String? stationDescription,
    Map<String, dynamic>? workingHours,
  }) {
    return InspactionStation(
      sId: sId ?? this.sId,
      stationId: stationId ?? this.stationId,
      stationName: stationName ?? this.stationName,
      // stationNameLower: stationNameLower ?? this.stationNameLower,
      // stationRegEmail: stationRegEmail ?? this.stationRegEmail,
      stationContactNumber: stationContactNumber ?? this.stationContactNumber,
      // stationTelNo: stationTelNo ?? this.stationTelNo,
      stationAddress: stationAddress ?? this.stationAddress,
      stationZipCode: stationZipCode ?? this.stationZipCode,
      sCountyDetails: sCountyDetails ?? this.sCountyDetails,
      stationDocumentIdList: stationDocumentIdList ?? this.stationDocumentIdList,
      stationLatitude: stationLatitude ?? this.stationLatitude,
      stationLongitude: stationLongitude ?? this.stationLongitude,
      stationRegApprovalStatus: stationRegApprovalStatus ?? this.stationRegApprovalStatus,
      stationAvailabilityStatus: stationAvailabilityStatus ?? this.stationAvailabilityStatus,
      stationDocumentsVerificationStatus: stationDocumentsVerificationStatus ?? this.stationDocumentsVerificationStatus,
      stationActivationStatus: stationActivationStatus ?? this.stationActivationStatus,
      maxInspectors: maxInspectors ?? this.maxInspectors,
      // startTime: startTime ?? this.startTime,
      // endTime: endTime ?? this.endTime,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
      stationDescription: stationDescription ?? this.stationDescription,
      workingHours: workingHours ?? this.workingHours,
    );
  }
}

class WorkingHours {
  final Set<String> selectedDays;
  final Map<String, String> startTimes;
  final Map<String, String> endTimes;

  const WorkingHours({required this.selectedDays, required this.startTimes, required this.endTimes});

  /// -----------------------------
  /// To JSON
  /// -----------------------------
  Map<String, dynamic> toJson() {
    return {'selected_days': selectedDays.toList(), 'start_times': startTimes, 'end_times': endTimes};
  }

  /// -----------------------------
  /// From JSON
  /// -----------------------------
  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(selectedDays: Set.from(json['selected_days']), startTimes: Map.from(json['start_times']), endTimes: Map.from(json['end_times']));
  }
}
