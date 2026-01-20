import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_structure/models/inspection.dart';
import '../../../data/repositories/inspection_repository/inspection_repository.dart';

part 'inspection_event.dart';
part 'inspection_state.dart';

class InspectionBloc extends Bloc<InspectionEvent, InspectionState> {
  final InspectionRepository _inspectionRepository =
      InspectionRepository.instance;

  InspectionBloc() : super(InspectionInitial()) {
    on<FetchInspectionsEvent>(_onFetchInspections);
    on<DeleteInspectionEvent>(_onDeleteInspection);
  }

  Future<void> _onFetchInspections(
    FetchInspectionsEvent event,
    Emitter<InspectionState> emit,
  ) async {
    emit(InspectionLoading());
    try {
      final inspections = await _inspectionRepository.getAllInspections();
      emit(InspectionLoaded(inspections: inspections));
    } catch (e) {
      emit(InspectionError(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteInspection(
    DeleteInspectionEvent event,
    Emitter<InspectionState> emit,
  ) async {
    try {
      await _inspectionRepository.deleteInspection(event.inspectionId);
      add(FetchInspectionsEvent());
    } catch (e) {
      emit(InspectionError(errorMessage: e.toString()));
    }
  }
}
