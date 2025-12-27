part of 'inspactor_bloc.dart';

abstract class InspactorEvent {}

class FetchInspactorsEvent extends InspactorEvent {}

class AddInspactorEvent extends InspactorEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? badgeId;
  final String stationId;
  final String stationName;
  AddInspactorEvent({required this.firstName, required this.lastName, required this.email, required this.phone, this.badgeId, required this.stationId, required this.stationName});
}

class UpdateInspactorEvent extends InspactorEvent {
  final Inspector inspector;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? badgeId;
  final String stationId;
  final String stationName;
  UpdateInspactorEvent({
    required this.inspector,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.badgeId,
    required this.stationId,
    required this.stationName,
  });
}

class DeleteInspactorEvent extends InspactorEvent {
  final String inspectorId;
  DeleteInspactorEvent({required this.inspectorId});
}

class ToggleActiveEvent extends InspactorEvent {
  final String inspectorId;
  final bool isActive;
  ToggleActiveEvent({required this.inspectorId, required this.isActive});
}
