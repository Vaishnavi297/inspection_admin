import 'package:cloud_firestore/cloud_firestore.dart';

class Inspection {
  final String? appointmentApprovalStatus;
  final Timestamp? appointmentDateTime;
  final String? appointmentId;
  final String? cId;
  final String? countyId;
  final Timestamp? createTime;
  final String? inspectionDeclineReason;
  final String? inspectionDocumentImage;
  final String? inspectionNote;
  final String? inspectionSticker;
  final String? inspectionType;
  final bool? isScheduledForLater;
  final String? stationId;
  final Timestamp? updateTime;
  final String? vId;
  final String? vName;
  final String? vStates;
  final String? vTitle;
  final String? walkInInspectionNotes;

  const Inspection({
    this.appointmentApprovalStatus,
    this.appointmentDateTime,
    this.appointmentId,
    this.cId,
    this.countyId,
    this.createTime,
    this.inspectionDeclineReason,
    this.inspectionDocumentImage,
    this.inspectionNote,
    this.inspectionSticker,
    this.inspectionType,
    this.isScheduledForLater,
    this.stationId,
    this.updateTime,
    this.vId,
    this.vName,
    this.vStates,
    this.vTitle,
    this.walkInInspectionNotes,
  });

  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      appointmentApprovalStatus: json['appointment_approval_status'],
      appointmentDateTime: json['appointment_date_time'] is Timestamp
          ? json['appointment_date_time']
          : null,
      appointmentId: json['appointment_id'],
      cId: json['c_id'],
      countyId: json['county_id'],
      createTime: json['create_time'] is Timestamp ? json['create_time'] : null,
      inspectionDeclineReason: json['inspection_decline_reason'],
      inspectionDocumentImage: json['inspection_document_image'],
      inspectionNote: json['inspection_note'],
      inspectionSticker: json['inspection_sticker'],
      inspectionType: json['inspection_type'],
      isScheduledForLater: json['is_scheduled_for_later'],
      stationId: json['station_id'],
      updateTime: json['update_time'] is Timestamp ? json['update_time'] : null,
      vId: json['v_id'],
      vName: json['v_name'],
      vStates: json['v_states'],
      vTitle: json['v_title'],
      walkInInspectionNotes: json['walk_in_inspection_notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointment_approval_status': appointmentApprovalStatus,
      'appointment_date_time': appointmentDateTime,
      'appointment_id': appointmentId,
      'c_id': cId,
      'county_id': countyId,
      'create_time': createTime,
      'inspection_decline_reason': inspectionDeclineReason,
      'inspection_document_image': inspectionDocumentImage,
      'inspection_note': inspectionNote,
      'inspection_sticker': inspectionSticker,
      'inspection_type': inspectionType,
      'is_scheduled_for_later': isScheduledForLater,
      'station_id': stationId,
      'update_time': updateTime,
      'v_id': vId,
      'v_name': vName,
      'v_states': vStates,
      'v_title': vTitle,
      'walk_in_inspection_notes': walkInInspectionNotes,
    };
  }

  Inspection copyWith({
    String? appointmentApprovalStatus,
    Timestamp? appointmentDateTime,
    String? appointmentId,
    String? cId,
    String? countyId,
    Timestamp? createTime,
    String? inspectionDeclineReason,
    String? inspectionDocumentImage,
    String? inspectionNote,
    String? inspectionSticker,
    String? inspectionType,
    bool? isScheduledForLater,
    String? stationId,
    Timestamp? updateTime,
    String? vId,
    String? vName,
    String? vStates,
    String? vTitle,
    String? walkInInspectionNotes,
  }) {
    return Inspection(
      appointmentApprovalStatus:
          appointmentApprovalStatus ?? this.appointmentApprovalStatus,
      appointmentDateTime: appointmentDateTime ?? this.appointmentDateTime,
      appointmentId: appointmentId ?? this.appointmentId,
      cId: cId ?? this.cId,
      countyId: countyId ?? this.countyId,
      createTime: createTime ?? this.createTime,
      inspectionDeclineReason:
          inspectionDeclineReason ?? this.inspectionDeclineReason,
      inspectionDocumentImage:
          inspectionDocumentImage ?? this.inspectionDocumentImage,
      inspectionNote: inspectionNote ?? this.inspectionNote,
      inspectionSticker: inspectionSticker ?? this.inspectionSticker,
      inspectionType: inspectionType ?? this.inspectionType,
      isScheduledForLater: isScheduledForLater ?? this.isScheduledForLater,
      stationId: stationId ?? this.stationId,
      updateTime: updateTime ?? this.updateTime,
      vId: vId ?? this.vId,
      vName: vName ?? this.vName,
      vStates: vStates ?? this.vStates,
      vTitle: vTitle ?? this.vTitle,
      walkInInspectionNotes:
          walkInInspectionNotes ?? this.walkInInspectionNotes,
    );
  }
}
