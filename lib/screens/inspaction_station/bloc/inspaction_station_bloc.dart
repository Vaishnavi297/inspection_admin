import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../../data/data_structure/models/inspaction_station.dart';
import '../../../data/repositories/inspaction_station_repository/inspaction_station_repository.dart';

part 'inspaction_station_event.dart';
part 'inspaction_station_state.dart';

class InspactionStationBloc extends Bloc<InspactionStationEvent, InspactionStationState> {
  final InspactionStationRepository _repo = InspactionStationRepository.instance;

  InspactionStationBloc() : super(InspactionStationInitial()) {
    on<FetchInspactionStationsEvent>(_onFetchStations);
    on<AddInspactionStationEvent>(_onAddStation);
    on<UpdateInspactionStationEvent>(_onUpdateStation);
    on<DeleteInspactionStationEvent>(_onDeleteStation);
  }

  Future<void> _onFetchStations(FetchInspactionStationsEvent event, Emitter<InspactionStationState> emit) async {
    emit(InspactionStationLoading());
    try {
      final list = await _repo.getAllStations();
      emit(InspactionStationLoaded(list));
    } catch (e) {
      emit(InspactionStationError(e.toString()));
    }
  }

  Future<void> _onAddStation(AddInspactionStationEvent event, Emitter<InspactionStationState> emit) async {
    emit(InspactionStationLoading());
    try {
      final station = InspactionStation(
        stationId: event.station.stationId,
        stationName: event.station.stationName,
        // stationNameLower: event.station.stationNameLower,
        stationActivationStatus: true,
        sCountyDetails: event.station.sCountyDetails,
        stationAddress: event.station.stationAddress,
        stationContactNumber: event.station.stationContactNumber,
        workingHours: event.station.workingHours,
        stationDescription: event.station.stationDescription,
        createTime: Timestamp.now(),
        updateTime: Timestamp.now(),
        maxInspectors: event.station.maxInspectors,
      );
      await _repo.addStation(station);
      final list = await _repo.getAllStations();
      emit(InspactionStationLoaded(list));
    } catch (e) {
      emit(InspactionStationError(e.toString()));
    }
  }

  Future<void> _onUpdateStation(UpdateInspactionStationEvent event, Emitter<InspactionStationState> emit) async {
    emit(InspactionStationLoading());
    try {
      final updated = event.station.copyWith(
        stationName: event.stationName,
        // stationNameLower: event.stationLowerName,
        updateTime: Timestamp.fromDate(DateTime.now()),
        maxInspectors: event.maxInspectors,
        workingHours: event.station.workingHours ?? event.station.workingHours,
      );
      await _repo.setStation(event.station.sId!, updated);
      final list = await _repo.getAllStations();
      emit(InspactionStationLoaded(list));
    } catch (e) {
      emit(InspactionStationError(e.toString()));
    }
  }

  Future<void> _onDeleteStation(DeleteInspactionStationEvent event, Emitter<InspactionStationState> emit) async {
    emit(InspactionStationLoading());
    try {
      await _repo.deleteStation(event.stationId);
      final list = await _repo.getAllStations();
      emit(InspactionStationLoaded(list));
    } catch (e) {
      emit(InspactionStationError(e.toString()));
    }
  }
}
