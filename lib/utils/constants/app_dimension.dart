// ignore_for_file: camel_case_types
import 'package:flutter/material.dart';

Size screenSize = const Size(360, 690);
double defaultScreenWidth = 750.0;
double defaultScreenHeight = 1334.0;
double screensWidth = defaultScreenWidth;
double screensHeight = defaultScreenHeight;

/// PADDING & MARGIN CONSTANTS
class s {
  static double s0 = 0;
  static double s0_5 = 0.5;
  static double s1 = 1.0;
  static double s1_5 = 1.5;
  static double s2 = 2.0;
  static double s3 = 3.0;
  static double s4 = 4.0;
  static double s5 = 5.0;
  static double s6 = 6.0;
  static double s7 = 7.0;
  static double s8 = 8.0;
  static double s9 = 9.0;
  static double s10 = 10.0;
  static double s11 = 11.0;
  static double s12 = 12.0;
  static double s13 = 13.0;
  static double s14 = 14.0;
  static double s15 = 15.0;
  static double s16 = 16.0;
  static double s17 = 17.0;
  static double s18 = 18.0;
  static double s19 = 19.0;
  static double s20 = 20.0;
  static double s21 = 21.0;
  static double s22 = 22.0;
  static double s23 = 23.0;
  static double s24 = 24.0;
  static double s25 = 25.0;
  static double s26 = 26.0;
  static double s28 = 28.0;
  static double s30 = 30.0;
  static double s31 = 31.0;
  static double s32 = 32.0;
  static double s35 = 35.0;
  static double s36 = 36.0;
  static double s38 = 38.0;
  static double s40 = 40.0;
  static double s42 = 42.0;
  static double s44 = 44.0;
  static double s45 = 45.0;
  static double s47 = 47.0;
  static double s50 = 50.0;
  static double s55 = 55.0;
  static double s48 = 48.0;
  static double s56 = 56.0;
  static double s60 = 60.0;
  static double s62 = 62.0;
  static double s64 = 64.0;
  static double s70 = 70.0;
  static double s72 = 72.0;
  static double s80 = 80.0;
  static double s85 = 85.0;
  static double s88 = 88.0;
  static double s90 = 90.0;
  static double s100 = 100.0;
  static double s105 = 105.0;
  static double s110 = 110.0;
  static double s120 = 120.0;
  static double s128 = 128.0;
  static double s130 = 130.0;
  static double s138 = 138.0;
  static double s140 = 140.0;
  static double s150 = 150.0;
  static double s160 = 160.0;
  static double s164 = 164.0;
  static double s180 = 180.0;
  static double s200 = 200.0;
  static double s205 = 205.0;
  static double s210 = 210.0;
  static double s220 = 220.0;
  static double s240 = 240.0;
  static double s250 = 250.0;
  static double s260 = 260.0;
  static double s275 = 275.0;
  static double s280 = 280.0;
  static double s290 = 290.0;
  static double s300 = 300.0;
  static double s310 = 310.0;
  static double s320 = 320.0;
  static double s330 = 330.0;
  static double s340 = 340.0;
  static double s350 = 350.0;
  static double s360 = 360.0;
  static double s380 = 380.0;
  static double s328 = 328.0;
  static double s400 = 400.0;
  static double s420 = 420.0;
  static double s430 = 430.0;
  static double s450 = 450.0;
  static double s470 = 470.0;
  static double s490 = 490.0;
  static double s500 = 500.0;
  static double s520 = 520.0;
  static double s530 = 530.0;
  static double s550 = 550.0;
  static double s600 = 600.0;
  static double s965 = 965.0;
  static double s1000 = 1000.0;

  /// SCREEN S DEPENDENT CONSTANTS
  static double screenWidthButton = screensWidth - s64;
  static double screenWidthHalf = screensWidth / 2;
  static double screenWidthThird = screensWidth / 3;
  static double screenWidthFourth = screensWidth / 4;
  static double screenWidthFifth = screensWidth / 5;
  static double screenWidthSixth = screensWidth / 6;
  static double screenWidthTenth = screensWidth / 10;

  /// IMAGE DIMENSIONS
  static double defaultIconSize = 80.0;
  static double defaultImageHeight = 120.0;
  static double snackBarHeight = 50.0;
  static double texIconSize = 30.0;

  /// DEFAULT HEIGHT & WIDTH
  static double defaultIndicatorHeight = 5.0;
  static double defaultIndicatorWidth = screenWidthFourth;

  /// EDGE INSETS
  static EdgeInsets spacingAllDefault = EdgeInsets.all(s8);
  static EdgeInsets spacingAllSmall = EdgeInsets.all(s12);
}

/// APP FONT SIZE
class FontSize {
  static double s7 = 7.0;
  static double s8 = 8.0;
  static double s9 = 9.0;
  static double s10 = 10.0;
  static double s11 = 11.0;
  static double s12 = 12.0;
  static double s13 = 13.0;
  static double s14 = 14.0;
  static double s15 = 15.0;
  static double s16 = 16.0;
  static double s17 = 17.0;
  static double s18 = 18.0;
  static double s19 = 19.0;
  static double s20 = 20.0;
  static double s21 = 21.0;
  static double s22 = 22.0;
  static double s23 = 23.0;
  static double s24 = 24.0;
  static double s25 = 25.0;
  static double s26 = 26.0;
  static double s27 = 27.0;
  static double s28 = 28.0;
  static double s29 = 29.0;
  static double s30 = 30.0;
  static double s32 = 32.0;
  static double s34 = 34.0;
  static double s36 = 36.0;
  static double s40 = 40.0;
  static double s42 = 42.0;
  static double s48 = 48.0;
  static double s52 = 52.0;

  static void setDefaultFontSize() {
    s7 = 7.0;
    s8 = 8.0;
    s9 = 9.0;
    s10 = 10.0;
    s11 = 11.0;
    s12 = 12.0;
    s13 = 13.0;
    s14 = 14.0;
    s15 = 15.0;
    s16 = 16.0;
    s17 = 17.0;
    s18 = 18.0;
    s19 = 19.0;
    s20 = 20.0;
    s21 = 21.0;
    s22 = 22.0;
    s23 = 23.0;
    s24 = 24.0;
    s25 = 25.0;
    s26 = 26.0;
    s27 = 27.0;
    s28 = 28.0;
    s29 = 29.0;
    s30 = 30.0;
    s32 = 32.0;
    s36 = 36.0;
    s40 = 40.0;
    s42 = 42.0;
    s48 = 48.0;
    s52 = 52.0;
  }
}
