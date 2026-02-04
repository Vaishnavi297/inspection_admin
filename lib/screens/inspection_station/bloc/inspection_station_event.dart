part of 'inspection_station_bloc.dart';

sealed class InspectionStationEvent extends Equatable {
  const InspectionStationEvent();

  @override
  List<Object> get props => [];
}

class AddInspectionStationEvent extends InspectionStationEvent {
  final InspectionStation station;

  const AddInspectionStationEvent({required this.station});
}

class FetchInspectionStationsEvent extends InspectionStationEvent {
  const FetchInspectionStationsEvent();
}

class UpdateInspectionStationEvent extends InspectionStationEvent {
  final InspectionStation station;

  const UpdateInspectionStationEvent({required this.station});
}

class DeleteInspectionStationEvent extends InspectionStationEvent {
  final String stationId;

  const DeleteInspectionStationEvent({required this.stationId});
}
