import 'package:flutter/material.dart';
import 'package:inspection_station/utils/common/responsive_widget.dart';
import 'package:inspection_station/utils/constants/app_colors.dart';
import 'components/sidebar_component.dart';
import '../dashboard/dashboard_page.dart';

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
        return _SectionPlaceholder(title: 'County');
      case 2:
        return _SectionPlaceholder(title: 'Stations');
      case 3:
        return _SectionPlaceholder(title: 'Inspactors');
      case 4:
        return _SectionPlaceholder(title: 'Users');
      case 5:
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
