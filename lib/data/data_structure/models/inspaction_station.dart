import 'package:cloud_firestore/cloud_firestore.dart';

import 'country.dart';

class InspactionStation {
  final String? sId;
  final String? stationId;
  final String stationName;
  // final String? stationNameLower;

  final String? stationRegEmail;
  final String? stationAuthUid;
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
  final int? inspactors;

  // final String? startTime;
  // final String? endTime;

  final Timestamp? createTime;
  final Timestamp? updateTime;

  final String? stationDescription;
  final WorkingHours? workingHours;

  const InspactionStation({
    this.sId,
    this.stationId,
    required this.stationName,
    // this.stationNameLower,
    this.stationRegEmail,
    this.stationAuthUid,
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
    this.inspactors,
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
    final whRaw = json['working_hours'];
    final WorkingHours? wh = (whRaw is Map)
        ? WorkingHours.fromJson(Map<String, dynamic>.from(whRaw))
        : (whRaw is WorkingHours ? whRaw : null);
    return InspactionStation(
      sId: json['sId'],
      stationId: json['station_id'],
      stationName: json['station_name'] as String,

      // stationNameLower: json['station_name_lower'],
      stationRegEmail: json['station_reg_email'],
      stationAuthUid: json['station_auth_uid'],
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
      inspactors: json['inspactors'] != null ? (json['inspactors'] as num).toInt() : null,

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
      workingHours: wh,
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
      'station_reg_email': stationRegEmail,
      'station_auth_uid': stationAuthUid,
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
      'inspactors': inspactors,
      // 'start_time': startTime,
      // 'end_time': endTime,
      'create_time': createTime?.toDate(),
      'update_time': updateTime?.toDate(),
      'station_description': stationDescription,
      'working_hours': workingHours?.toJson(),
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
    String? stationRegEmail,
    String? stationAuthUid,
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
    int? inspactors,
    // String? startTime,
    // String? endTime,
    Timestamp? createTime,
    Timestamp? updateTime,

    String? stationDescription,
    WorkingHours? workingHours,
  }) {
    return InspactionStation(
      sId: sId ?? this.sId,
      stationId: stationId ?? this.stationId,
      stationName: stationName ?? this.stationName,
      // stationNameLower: stationNameLower ?? this.stationNameLower,
      stationRegEmail: stationRegEmail ?? this.stationRegEmail,
      stationAuthUid: stationAuthUid ?? this.stationAuthUid,
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
      inspactors: inspactors ?? this.inspactors,
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
  final Map<String, List<DayInterval>> weeklySchedule;

  const WorkingHours({required this.selectedDays, required this.startTimes, required this.endTimes, this.weeklySchedule = const {}});

  Map<String, dynamic> toJson() {
    if (weeklySchedule.isNotEmpty) {
      final map = <String, dynamic>{};
      weeklySchedule.forEach((day, ranges) {
        map[day] = ranges.map((r) => r.toJson()).toList();
      });
      return {'weeklySchedule': map};
    }
    final days = selectedDays.toList();
    final ws = <String, List<DayInterval>>{};
    for (final d in days) {
      final s = startTimes[d];
      final e = endTimes[d];
      if (s != null && e != null) {
        ws[d] = [DayInterval(open: s, close: e)];
      }
    }
    final map = <String, dynamic>{};
    ws.forEach((day, ranges) {
      map[day] = ranges.map((r) => r.toJson()).toList();
    });
    return {'weeklySchedule': map};
  }

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('weeklySchedule')) {
      final wsRaw = Map<String, dynamic>.from(json['weeklySchedule'] ?? const {});
      final ws = <String, List<DayInterval>>{};
      final selected = <String>{};
      final starts = <String, String>{};
      final ends = <String, String>{};
      wsRaw.forEach((day, list) {
        final ranges = (list as List? ?? const <dynamic>[]).map((e) => DayInterval.fromJson(Map<String, dynamic>.from(e))).toList();
        ws[day] = ranges;
        if (ranges.isNotEmpty) {
          selected.add(day);
          starts[day] = ranges.first.open;
          ends[day] = ranges.first.close;
        }
      });
      return WorkingHours(selectedDays: selected, startTimes: starts, endTimes: ends, weeklySchedule: ws);
    } else if (json.containsKey('selected_days')) {
      final selected = Set<String>.from(json['selected_days'] ?? const []);
      final starts = Map<String, String>.from(json['start_times'] ?? const {});
      final ends = Map<String, String>.from(json['end_times'] ?? const {});
      final ws = <String, List<DayInterval>>{};
      for (final d in selected) {
        final s = starts[d];
        final e = ends[d];
        if (s != null && e != null) {
          ws[d] = [DayInterval(open: s, close: e)];
        }
      }
      return WorkingHours(selectedDays: selected, startTimes: starts, endTimes: ends, weeklySchedule: ws);
    } else {
      final selected = <String>{};
      final starts = <String, String>{};
      final ends = <String, String>{};
      final ws = <String, List<DayInterval>>{};
      const days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
      for (final d in days) {
        final entry = json[d];
        if (entry is Map) {
          final closed = entry['closed'] == true;
          if (!closed) {
            selected.add(d);
            final s = entry['start'];
            final e = entry['end'];
            if (s != null) starts[d] = s.toString();
            if (e != null) ends[d] = e.toString();
            if (s != null && e != null) {
              ws[d] = [DayInterval(open: s.toString(), close: e.toString())];
            }
          }
        }
      }
      return WorkingHours(selectedDays: selected, startTimes: starts, endTimes: ends, weeklySchedule: ws);
    }
  }
}

class DayInterval {
  final String open;
  final String close;
  const DayInterval({required this.open, required this.close});
  Map<String, dynamic> toJson() {
    return {'open': open, 'close': close};
  }

  factory DayInterval.fromJson(Map<String, dynamic> json) {
    return DayInterval(open: json['open']?.toString() ?? '', close: json['close']?.toString() ?? '');
  }
}
