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

  const UpdateInspactionStationEvent({required this.station});
}

class DeleteInspactionStationEvent extends InspactionStationEvent {
  final String stationId;

  const DeleteInspactionStationEvent({required this.stationId});
}
