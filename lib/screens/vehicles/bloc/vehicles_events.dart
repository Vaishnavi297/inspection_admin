part of 'vehicles_bloc.dart';

abstract class VehiclesEvent {}

class FetchVehiclesEvent extends VehiclesEvent {}

class AddVehicleEvent extends VehiclesEvent {
  final String? cID;
  final String? vName;
  final String? vTitle;
  final String? vPlateNumber;
  final String? vImageUrl;
  final String? vVin;
  final String? vState;
  final String? vCurrentInspectionSticker;
  final DateTime? vLastInspectionDate;
  final bool? vActivationStatus;
  final String? documentVerificationStatus;
  final List<dynamic>? insuranceDocumentsIdList;
  final List<dynamic>? registrationDocumentsIdList;
  final String? vModel;
  final String? vMileage;
  AddVehicleEvent({
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
  });
}

class UpdateVehicleEvent extends VehiclesEvent {
  final Vehicle vehicle;
  final String? cID;
  final String? vName;
  final String? vTitle;
  final String? vPlateNumber;
  final String? vImageUrl;
  final String? vVin;
  final String? vState;
  final String? vCurrentInspectionSticker;
  final DateTime? vLastInspectionDate;
  final bool? vActivationStatus;
  final String? documentVerificationStatus;
  final List<dynamic>? insuranceDocumentsIdList;
  final List<dynamic>? registrationDocumentsIdList;
  final String? vModel;
  final String? vMileage;
  UpdateVehicleEvent({
    required this.vehicle,
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
  });
}

class DeleteVehicleEvent extends VehiclesEvent {
  final String vehicleId;
  DeleteVehicleEvent({required this.vehicleId});
}
