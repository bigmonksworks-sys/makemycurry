import 'package:flutter/material.dart';
import 'package:flutter_grocery/utill/app_constants.dart';

const Color pesitoDarkPrimary = Color(0xFFC70043); // Pesito primary
const Color pesitoDarkSecondary =
    Color(0xFF6A1331); // Deep shade of Pesito pink
const Color pesitoDarkCard =
    Color(0xFF1A1A1A); // Slightly lighter than scaffold
const Color pesitoDarkScaffold = Color(0xFF131313); // Main background
const Color pesitoDarkHint = Color(0xFFFFB3C7); // Light pink hint
const Color pesitoDarkFocus = Color(0xFFE74D7A); // Bright accent for focus
const Color pesitoDarkCanvas = Color(0xFF232025); // Canvas
const Color pesitoDarkShadow = Color(0x80C70043); // 50% opacity Pesito pink

ThemeData dark = ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: pesitoDarkPrimary,
  secondaryHeaderColor: pesitoDarkSecondary,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: pesitoDarkScaffold,
  cardColor: pesitoDarkCard,
  hintColor: pesitoDarkHint,
  focusColor: pesitoDarkFocus,
  canvasColor: pesitoDarkCanvas,
  shadowColor: pesitoDarkShadow,
  textTheme: const TextTheme(
    titleLarge: TextStyle(
        color: Color(0xFFFFE4EF),
        fontWeight: FontWeight.bold), // Off-white-pink
    bodyMedium: TextStyle(color: Colors.white70),
  ),
  pageTransitionsTheme: const PageTransitionsTheme(builders: {
    TargetPlatform.android: ZoomPageTransitionsBuilder(),
    TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
    TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
  }),
  popupMenuTheme: const PopupMenuThemeData(
      color: Color(0xFF232025), surfaceTintColor: Color(0xFF232025)),
  dialogTheme: const DialogThemeData(
      backgroundColor: Color(0xFF1A1A1A), surfaceTintColor: Color(0xFF1A1A1A)),
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: pesitoDarkPrimary,
    onPrimary: Colors.white,
    secondary: pesitoDarkSecondary,
    onSecondary: pesitoDarkHint,
    error: Colors.redAccent,
    onError: Colors.white,
    surface: pesitoDarkCard,
    onSurface: Colors.white70,
    shadow: pesitoDarkShadow,
  ),
);
