import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/../utils/constants/app_dimension.dart';
import '../utils/constants/app_colors.dart';

AppTheme appTheme = AppTheme();

class AppTheme {
  ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    // Color Scheme
    colorScheme: ColorScheme.fromSeed(seedColor: appColors.primaryColor),

    // Backgrounds
    scaffoldBackgroundColor: appColors.backgroundColor,

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: appColors.backgroundColor,
      elevation: 0,
      iconTheme: IconThemeData(color: appColors.primaryTextColor),
    ),

    // Text Theme
    textTheme: GoogleFonts.ptSansTextTheme().copyWith(
      bodyLarge: GoogleFonts.ptSans(fontSize: FontSize.s16, color: appColors.primaryTextColor),
      bodyMedium: GoogleFonts.ptSans(fontSize: FontSize.s14, color: appColors.primaryTextColor),
      titleLarge: GoogleFonts.ptSans(fontSize: FontSize.s20, fontWeight: FontWeight.bold, color: appColors.primaryTextColor),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: appColors.primaryColor,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.ptSans(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: appColors.primaryColor,
        textStyle: GoogleFonts.ptSans(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: appColors.primaryColor),
        textStyle: GoogleFonts.ptSans(fontSize: 16, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
