import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String? vId;
  final String? cID;
  final String? vName;
  final String? vTitle;
  final String? vPlateNumber;
  final String? vImageUrl;
  final String? vVin;
  final String? vState;
  final String? vCurrentInspectionSticker;
  final Timestamp? vLastInspectionDate;
  final bool? vActivationStatus;
  final String? documentVerificationStatus;
  final List<dynamic>? insuranceDocumentsIdList;
  final List<dynamic>? registrationDocumentsIdList;
  final String? vModel;
  final String? vMileage;
  final Timestamp? createTime;
  final Timestamp? updateTime;

  const Vehicle({
    this.vId,
    this.cID,
    this.vName,
    this.vTitle,
    this.vPlateNumber,
    this.vImageUrl,
    this.vVin,
    this.vState,
    this.vCurrentInspectionSticker,
    this.vLastInspectionDate,
    this.vActivationStatus,
    this.documentVerificationStatus,
    this.insuranceDocumentsIdList,
    this.registrationDocumentsIdList,
    this.vModel,
    this.vMileage,
    this.createTime,
    this.updateTime,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vId: json['v_id'],
      cID: json['c_id'],
      vName: json['v_name'],
      vTitle: json['v_title'],
      vPlateNumber: json['v_plate_number'],
      vImageUrl: json['v_image_url'],
      vVin: json['v_vin'],
      vState: json['v_state'],
      vCurrentInspectionSticker: json['v_current_inspection_sticker'],
      vLastInspectionDate: json['v_last_inspection_date'] != null ? Timestamp.fromDate(DateTime.parse(json['v_last_inspection_date'])) : null,
      vActivationStatus: json['v_activation_status'],
      documentVerificationStatus: json['document_verification_status'],
      insuranceDocumentsIdList: (json['insurance_documents_id_list'] as List?)?.toList(),
      registrationDocumentsIdList: (json['registration_documents_id_list'] as List?)?.toList(),
      vModel: json['v_model'],
      vMileage: json['v_mileage'],
      createTime: json['create_time'] != null ? Timestamp.fromDate(DateTime.parse(json['create_time'])) : null,
      updateTime: json['update_time'] != null ? Timestamp.fromDate(DateTime.parse(json['update_time'])) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'v_id': vId,
      'c_id': cID,
      'v_name': vName,
      'v_title': vTitle,
      'v_plate_number': vPlateNumber,
      'v_image_url': vImageUrl,
      'v_vin': vVin,
      'v_state': vState,
      'v_current_inspection_sticker': vCurrentInspectionSticker,
      'v_last_inspection_date': vLastInspectionDate,
      'v_activation_status': vActivationStatus,
      'document_verification_status': documentVerificationStatus,
      'insurance_documents_id_list': insuranceDocumentsIdList,
      'registration_documents_id_list': registrationDocumentsIdList,
      'v_model': vModel,
      'v_mileage': vMileage,
      'create_time': createTime,
      'update_time': updateTime,
    };
  }

  Vehicle copyWith({
    String? vId,
    String? cID,
    String? vName,
    String? vTitle,
    String? vPlateNumber,
    String? vImageUrl,
    String? vVin,
    String? vState,
    String? vCurrentInspectionSticker,
    Timestamp? vLastInspectionDate,
    bool? vActivationStatus,
    String? documentVerificationStatus,
    List<dynamic>? insuranceDocumentsIdList,
    List<dynamic>? registrationDocumentsIdList,
    String? vModel,
    String? vMileage,
    Timestamp? createTime,
    Timestamp? updateTime,
  }) {
    return Vehicle(
      vId: vId ?? this.vId,
      cID: cID ?? this.cID,
      vName: vName ?? this.vName,
      vTitle: vTitle ?? this.vTitle,
      vPlateNumber: vPlateNumber ?? this.vPlateNumber,
      vImageUrl: vImageUrl ?? this.vImageUrl,
      vVin: vVin ?? this.vVin,
      vState: vState ?? this.vState,
      vCurrentInspectionSticker: vCurrentInspectionSticker ?? this.vCurrentInspectionSticker,
      vLastInspectionDate: vLastInspectionDate ?? this.vLastInspectionDate,
      vActivationStatus: vActivationStatus ?? this.vActivationStatus,
      documentVerificationStatus: documentVerificationStatus ?? this.documentVerificationStatus,
      insuranceDocumentsIdList: insuranceDocumentsIdList ?? this.insuranceDocumentsIdList,
      registrationDocumentsIdList: registrationDocumentsIdList ?? this.registrationDocumentsIdList,
      vModel: vModel ?? this.vModel,
      vMileage: vMileage ?? this.vMileage,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }
}
