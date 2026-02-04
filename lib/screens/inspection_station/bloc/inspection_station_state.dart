part of 'inspection_station_bloc.dart';

sealed class InspectionStationState extends Equatable {
  const InspectionStationState();

  @override
  List<Object> get props => [];
}

final class InspectionStationInitial extends InspectionStationState {}

final class InspectionStationLoading extends InspectionStationState {}

final class InspectionStationLoaded extends InspectionStationState {
  final List<InspectionStation> inspectionStations;
  const InspectionStationLoaded(this.inspectionStations);
}

final class InspectionStationError extends InspectionStationState {
  final String errorMessage;
  const InspectionStationError(this.errorMessage);
}
