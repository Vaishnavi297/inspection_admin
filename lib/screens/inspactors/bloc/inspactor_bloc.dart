import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/data_structure/models/inspector.dart';
import '../../../data/repositories/inspector_repository/inspector_repository.dart';

part 'inspactor_events.dart';
part 'inspactor_states.dart';

class InspactorBloc extends Bloc<InspactorEvent, InspactorState> {
  final InspectorRepository _repo;

  InspactorBloc()
    : _repo = InspectorRepository.instance,
      super(InspactorInitial()) {
    on<FetchInspactorsEvent>(_onFetch);
    on<AddInspactorEvent>(_onAdd);
    on<UpdateInspactorEvent>(_onUpdate);
    on<DeleteInspactorEvent>(_onDelete);
    on<ToggleActiveEvent>(_onToggleActive);
  }

  Future<void> _onFetch(
    FetchInspactorsEvent event,
    Emitter<InspactorState> emit,
  ) async {
    emit(InspactorLoading());
    try {
      final list = await _repo.getAllInspectors();
      emit(InspactorLoaded(list));
    } catch (e) {
      emit(InspactorError(e.toString()));
    }
  }

  Future<void> _onAdd(
    AddInspactorEvent event,
    Emitter<InspactorState> emit,
  ) async {
    emit(InspactorLoading());
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
      emit(InspactorLoaded(list));
    } catch (e) {
      emit(InspactorError(e.toString()));
    }
  }

  Future<void> _onUpdate(
    UpdateInspactorEvent event,
    Emitter<InspactorState> emit,
  ) async {
    emit(InspactorLoading());
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
      emit(InspactorLoaded(list));
    } catch (e) {
      emit(InspactorError(e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteInspactorEvent event,
    Emitter<InspactorState> emit,
  ) async {
    emit(InspactorLoading());
    try {
      await _repo.deleteInspectorTransaction(event.inspectorId);
      final list = await _repo.getAllInspectors();
      emit(InspactorLoaded(list));
    } catch (e) {
      emit(InspactorError(e.toString()));
    }
  }

  Future<void> _onToggleActive(
    ToggleActiveEvent event,
    Emitter<InspactorState> emit,
  ) async {
    emit(InspactorLoading());
    try {
      await _repo.toggleActive(event.inspectorId, event.isActive);
      final list = await _repo.getAllInspectors();
      emit(InspactorLoaded(list));
    } catch (e) {
      emit(InspactorError(e.toString()));
    }
  }
}
