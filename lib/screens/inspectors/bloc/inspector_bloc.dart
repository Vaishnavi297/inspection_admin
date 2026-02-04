import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/data_structure/models/inspector.dart';
import '../../../data/repositories/inspector_repository/inspector_repository.dart';

part 'inspector_events.dart';
part 'inspector_state.dart';

class InspectorBloc extends Bloc<InspectorEvent, InspectorState> {
  final InspectorRepository _repo;

  InspectorBloc()
    : _repo = InspectorRepository.instance,
      super(InspectorInitial()) {
    on<FetchInspectorsEvent>(_onFetch);
    on<AddInspectorEvent>(_onAdd);
    on<UpdateInspectorEvent>(_onUpdate);
    on<DeleteInspectorEvent>(_onDelete);
    on<ToggleActiveEvent>(_onToggleActive);
  }

  Future<void> _onFetch(
    FetchInspectorsEvent event,
    Emitter<InspectorState> emit,
  ) async {
    emit(InspectorLoading());
    try {
      final list = await _repo.getAllInspectors();
      emit(InspectorLoaded(list));
    } catch (e) {
      emit(InspectorError(e.toString()));
    }
  }

  Future<void> _onAdd(
    AddInspectorEvent event,
    Emitter<InspectorState> emit,
  ) async {
    emit(InspectorLoading());
    try {
      final inspector = Inspector(
        inspectorId: '',
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        phone: event.phone,
        badgeId: event.badgeId,
        stationId: event.stationId,
        stationName: event.stationName,
        isActive: true,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );
      await _repo.createInspector(inspector);
      final list = await _repo.getAllInspectors();
      emit(InspectorLoaded(list));
    } catch (e) {
      emit(InspectorError(e.toString()));
    }
  }

  Future<void> _onUpdate(
    UpdateInspectorEvent event,
    Emitter<InspectorState> emit,
  ) async {
    emit(InspectorLoading());
    try {
      final updated = event.inspector.copyWith(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        phone: event.phone,
        badgeId: event.badgeId,
        stationId: event.stationId,
        stationName: event.stationName,
        updatedAt: Timestamp.now(),
      );
      await _repo.updateInspectorTransaction(updated);
      final list = await _repo.getAllInspectors();
      emit(InspectorLoaded(list));
    } catch (e) {
      emit(InspectorError(e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteInspectorEvent event,
    Emitter<InspectorState> emit,
  ) async {
    emit(InspectorLoading());
    try {
      await _repo.deleteInspectorTransaction(event.inspectorId);
      final list = await _repo.getAllInspectors();
      emit(InspectorLoaded(list));
    } catch (e) {
      emit(InspectorError(e.toString()));
    }
  }

  Future<void> _onToggleActive(
    ToggleActiveEvent event,
    Emitter<InspectorState> emit,
  ) async {
    emit(InspectorLoading());
    try {
      await _repo.toggleActive(event.inspectorId, event.isActive);
      final list = await _repo.getAllInspectors();
      emit(InspectorLoaded(list));
    } catch (e) {
      emit(InspectorError(e.toString()));
    }
  }
}
