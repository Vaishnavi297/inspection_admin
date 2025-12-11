import '/../themes/app_themes.dart';

import 'package:flutter/material.dart';
import 'utils/constants/app_strings.dart';
import 'utils/routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appStrings.lblAppName,
      theme: appTheme.lightTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      routes: getAllRoutes(),
     
    );
  }
}
