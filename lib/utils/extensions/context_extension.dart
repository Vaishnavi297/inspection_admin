import 'package:flutter/material.dart';

double? maxScreenWidth;

extension ContextExtensions on BuildContext {
  /// return the transaction string
  // AppLocalizations get trs => AppLocalizations.of(this)!;

  /// RETURN SCREEN SIZE
  Size size() => MediaQuery.of(this).size;

  /// RETURN SCREEN WIDTH
  double width() => maxScreenWidth ?? MediaQuery.of(this).size.width;

  /// RETURN SCREEN HEIGHT
  double height() => MediaQuery.of(this).size.height;

  /// RETURN SCREEN DEVICE PIXEL RATIO
  double pixelRatio() => MediaQuery.of(this).devicePixelRatio;

  /// RETURNS BRIGHTNESS
  Brightness platformBrightness() => MediaQuery.of(this).platformBrightness;

  /// RETURN THE HEIGHT OF STATUS BAR
  double get statusBarHeight => MediaQuery.of(this).padding.top;

  /// RETURN THE HEIGHT OF NAVIGATION BAR
  double get navigationBarHeight => MediaQuery.of(this).padding.bottom;

  /// RETURNS Theme.of(context)
  ThemeData get theme => Theme.of(this);

  /// RETURNS Theme.of(context).textTheme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// RETURNS DefaultTextStyle.of(context)
  DefaultTextStyle get defaultTextStyle => DefaultTextStyle.of(this);

  /// RETURNS Form.of(context)
  FormState? get formState => Form.of(this);

  /// RETURNS Scaffold.of(context)
  ScaffoldState get scaffoldState => Scaffold.of(this);

  /// RETURNS Overlay.of(context)
  OverlayState? get overlayState => Overlay.of(this);

  /// RETURNS PRIMARY COLOR
  Color get primaryColor => theme.primaryColor;

  /// RETURNS ACCENT COLOR
  Color get accentColor => theme.colorScheme.secondary;

  /// RETURNS SCAFFOLD BACKGROUND COLOR
  Color get scaffoldBackgroundColor => theme.scaffoldBackgroundColor;

  /// RETURNS CARD COLOR
  Color get cardColor => theme.cardColor;

  /// RETURNS DIVIDER COLOR
  Color get dividerColor => theme.dividerColor;

  /// RETURNS ICON COLOR
  Color get iconColor => theme.iconTheme.color!;

  /// REQUEST FOCUS TO GIVEN FOCUS NODE
  void requestFocus(FocusNode focus) {
    FocusScope.of(this).requestFocus(focus);
  }

  /// REQUEST FOCUS TO GIVEN FOCUS NODE
  void unFocus(FocusNode focus) {
    focus.unfocus();
  }

  // bool isPhone() => MediaQuery.of(this).size.width < tabletBreakpointGlobal;
  // bool isTablet() =>
  //     MediaQuery.of(this).size.width < desktopBreakpointGlobal &&
  //     MediaQuery.of(this).size.width >= tabletBreakpointGlobal;
  // /// Return true if the platform is Desktop
  // bool isDesktop() => MediaQuery.of(this).size.width >= desktopBreakpointGlobal;

  Orientation get orientation => MediaQuery.of(this).orientation;

  /// RETURN TRUE IF CURRENT ORIENTATION IS LANDSCAPE
  bool get isLandscape => orientation == Orientation.landscape;

  /// /// RETURN TRUE IF CURRENT ORIENTATION IS PORTRAIT
  bool get isPortrait => orientation == Orientation.portrait;

  bool get canPop => Navigator.canPop(this);

  void pop<T extends Object>([T? result]) => Navigator.pop(this, result);

  TargetPlatform get platform => Theme.of(this).platform;

  /// RETURN TRUE IF THE PLATFORM IS Android
  bool get isAndroid => platform == TargetPlatform.android;

  /// RETURN TRUE IF THE PLATFORM IS iOS
  bool get isIOS => platform == TargetPlatform.iOS;

  /// RETURN TRUE IF THE PLATFORM IS MacOS
  bool get isMacOS => platform == TargetPlatform.macOS;

  /// RETURN TRUE IF THE PLATFORM IS WINDOWS
  bool get isWindows => platform == TargetPlatform.windows;

  /// RETURN TRUE IF THE PLATFORM IS FUCHSIA
  bool get isFuchsia => platform == TargetPlatform.fuchsia;

  /// RETURN TRUE IF THE PLATFORM IS LINUX
  bool get isLinux => platform == TargetPlatform.linux;

  /// OPEN DRAWER
  void openDrawer() => Scaffold.of(this).openDrawer();

  /// HIDE DRAWER
  void openEndDrawer() => Scaffold.of(this).openEndDrawer();

  /// RETURN TRUE IF KEYBOARD IS VISIBLE
  bool get isKeyboardShowing => MediaQuery.of(this).viewInsets.bottom > 0;
}
