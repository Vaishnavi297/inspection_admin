import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

class ValidateEvent extends WorkingHoursEvent {
  const ValidateEvent();
}

class WorkingHoursBloc extends Bloc<WorkingHoursEvent, WorkingHoursState> {
  static const daysOrder = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  static const dayLabels = {'mon': 'MON', 'tue': 'TUE', 'wed': 'WED', 'thu': 'THU', 'fri': 'FRI', 'sat': 'SAT', 'sun': 'SUN'};

  WorkingHoursBloc() : super(const WorkingHoursState()) {
    on<ToggleDayEvent>(_onToggleDay);
    on<SetStartEvent>(_onSetStart);
    on<SetEndEvent>(_onSetEnd);
    on<ValidateEvent>(_onValidate);
  }

  WorkingHoursBloc seedFromJson(Map<String, dynamic>? json) {
    if (json == null) return this;
    final selected = <String>{};
    final starts = <String, String>{};
    final ends = <String, String>{};
    for (final day in daysOrder) {
      final entry = json[day];
      if (entry is Map && entry['closed'] != true) {
        selected.add(day);
        final s = entry['start'];
        final e = entry['end'];
        if (s is String) starts[day] = s;
        if (e is String) ends[day] = e;
      }
    }
    // ignore: invalid_use_of_visible_for_testing_member
    emit(WorkingHoursState(selectedDays: selected, startTimes: starts, endTimes: ends));
    return this;
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
    emit(state.copyWith(startTimes: starts));
  }

  void _onSetEnd(SetEndEvent event, Emitter<WorkingHoursState> emit) {
    final ends = Map<String, String>.from(state.endTimes);
    ends[event.day] = event.hhmm;
    emit(state.copyWith(endTimes: ends));
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
      if (!_isEndAfterStart(s, e) == false) {
        errs[day] = 'End time must be after start';
      }
    }
    emit(state.copyWith(errors: errs));
  }

  Map<String, dynamic> toApiJson() {
    final map = <String, dynamic>{};
    for (final day in daysOrder) {
      if (state.selectedDays.contains(day)) {
        map[day] = {'start': state.startTimes[day], 'end': state.endTimes[day], 'closed': false};
      } else {
        map[day] = {'closed': true};
      }
    }
    return map;
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
