part of 'inspection_bloc.dart';

abstract class InspectionEvent extends Equatable {
  const InspectionEvent();

  @override
  List<Object?> get props => [];
}

class FetchInspectionsEvent extends InspectionEvent {}

class DeleteInspectionEvent extends InspectionEvent {
  final String inspectionId;
  const DeleteInspectionEvent({required this.inspectionId});

  @override
  List<Object?> get props => [inspectionId];
}
