import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../screens/auth/login_page.dart';
import '../../screens/home/home.dart';
import '../../screens/home/main_layout.dart';
import '../../screens/splash/splash_page.dart';
import '../../screens/auth/bloc/sign_in_bloc.dart';

import '../../screens/dashboard/dashboard_page.dart';
import '../../screens/county/county_page.dart';
import '../../screens/county/bloc/county_bloc.dart';
import '../../screens/inspaction_station/Inspaction_station_page.dart';
import '../../screens/inspaction_station/bloc/inspaction_station_bloc.dart';
import '../../screens/inspactors/inspactor_page.dart';
import '../../screens/inspactors/bloc/inspactor_bloc.dart';
import '../../screens/users/users_page.dart';
import '../../screens/users/bloc/users_bloc.dart';
import '../../screens/vehicles/vehicles_page.dart';
import '../../screens/vehicles/bloc/vehicles_bloc.dart';
import '../../screens/inspection/inspection_page.dart';
import '../../screens/inspection/bloc/inspection_bloc.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String county = '/county';
  static const String stations = '/stations';
  static const String inspectors = '/inspectors';
  static const String users = '/users';
  static const String vehicles = '/vehicles';
  static const String inspections = '/inspections';
}

Map<String, Widget Function(BuildContext)> getAllRoutes() {
  return {
    AppRoutes.splash: (context) => const SplashPage(),
    AppRoutes.login: (context) =>
        BlocProvider(create: (_) => SignInBloc(), child: const LoginPage()),
    AppRoutes.home: (context) => const HomePage(),
    AppRoutes.dashboard: (context) =>
        const MainLayout(currentIndex: 0, child: DashboardPage()),
    AppRoutes.county: (context) => BlocProvider(
      create: (context) => CountyBloc(),
      child: const MainLayout(currentIndex: 1, child: CountyPage()),
    ),
    AppRoutes.stations: (context) => BlocProvider(
      create: (context) => InspactionStationBloc(),
      child: const MainLayout(currentIndex: 2, child: InspactionStationPage()),
    ),
    AppRoutes.inspectors: (context) => BlocProvider(
      create: (context) => InspactorBloc(),
      child: const MainLayout(currentIndex: 3, child: InspactorsPage()),
    ),
    AppRoutes.users: (context) => BlocProvider(
      create: (context) => UsersBloc(),
      child: const MainLayout(currentIndex: 4, child: UsersPage()),
    ),
    AppRoutes.vehicles: (context) => BlocProvider(
      create: (context) => VehiclesBloc(),
      child: const MainLayout(currentIndex: 5, child: VehiclesPage()),
    ),
    AppRoutes.inspections: (context) => BlocProvider(
      create: (context) => InspectionBloc(),
      child: const MainLayout(currentIndex: 6, child: InspectionPage()),
    ),
  };
}
