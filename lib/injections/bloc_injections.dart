import 'package:flutter_bloc/flutter_bloc.dart';
import '../screens/county/bloc/county_bloc.dart';
import '../screens/inspaction_station/bloc/inspaction_station_bloc.dart';
import '../screens/inspection/bloc/inspection_bloc.dart';
import './../screens/auth/cubit/login_password_visibility_cubit.dart';

import '../screens/auth/bloc/sign_in_bloc.dart';

List<BlocProvider> getAllBlocProviders() {
  return [
    // Provide feature blocs per route to avoid state retention issues
    BlocProvider(create: (context) => LoginPasswordVisibilityCubit()),

    BlocProvider(create: (context) => SignInBloc()),

    BlocProvider(create: (context) => InspactionStationBloc()),
    BlocProvider(create: (context) => CountyBloc()),
    BlocProvider(create: (context) => InspectionBloc()),
  ];
}
