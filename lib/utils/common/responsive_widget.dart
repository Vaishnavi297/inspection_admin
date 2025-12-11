import 'package:flutter/material.dart';

class ResponsiveWidget extends StatelessWidget {
  final Widget largeScreen;
  final Widget? mediumScreen;
  final Widget? smallScreen;

  const ResponsiveWidget({super.key, required this.largeScreen, this.mediumScreen, this.smallScreen});

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 800;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 1200 && MediaQuery.of(context).size.height - kToolbarHeight > 500;
  }

  static bool isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 800 && MediaQuery.of(context).size.width <= 1200;
  }

  static bool isLessMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width <= 1200;
  }

  static bool isExtraSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width <= 900;
  }

  static bool isExtraMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width <= 800;
  }

  static bool isMobile(BuildContext context) {
    final platform = Theme.of(context).platform;
    final isMobilePlatform = platform == TargetPlatform.android || platform == TargetPlatform.iOS;
    return isMobilePlatform;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 1024;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return largeScreen;
        } else if (constraints.maxWidth <= 1200 && constraints.maxWidth >= 800) {
          return mediumScreen ?? largeScreen;
        } else {
          return smallScreen ?? largeScreen;
        }
      },
    );
  }
}
