part of 'county_bloc.dart';

@immutable
abstract class CountyEvent {}

class FetchCountiesEvent extends CountyEvent {}

class AddCountyEvent extends CountyEvent {
  final String countyName;
  final String countyLowerName;

  AddCountyEvent({required this.countyName, required this.countyLowerName});
}

class UpdateCountyEvent extends CountyEvent {
  final County county;
  final String countyName;
  final String countyLowerName;

  UpdateCountyEvent({required this.county, required this.countyName, required this.countyLowerName});
}

class DeleteCountyEvent extends CountyEvent {
  final String countyId;

  DeleteCountyEvent({required this.countyId});
}

