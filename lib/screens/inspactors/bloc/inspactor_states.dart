part of 'inspactor_bloc.dart';

abstract class InspactorState {}

class InspactorInitial extends InspactorState {}

class InspactorLoading extends InspactorState {}

class InspactorLoaded extends InspactorState {
  final List<Inspector> inspactors;
  InspactorLoaded(this.inspactors);
}

class InspactorError extends InspactorState {
  final String message;
  InspactorError(this.message);
}
