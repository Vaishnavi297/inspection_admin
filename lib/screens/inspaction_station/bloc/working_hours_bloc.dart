import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/data_structure/models/inspaction_station.dart';

class WorkingHoursState extends Equatable {
  final Set<String> selectedDays;
  final Map<String, String> startTimes;
  final Map<String, String> endTimes;
  final Map<String, String?> errors;

  const WorkingHoursState({this.selectedDays = const {}, this.startTimes = const {}, this.endTimes = const {}, this.errors = const {}});

  WorkingHoursState copyWith({Set<String>? selectedDays, Map<String, String>? startTimes, Map<String, String>? endTimes, Map<String, String?>? errors}) {
    return WorkingHoursState(selectedDays: selectedDays ?? this.selectedDays, startTimes: startTimes ?? this.startTimes, endTimes: endTimes ?? this.endTimes, errors: errors ?? this.errors);
  }

  @override
  List<Object?> get props => [selectedDays, startTimes, endTimes, errors];
}

abstract class WorkingHoursEvent extends Equatable {
  const WorkingHoursEvent();
  @override
  List<Object?> get props => [];
}

class ToggleDayEvent extends WorkingHoursEvent {
  final String day; // mon..sun
  const ToggleDayEvent(this.day);
  @override
  List<Object?> get props => [day];
}

class SetStartEvent extends WorkingHoursEvent {
  final String day;
  final String hhmm; // 24h format
  const SetStartEvent(this.day, this.hhmm);
  @override
  List<Object?> get props => [day, hhmm];
}

class SetEndEvent extends WorkingHoursEvent {
  final String day;
  final String hhmm;
  const SetEndEvent(this.day, this.hhmm);
  @override
  List<Object?> get props => [day, hhmm];
}

class SelectAllEvent extends WorkingHoursEvent {
  const SelectAllEvent();
}

class ValidateEvent extends WorkingHoursEvent {
  const ValidateEvent();
}

class SeedFromJsonEvent extends WorkingHoursEvent {
  final WorkingHours? json;
  const SeedFromJsonEvent(this.json);
  @override
  List<Object?> get props => [json];
}

class WorkingHoursBloc extends Bloc<WorkingHoursEvent, WorkingHoursState> {
  static const daysOrder = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  static const dayLabels = {'mon': 'MON', 'tue': 'TUE', 'wed': 'WED', 'thu': 'THU', 'fri': 'FRI', 'sat': 'SAT', 'sun': 'SUN'};

  WorkingHoursBloc([WorkingHours? initialData]) : super(const WorkingHoursState()) {
    on<ToggleDayEvent>(_onToggleDay);
    on<SetStartEvent>(_onSetStart);
    on<SetEndEvent>(_onSetEnd);
    on<ValidateEvent>(_onValidate);
    on<SeedFromJsonEvent>(_onSeedFromJson);
    on<SelectAllEvent>(_onSelectAll);
    if (initialData != null) {
      add(SeedFromJsonEvent(initialData));
    }
  }

  void _onSeedFromJson(SeedFromJsonEvent event, Emitter<WorkingHoursState> emit) {
    if (event.json == null) return;
    emit(WorkingHoursState(selectedDays: event.json!.selectedDays, startTimes: event.json!.startTimes, endTimes: event.json!.endTimes));
  }

  void _onToggleDay(ToggleDayEvent event, Emitter<WorkingHoursState> emit) {
    final next = Set<String>.from(state.selectedDays);
    if (next.contains(event.day)) {
      next.remove(event.day);
    } else {
      next.add(event.day);
    }
    final errs = Map<String, String?>.from(state.errors)..remove(event.day);
    emit(state.copyWith(selectedDays: next, errors: errs));
  }

  void _onSetStart(SetStartEvent event, Emitter<WorkingHoursState> emit) {
    final starts = Map<String, String>.from(state.startTimes);
    starts[event.day] = event.hhmm;
    final errs = Map<String, String?>.from(state.errors)..remove(event.day);
    emit(state.copyWith(startTimes: starts, errors: errs));
  }

  void _onSetEnd(SetEndEvent event, Emitter<WorkingHoursState> emit) {
    final ends = Map<String, String>.from(state.endTimes);
    ends[event.day] = event.hhmm;
    final errs = Map<String, String?>.from(state.errors)..remove(event.day);
    emit(state.copyWith(endTimes: ends, errors: errs));
  }

  void _onSelectAll(SelectAllEvent event, Emitter<WorkingHoursState> emit) {
    final allDays = Set<String>.from(daysOrder);
    
    // Find the first available start and end time from selected days
    String? defaultStartTime;
    String? defaultEndTime;
    
    // Look through selected days first to find existing times
    for (final day in state.selectedDays) {
      final start = state.startTimes[day];
      final end = state.endTimes[day];
      if (start != null && end != null) {
        defaultStartTime = start;
        defaultEndTime = end;
        break;
      }
    }
    
    // If no times found in selected days, look through all days
    if (defaultStartTime == null || defaultEndTime == null) {
      for (final day in daysOrder) {
        final start = state.startTimes[day];
        final end = state.endTimes[day];
        if (start != null && end != null) {
          defaultStartTime = start;
          defaultEndTime = end;
          break;
        }
      }
    }
    
    // If still no times found, use default working hours (9:00 - 17:00)
    final startTime = defaultStartTime ?? '09:00';
    final endTime = defaultEndTime ?? '17:00';
    
    // Apply the same start and end times to all days
    final allStartTimes = <String, String>{};
    final allEndTimes = <String, String>{};
    final clearedErrors = <String, String?>{};
    
    for (final day in allDays) {
      allStartTimes[day] = startTime;
      allEndTimes[day] = endTime;
      clearedErrors[day] = null;
    }
    
    emit(state.copyWith(
      selectedDays: allDays,
      startTimes: allStartTimes,
      endTimes: allEndTimes,
      errors: clearedErrors,
    ));
  }

  void _onValidate(ValidateEvent event, Emitter<WorkingHoursState> emit) {
    final errs = <String, String?>{};
    for (final day in daysOrder) {
      if (!state.selectedDays.contains(day)) continue;
      final s = state.startTimes[day];
      final e = state.endTimes[day];
      if (s == null || e == null) {
        errs[day] = 'Select start and end time';
        continue;
      }
      if (!_isEndAfterStart(s, e)) {
        errs[day] = 'End time must be after start';
      }
    }
    emit(state.copyWith(errors: errs));
  }

  WorkingHours toWorkingHours() {
    return WorkingHours(selectedDays: state.selectedDays, startTimes: state.startTimes, endTimes: state.endTimes);
  }

  static bool _isEndAfterStart(String s, String e) {
    int _toMinutes(String hhmm) {
      final parts = hhmm.split(':');
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      return h * 60 + m;
    }
    return _toMinutes(e) > _toMinutes(s);
  }
}
