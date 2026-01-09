import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inspection_station/data/data.dart';
import 'package:inspection_station/injections/bloc_injections.dart';
import '/../themes/app_themes.dart';
import 'package:flutter/material.dart';
import 'data/services/local_storage_services/local_storage_services.dart';
import 'firebase_options.dart';
import 'utils/constants/app_strings.dart';
import 'utils/routes/app_routes.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setUrlStrategy(PathUrlStrategy());
  initializeFirebase();
  runApp(const MyApp());
}

void initializeFirebase() async {
  try {
    print('=== FIREBASE DEBUG: Initializing Firebase... ===');
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print('=== FIREBASE DEBUG: Firebase initialized successfully ===');
    await FirebaseCrashlyticsService.initialize();
    await LocalStorageService.instance.init();
    print('=== FIREBASE DEBUG: All services initialized ===');
  } catch (e, stackTrace) {
    print('=== FIREBASE DEBUG: Error initializing Firebase: $e ===');
    print('=== FIREBASE DEBUG: Stack trace: $stackTrace ===');
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: getAllBlocProviders(),
      child: MaterialApp(
        title: appStrings.lblAppName,
        theme: appTheme.lightTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splash,
        routes: getAllRoutes(),
      ),
    );
  }
}
