import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WtfColors {
  static const guruPrimary = Color(0xFF1769E0);
  static const guruPrimaryLight = Color(0xFFE8F0FE);
  static const trainerPrimary = Color(0xFFE50914);
  static const trainerPrimaryLight = Color(0xFFFDE8E8);
  static const neutral900 = Color(0xFF111827);
  static const neutral600 = Color(0xFF4B5563);
  static const neutral200 = Color(0xFFE5E7EB);
  static const neutral50 = Color(0xFFF9FAFB);
  static const success = Color(0xFF12B76A);
  static const warning = Color(0xFFF79009);
  static const error = Color(0xFFD92D20);
}

class WtfSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
}

ThemeData buildGuruTheme() =>
    _buildTheme(WtfColors.guruPrimary, WtfColors.guruPrimaryLight);

ThemeData buildTrainerTheme() =>
    _buildTheme(WtfColors.trainerPrimary, WtfColors.trainerPrimaryLight);

ThemeData _buildTheme(Color primary, Color primaryLight) {
  final textTheme = GoogleFonts.interTextTheme();
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: primary,
    brightness: Brightness.light,
    scaffoldBackgroundColor: WtfColors.neutral50,
    textTheme: textTheme.copyWith(
      headlineLarge: textTheme.headlineLarge?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: textTheme.headlineMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: textTheme.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: textTheme.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      labelSmall: textTheme.labelSmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: WtfColors.neutral200),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primary, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
