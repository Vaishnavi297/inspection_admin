import '../../screens/auth/login_page.dart';
import '../../screens/home/home.dart';
import '../../screens/splash/splash_page.dart';
import '../../screens/auth/bloc/sign_in_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
}

Map<String, Widget Function(BuildContext)> getAllRoutes() {
  return {AppRoutes.splash: (context) => SplashPage(), AppRoutes.login: (context) => BlocProvider(create: (_) => SignInBloc(), child: const LoginPage()), AppRoutes.home: (context) => HomePage()};
}
