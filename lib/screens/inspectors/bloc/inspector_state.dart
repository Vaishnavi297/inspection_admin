part of 'inspector_bloc.dart';

abstract class InspectorState {}

class InspectorInitial extends InspectorState {}

class InspectorLoading extends InspectorState {}

class InspectorLoaded extends InspectorState {
  final List<Inspector> inspectors;
  InspectorLoaded(this.inspectors);
}

class InspectorError extends InspectorState {
  final String message;
  InspectorError(this.message);
}
