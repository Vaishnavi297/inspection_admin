import '../../screens/auth/login_page.dart';
import '../../screens/home/home.dart';
import '../../screens/splash/splash_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home='/home';
}

Map<String, Widget Function(BuildContext)> getAllRoutes() {
  return {
    AppRoutes.splash: (_) => SplashPage(),
    AppRoutes.login: (_) => LoginPage(),
    AppRoutes.home: (_) => HomePage(),

  };
}
