import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../screens/auth/login_page.dart';
import '../../screens/home/main_layout.dart';
import '../../screens/inspectors/bloc/inspector_bloc.dart';
import '../../screens/inspectors/inspector_page.dart';
import '../../screens/splash/splash_page.dart';
import '../../screens/auth/bloc/sign_in_bloc.dart';

import '../../screens/dashboard/dashboard_page.dart';
import '../../screens/county/county_page.dart';
import '../../screens/county/bloc/county_bloc.dart';
import '../../screens/inspection_station/Inspection_station_page.dart';
import '../../screens/inspection_station/bloc/inspection_station_bloc.dart';
import '../../screens/users/users_page.dart';
import '../../screens/users/bloc/users_bloc.dart';
import '../../screens/vehicles/vehicles_page.dart';
import '../../screens/vehicles/bloc/vehicles_bloc.dart';
import '../../screens/inspections/inspection_page.dart';
import '../../screens/inspections/bloc/inspection_bloc.dart';
import '../../screens/states/state_list_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String county = '/county';
  static const String stations = '/stations';
  static const String inspectors = '/inspectors';
  static const String users = '/users';
  static const String vehicles = '/vehicles';
  static const String inspections = '/inspections';
  static const String states = '/states';

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: splash,
    routes: [
      GoRoute(path: splash, builder: (context, state) => const SplashPage()),
      GoRoute(
        path: login,
        builder: (context, state) =>
            BlocProvider(create: (_) => SignInBloc(), child: const LoginPage()),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          int index = 0;
          final location = state.uri.path;
          if (location == AppRoutes.dashboard)
            index = 0;
          else if (location == AppRoutes.county)
            index = 1;
          else if (location == AppRoutes.stations)
            index = 2;
          else if (location == AppRoutes.inspectors)
            index = 3;
          else if (location == AppRoutes.users)
            index = 4;
          else if (location == AppRoutes.vehicles)
            index = 5;
          else if (location == AppRoutes.inspections)
            index = 6;
          else if (location == AppRoutes.states)
            index = 7;

          return MainLayout(currentIndex: index, child: child);
        },
        routes: [
          GoRoute(
            path: dashboard,
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: county,
            builder: (context, state) => BlocProvider(
              create: (context) => CountyBloc(),
              child: const CountyPage(),
            ),
          ),
          GoRoute(
            path: stations,
            builder: (context, state) => BlocProvider(
              create: (context) => InspectionStationBloc(),
              child: const InspectionStationPage(),
            ),
          ),
          GoRoute(
            path: inspectors,
            builder: (context, state) => BlocProvider(
              create: (context) => InspectorBloc(),
              child: const InspectorPage(),
            ),
          ),
          GoRoute(
            path: users,
            builder: (context, state) => BlocProvider(
              create: (context) => UsersBloc(),
              child: const UsersPage(),
            ),
          ),
          GoRoute(
            path: vehicles,
            builder: (context, state) => BlocProvider(
              create: (context) => VehiclesBloc(),
              child: const VehiclesPage(),
            ),
          ),
          GoRoute(
            path: inspections,
            builder: (context, state) => BlocProvider(
              create: (context) => InspectionBloc(),
              child: const InspectionPage(),
            ),
          ),
          GoRoute(
            path: states,
            builder: (context, state) => const StateListPage(),
          ),
        ],
      ),
    ],
  );
}
