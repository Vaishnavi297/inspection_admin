part of 'vehicles_bloc.dart';

abstract class VehiclesState {}

class VehiclesInitial extends VehiclesState {}

class VehiclesLoading extends VehiclesState {}

class VehiclesLoaded extends VehiclesState {
  final List<Vehicle> vehicles;
  VehiclesLoaded(this.vehicles);
}

class VehiclesError extends VehiclesState {
  final String message;
  VehiclesError(this.message);
}
