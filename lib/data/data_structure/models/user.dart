import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inspection_station/data/data_structure/models/country.dart';

class AppUser {
  final String? cId;
  final String? cName;
  final bool? cActivationStatus;
  final bool? cisCustomerLogout;
  final String? cEmail;
  final String? cMobileNo;
  final DateTime? cDob;
  final String? authenticationToken;
  final String? cProfileImageUrl;
  final double? cCurrentLatitude;
  final double? cCurrentLongitude;
  final County? cCurrentCountyDetails;
  final   Timestamp? createTime;
  final   Timestamp? updateTime;

  AppUser({
    this.cId,
    this.cName,
    this.cActivationStatus = false,
    this.cisCustomerLogout = false,
    this.cEmail,
    this.cMobileNo,
    this.cDob,
    this.authenticationToken,
    this.cCurrentLatitude,
    this.cCurrentLongitude,
    this.cProfileImageUrl,
    this.cCurrentCountyDetails,
    this.createTime,
    this.updateTime,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      cId: json['c_id'],
      cName: json['c_name'],
      cActivationStatus: json['c_activation_status'] ?? false,
      cisCustomerLogout: json['c_is_customer_logout'] ?? false,
      cEmail: json['c_email'],
      cMobileNo: json['c_mobile_no'],
      cProfileImageUrl: json['c_profile_image_url'],
      authenticationToken: json['authentication_token'],
      cCurrentLatitude: json['c_current_latitude'] != null ? (json['c_current_latitude'] as num).toDouble() : null,
      cCurrentLongitude: json['c_current_longitude'] != null ? (json['c_current_longitude'] as num).toDouble() : null,
      cDob: json['customer_dob'] != null ? DateTime.parse(json['customer_dob']) : null,
      cCurrentCountyDetails: json['c_current_county_details'] != null ? County.fromJson(json['c_current_county_details']) : null,
      createTime: json['create_time'],
      updateTime: json['update_time'],
    );
  }

  /// -------------------------
  /// COPY WITH
  /// -------------------------
  AppUser copyWith({
    String? cId,
    String? cName,
    bool? cActivationStatus,
    bool? cisCustomerLogout,
    String? cEmail,
    String? cMobileNo,
    String? authenticationToken,
    String? cProfileImageUrl,
    double? cCurrentLatitude,
    double? cCurrentLongitude,
    County? cCurrentCountyDetails,
    DateTime? cDob,
    Timestamp? createTime,
    Timestamp? updateTime,  
  }) {
    return AppUser(
      cId: cId ?? this.cId,
      cName: cName ?? this.cName,
      cActivationStatus: cActivationStatus ?? this.cActivationStatus,
      cisCustomerLogout: cisCustomerLogout ?? this.cisCustomerLogout,
      cEmail: cEmail ?? this.cEmail,
      cMobileNo: cMobileNo ?? this.cMobileNo,
      cProfileImageUrl: cProfileImageUrl ?? this.cProfileImageUrl,
      authenticationToken: authenticationToken ?? this.authenticationToken,
      cCurrentLatitude: cCurrentLatitude ?? this.cCurrentLatitude,
      cCurrentLongitude: cCurrentLongitude ?? this.cCurrentLongitude,
      cCurrentCountyDetails: cCurrentCountyDetails ?? this.cCurrentCountyDetails,
      cDob: cDob ?? this.cDob,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'c_id': cId,
      'c_name': cName,
      'c_activation_status': cActivationStatus ?? false,
      'c_is_customer_logout': cisCustomerLogout ?? false,
      'c_email': cEmail,
      'c_mobile_no': cMobileNo,
      'authentication_token': authenticationToken,
      'c_current_latitude': cCurrentLatitude,
      'c_current_longitude': cCurrentLongitude,
      'c_profile_image_url': cProfileImageUrl,
      'c_current_county_details': cCurrentCountyDetails != null ? cCurrentCountyDetails!.toJson() : null,
      'customer_dob': cDob?.toIso8601String(),
      'create_time': createTime,
      'update_time': updateTime,
    };
  }
}
