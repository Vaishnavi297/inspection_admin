import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../../data/data_structure/models/inspection_station.dart';
import '../../../data/repositories/inspection_station_repository/inspection_station_repository.dart';

part 'inspection_station_event.dart';
part 'inspection_station_state.dart';

class InspectionStationBloc
    extends Bloc<InspectionStationEvent, InspectionStationState> {
  final InspectionStationRepository _repo =
      InspectionStationRepository.instance;

  InspectionStationBloc() : super(InspectionStationInitial()) {
    on<FetchInspectionStationsEvent>(_onFetchStations);
    on<AddInspectionStationEvent>(_onAddStation);
    on<UpdateInspectionStationEvent>(_onUpdateStation);
    on<DeleteInspectionStationEvent>(_onDeleteStation);
  }

  Future<void> _onFetchStations(
    FetchInspectionStationsEvent event,
    Emitter<InspectionStationState> emit,
  ) async {
    emit(InspectionStationLoading());
    try {
      final list = await _repo.getAllStations();
      emit(InspectionStationLoaded(list));
    } catch (e) {
      emit(InspectionStationError(e.toString()));
    }
  }

  Future<void> _onAddStation(
    AddInspectionStationEvent event,
    Emitter<InspectionStationState> emit,
  ) async {
    emit(InspectionStationLoading());
    try {
      final stationToSave = event.station.copyWith(
        stationActivationStatus: true,
        createTime: Timestamp.now(),
        updateTime: Timestamp.now(),
      );

      await _repo.addStation(stationToSave);

      final list = await _repo.getAllStations();
      emit(InspectionStationLoaded(list));
    } catch (e, stackTrace) {
      print('Error adding station: $e');
      print('Stack trace: $stackTrace');
      emit(InspectionStationError('Failed to add station: $e'));
    }
  }

  Future<void> _onUpdateStation(
    UpdateInspectionStationEvent event,
    Emitter<InspectionStationState> emit,
  ) async {
    emit(InspectionStationLoading());
    try {
      final updated = event.station.copyWith(
        stationName: event.station.stationName,
        // stationNameLower: event.stationLowerName,
        updateTime: Timestamp.fromDate(DateTime.now()),
        // inspactors: event.inspactors,
        workingHours: event.station.workingHours ?? event.station.workingHours,
      );
      await _repo.setStation(event.station.sId!, updated);
      final list = await _repo.getAllStations();
      emit(InspectionStationLoaded(list));
    } catch (e) {
      emit(InspectionStationError(e.toString()));
    }
  }

  Future<void> _onDeleteStation(
    DeleteInspectionStationEvent event,
    Emitter<InspectionStationState> emit,
  ) async {
    emit(InspectionStationLoading());
    try {
      await _repo.deleteStation(event.stationId);
      final list = await _repo.getAllStations();
      emit(InspectionStationLoaded(list));
    } catch (e) {
      emit(InspectionStationError(e.toString()));
    }
  }
}
