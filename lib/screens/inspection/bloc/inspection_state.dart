part of 'inspection_bloc.dart';

abstract class InspectionState extends Equatable {
  const InspectionState();

  @override
  List<Object?> get props => [];
}

class InspectionInitial extends InspectionState {}

class InspectionLoading extends InspectionState {}

class InspectionLoaded extends InspectionState {
  final List<Inspection> inspections;
  const InspectionLoaded({required this.inspections});

  @override
  List<Object?> get props => [inspections];
}

class InspectionError extends InspectionState {
  final String errorMessage;
  const InspectionError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
