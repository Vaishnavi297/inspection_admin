part of 'inspector_bloc.dart';

abstract class InspectorEvent {}

class FetchInspectorsEvent extends InspectorEvent {}

class AddInspectorEvent extends InspectorEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? badgeId;
  final String stationId;
  final String stationName;
  AddInspectorEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.badgeId,
    required this.stationId,
    required this.stationName,
  });
}

class UpdateInspectorEvent extends InspectorEvent {
  final Inspector inspector;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? badgeId;
  final String stationId;
  final String stationName;
  UpdateInspectorEvent({
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

class DeleteInspectorEvent extends InspectorEvent {
  final String inspectorId;
  DeleteInspectorEvent({required this.inspectorId});
}

class ToggleActiveEvent extends InspectorEvent {
  final String inspectorId;
  final bool isActive;
  ToggleActiveEvent({required this.inspectorId, required this.isActive});
}
