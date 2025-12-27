import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inspection_station/utils/common/responsive_widget.dart';
import 'package:inspection_station/utils/constants/app_colors.dart';
import '../inspaction_station/Inspaction_station_page.dart';
import '../inspaction_station/bloc/inspaction_station_bloc.dart';
import '../inspactors/inspactor_page.dart';
import '../inspactors/bloc/inspactor_bloc.dart';
import 'components/sidebar_component.dart';
import '../dashboard/dashboard_page.dart';
import '../users/users_page.dart';
import '../users/bloc/users_bloc.dart';
import '../county/county_page.dart';
import '../county/bloc/county_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  Widget _contentFor(int index) {
    switch (index) {
      case 0:
        return const DashboardPage();
      case 1:
        return BlocProvider(create: (context) => CountyBloc(), child: const CountyPage());
      case 2:
        return BlocProvider(create: (context) => InspactionStationBloc(), child: const InspactionStationPage());
      case 3:
        return BlocProvider(create: (context) => InspactorBloc(), child: const InspactorsPage());
      case 4:
        return BlocProvider(create: (context) => UsersBloc(), child: const UsersPage());
      case 5:
        return _SectionPlaceholder(title: 'Vehicles');
      case 6:
        return _SectionPlaceholder(title: 'Settings');
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = ResponsiveWidget.isSmallScreen(context);
    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      appBar: isSmall ? AppBar(title: const Text('Inspection WV Admin'), backgroundColor: appColors.backgroundColor, elevation: 0) : null,
      drawer: isSmall
          ? Drawer(
              child: SidebarComponent(
                currentIndex: _currentIndex,
                onSelect: (i) {
                  setState(() => _currentIndex = i);
                  Navigator.of(context).pop();
                },
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isSmall) SidebarComponent(currentIndex: _currentIndex, onSelect: (i) => setState(() => _currentIndex = i)),
          Expanded(child: _contentFor(_currentIndex)),
        ],
      ),
    );
  }
}

class _SectionPlaceholder extends StatelessWidget {
  final String title;
  const _SectionPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title, style: Theme.of(context).textTheme.titleLarge));
  }
}
