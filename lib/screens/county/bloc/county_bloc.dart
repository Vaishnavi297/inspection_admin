import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_structure/models/country.dart';
import '../../../data/repositories/county_repository/county_repository.dart';

part 'county_events.dart';
part 'county_states.dart';

class CountyBloc extends Bloc<CountyEvent, CountyState> {
  final CountyRepository _countyRepository;

  CountyBloc() : _countyRepository = CountyRepository.instance, super(CountyInitial()) {
    on<FetchCountiesEvent>(_onFetchCounties);
    on<AddCountyEvent>(_onAddCounty);
    on<UpdateCountyEvent>(_onUpdateCounty);
    on<DeleteCountyEvent>(_onDeleteCounty);
  }

  Future<void> _onFetchCounties(FetchCountiesEvent event, Emitter<CountyState> emit) async {
    emit(CountyLoading());
    try {
      final counties = await _countyRepository.getAllCounties();
      emit(CountyLoaded(counties: counties));
    } catch (e) {
      emit(CountyError(errorMessage: e.toString()));
    }
  }

  Future<void> _onAddCounty(AddCountyEvent event, Emitter<CountyState> emit) async {
    emit(CountyLoading());
    try {
      // Create county with temporary id, will be replaced by Firestore document id
      final county = County(
        countyId: '', 
        countyName: event.countyName,
        countyLowerName: event.countyLowerName,
        createTime: Timestamp.now(),
        updateTime: Timestamp.now(),
      );  
      await _countyRepository.addCounty(county);
      
      // Fetch updated list
      final counties = await _countyRepository.getAllCounties();
      emit(CountyLoaded(counties: counties));
    } catch (e) {
      emit(CountyError(errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateCounty(UpdateCountyEvent event, Emitter<CountyState> emit) async {
    emit(CountyLoading());
    try {
      final updatedCounty = event.county.copyWith(
        countyName: event.countyName,
        updateTime: Timestamp.now(),
        createTime: event.county.createTime,
        countyId: event.county.countyId,
        countryLowerName: event.countyLowerName,
      );
      await _countyRepository.setCounty(event.county.countyId!, updatedCounty);
      
      // Fetch updated list
      final counties = await _countyRepository.getAllCounties();
      emit(CountyLoaded(counties: counties));
    } catch (e) {
      emit(CountyError(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteCounty(DeleteCountyEvent event, Emitter<CountyState> emit) async {
    emit(CountyLoading());
    try {
      await _countyRepository.deleteCounty(event.countyId);
      
      // Fetch updated list
      final counties = await _countyRepository.getAllCounties();
      emit(CountyLoaded(counties: counties));
    } catch (e) {
      emit(CountyError(errorMessage: e.toString()));
    }
  }
}

