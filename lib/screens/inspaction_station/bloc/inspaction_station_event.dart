part of 'inspaction_station_bloc.dart';

sealed class InspactionStationEvent extends Equatable {
  const InspactionStationEvent();

  @override
  List<Object> get props => [];
}

class AddInspactionStationEvent extends InspactionStationEvent {
  final InspactionStation station;

  const AddInspactionStationEvent({required this.station});
}

class FetchInspactionStationsEvent extends InspactionStationEvent {
  const FetchInspactionStationsEvent();
}

class UpdateInspactionStationEvent extends InspactionStationEvent {
  final InspactionStation station;
  final String stationName;
  final String stationLowerName;
  final int maxInspectors;

  const UpdateInspactionStationEvent({required this.station, required this.stationName, required this.stationLowerName, required this.maxInspectors});
}

class DeleteInspactionStationEvent extends InspactionStationEvent {
  final String stationId;

  const DeleteInspactionStationEvent({required this.stationId});
}
