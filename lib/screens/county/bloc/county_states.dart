part of 'county_bloc.dart';

@immutable
sealed class CountyState {}

final class CountyInitial extends CountyState {}

final class CountyLoading extends CountyState {}

final class CountyLoaded extends CountyState {
  final List<County> counties;

  CountyLoaded({required this.counties});
}

final class CountyError extends CountyState {
  final String errorMessage;

  CountyError({required this.errorMessage});
}

