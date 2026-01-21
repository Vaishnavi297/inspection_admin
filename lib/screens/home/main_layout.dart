import 'package:flutter/material.dart';
import 'package:inspection_station/utils/common/responsive_widget.dart';
import 'package:inspection_station/utils/constants/app_colors.dart';
import 'components/sidebar_component.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    final isSmall = ResponsiveWidget.isSmallScreen(context);
    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      appBar: isSmall
          ? AppBar(
              title: const Text('Inspection WV Admin'),
              backgroundColor: appColors.backgroundColor,
              elevation: 0,
            )
          : null,
      drawer: isSmall
          ? Drawer(child: SidebarComponent(currentIndex: widget.currentIndex))
          : null,
      body: Row(
        children: [
          if (!isSmall) SidebarComponent(currentIndex: widget.currentIndex),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
