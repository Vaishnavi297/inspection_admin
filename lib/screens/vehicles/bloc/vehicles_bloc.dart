import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/data_structure/models/vehicle.dart';
import '../../../data/repositories/vehicle_repository/vehicle_repository.dart';

part 'vehicles_events.dart';
part 'vehicles_states.dart';

class VehiclesBloc extends Bloc<VehiclesEvent, VehiclesState> {
  final VehicleRepository _repo;

  VehiclesBloc() : _repo = VehicleRepository.instance, super(VehiclesInitial()) {
    on<FetchVehiclesEvent>(_onFetch);
    on<AddVehicleEvent>(_onAdd);
    on<UpdateVehicleEvent>(_onUpdate);
    on<DeleteVehicleEvent>(_onDelete);
  }

  Future<void> _onFetch(FetchVehiclesEvent event, Emitter<VehiclesState> emit) async {
    emit(VehiclesLoading());
    try {
      final list = await _repo.getAllVehicles();
      emit(VehiclesLoaded(list));
    } catch (e) {
      emit(VehiclesError(e.toString()));
    }
  }

  Future<void> _onAdd(AddVehicleEvent event, Emitter<VehiclesState> emit) async {
    emit(VehiclesLoading());
    try {
      final vehicle = Vehicle(
        cID: event.cID,
        vName: event.vName,
        vTitle: event.vTitle,
        vPlateNumber: event.vPlateNumber,
        vImageUrl: event.vImageUrl,
        vVin: event.vVin,
        vState: event.vState,
        vCurrentInspectionSticker: event.vCurrentInspectionSticker,
        vLastInspectionDate: event.vLastInspectionDate,
        vActivationStatus: event.vActivationStatus,
        documentVerificationStatus: event.documentVerificationStatus,
        insuranceDocumentsIdList: event.insuranceDocumentsIdList,
        registrationDocumentsIdList: event.registrationDocumentsIdList,
        vModel: event.vModel,
        vMileage: event.vMileage,
        createTime: Timestamp.now(),
        updateTime: Timestamp.now(),
      );
      await _repo.addVehicle(vehicle);
      final list = await _repo.getAllVehicles();
      emit(VehiclesLoaded(list));
    } catch (e) {
      emit(VehiclesError(e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateVehicleEvent event, Emitter<VehiclesState> emit) async {
    emit(VehiclesLoading());
    try {
      final updated = event.vehicle.copyWith(
        cID: event.cID,
        vName: event.vName,
        vTitle: event.vTitle,
        vPlateNumber: event.vPlateNumber,
        vImageUrl: event.vImageUrl,
        vVin: event.vVin,
        vState: event.vState,
        vCurrentInspectionSticker: event.vCurrentInspectionSticker,
        vLastInspectionDate: event.vLastInspectionDate,
        vActivationStatus: event.vActivationStatus,
        documentVerificationStatus: event.documentVerificationStatus,
        insuranceDocumentsIdList: event.insuranceDocumentsIdList,
        registrationDocumentsIdList: event.registrationDocumentsIdList,
        vModel: event.vModel,
        vMileage: event.vMileage,
        updateTime: Timestamp.now(),
      );
      await _repo.setVehicle(event.vehicle.vId!, updated);
      final list = await _repo.getAllVehicles();
      emit(VehiclesLoaded(list));
    } catch (e) {
      emit(VehiclesError(e.toString()));
    }
  }

  Future<void> _onDelete(DeleteVehicleEvent event, Emitter<VehiclesState> emit) async {
    emit(VehiclesLoading());
    try {
      await _repo.deleteVehicle(event.vehicleId);
      final list = await _repo.getAllVehicles();
      emit(VehiclesLoaded(list));
    } catch (e) {
      emit(VehiclesError(e.toString()));
    }
  }
}
