part of 'dashboard_bloc.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  
  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final List<DashboardActivity> activities;
  final List<DashboardTopStation> stations;

  const DashboardLoaded({
    required this.stats,
    required this.activities,
    required this.stations,
  });

  @override
  List<Object> get props => [stats, activities, stations];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}
