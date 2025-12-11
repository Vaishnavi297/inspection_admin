import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

int defaultElevation = 4;
double defaultRadius = 8.0;
double defaultBlurRadius = 4.0;
double defaultSpreadRadius = 1.0;
double defaultAppBarElevation = 4.0;
int passwordLengthGlobal = 6;

Color shadowColorGlobal = Colors.grey.withValues(alpha: 0.2);

double? defaultInkWellRadius;
Color? defaultInkWellSplashColor;
Color? defaultInkWellHoverColor;
Color? defaultInkWellHighlightColor;

/// ENUM FOR PAGE ROUTE
// ignore: constant_identifier_names
enum PageRouteAnimation { Fade, Scale, Rotate, Slide, SlideBottomTop }

/// PAGINATION ANIMATION FOR PAGE ROUTE
PageRouteAnimation? pageRouteAnimationGlobal = PageRouteAnimation.Slide;
// Duration pageRouteTransitionDurationGlobal = 400.milliseconds;

/// GET THE CURRENT CONTEXT FROM THE NAVIGATOR
BuildContext? get getContext => navigatorKey.currentState?.overlay?.context;

/// GET ERROR MESSAGE
String? getErrorMsg(String id) {
  switch (id) {
    case "500":
      return "Internal server error";
    case "400":
      return "Bad request";
    case "1001":
      return "Current password is invalid";
    case "1009":
      return "Verification code is expired";
    case "1002":
      return "Password attempt limit reached, Please try again later after some times.";
    case "1003":
      return "User not found";
    case "1004":
      return "Invalid password";
    case "1005":
      return "User is unauthorized";
    case "1006":
      return "Your account has been flagged for a password reset";
    case "1007":
      return "Invalid verification code";
    case "1008":
      return "You are not authorized to update the password at this time";
    case "1010":
      return "Your profile is inactive, please contact admin!";
    case "1011":
      return "You don't have web app access";
    case "1012":
      return "You cannot delete this because there are existing members";
    case "401":
      return "Invalid email or password";
    default:
      return null;
  }
}
