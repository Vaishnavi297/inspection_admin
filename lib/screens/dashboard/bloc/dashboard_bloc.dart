import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/data_structure/models/dashboard_models.dart';
import '../../../data/repositories/dashboard_repository/dashboard_repository.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _repo = DashboardRepository.instance;

  DashboardBloc() : super(DashboardInitial()) {
    on<FetchDashboardData>(_onFetchData);
  }

  Future<void> _onFetchData(FetchDashboardData event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final stats = await _repo.getStats();
      final activities = await _repo.getRecentActivities();
      final stations = await _repo.getTopStations();
      emit(DashboardLoaded(stats: stats, activities: activities, stations: stations));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
