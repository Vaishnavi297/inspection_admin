part of 'inspaction_station_bloc.dart';

sealed class InspactionStationState extends Equatable {
  const InspactionStationState();

  @override
  List<Object> get props => [];
}

final class InspactionStationInitial extends InspactionStationState {}

final class InspactionStationLoading extends InspactionStationState {}

final class InspactionStationLoaded extends InspactionStationState {
  final List<InspactionStation> inspactionStations;
  const InspactionStationLoaded(this.inspactionStations);
}

final class InspactionStationError extends InspactionStationState {
  final String errorMessage;
  const InspactionStationError(this.errorMessage);
}
