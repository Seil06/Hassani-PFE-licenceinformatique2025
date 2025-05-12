import 'package:flutter/material.dart';
import 'package:myapp/theme/animated_gradient_background.dart';
import 'package:myapp/theme/custom_gradient_pallete.dart';
import 'app_pallete.dart';
// Assuming this file contains GradientPalette definitions

class ThemeBackground extends StatelessWidget {
  final Widget child;
  final bool isDarkMode;

  const ThemeBackground({
    super.key,
    required this.child,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      primaryColors: isDarkMode
          ? GradientPalette.darkPrimaryGradient
          : GradientPalette.lightPrimaryGradient,
      secondaryColors: isDarkMode
          ? GradientPalette.darkSecondaryGradient
          : GradientPalette.lightSecondaryGradient,
      child: child,
    );
  }
}

class AppTheme {
  static _border(Color color, {double width = 2}) => OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: width,
        ),
        borderRadius: BorderRadius.circular(12),
      );

  static final lightThemeMode = ThemeData.light().copyWith(
    scaffoldBackgroundColor: Colors.transparent, // Set transparent for gradient
    primaryColor: LightAppPallete.primaryLight,
    colorScheme: ColorScheme.light(
      primary: const Color.fromARGB(255, 210, 255, 223),
      surface: LightAppPallete.surface,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent, // Transparent for gradient
      elevation: 0,
      titleTextStyle: TextStyle(
        color: LightAppPallete.text,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        color: LightAppPallete.text,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: LightAppPallete.textSecondary,
        fontSize: 14,
      ),
      bodyMedium: TextStyle(
        color: LightAppPallete.text,
        fontWeight: FontWeight.w500, // Updated for better contrast
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: LightAppPallete.primaryLight,
      border: _border(const Color.fromARGB(255, 188, 196, 211), width: 0),
      enabledBorder: _border(LightAppPallete.grey, width: 0),
      focusedBorder: _border(LightAppPallete.primary),
      errorBorder: _border(LightAppPallete.error),
      errorStyle: TextStyle(
        color: LightAppPallete.error,
        fontSize: 12,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: LightAppPallete.primary,
        foregroundColor: LightAppPallete.backgroundAlt,
        padding: EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: LightAppPallete.info,
        textStyle: TextStyle(fontSize: 14),
      ),
    ),
    toggleButtonsTheme: ToggleButtonsThemeData(
      borderRadius: BorderRadius.circular(12),
      selectedColor: LightAppPallete.text,
      fillColor: LightAppPallete.primary,
      borderColor: LightAppPallete.grey,
      selectedBorderColor: LightAppPallete.primary,
      textStyle: TextStyle(color: LightAppPallete.text),
    ),
  );

  static final darkThemeMode = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.transparent, // Set transparent for gradient
    primaryColor: DarkAppPallete.primary,
    colorScheme: ColorScheme.dark(
      primary: DarkAppPallete.primary,
      surface: DarkAppPallete.surface,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent, // Transparent for gradient
      elevation: 0,
      titleTextStyle: TextStyle(
        color: DarkAppPallete.text,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        color: DarkAppPallete.text,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: DarkAppPallete.textSecondary,
        fontSize: 14,
      ),
      bodyMedium: TextStyle(
        color: DarkAppPallete.text,
        fontWeight: FontWeight.w500, // Updated for better contrast
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: DarkAppPallete.surfaceLight,
      border: _border(DarkAppPallete.grey, width: 0),
      enabledBorder: _border(DarkAppPallete.grey, width: 0),
      focusedBorder: _border(DarkAppPallete.primary),
      errorBorder: _border(DarkAppPallete.error),
      errorStyle: TextStyle(
        color: DarkAppPallete.error,
        fontSize: 12,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DarkAppPallete.primary,
        foregroundColor: DarkAppPallete.background,
        padding: EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: DarkAppPallete.info,
        textStyle: TextStyle(fontSize: 14),
      ),
    ),
    toggleButtonsTheme: ToggleButtonsThemeData(
      borderRadius: BorderRadius.circular(12),
      selectedColor: DarkAppPallete.text,
      fillColor: DarkAppPallete.primary,
      borderColor: DarkAppPallete.grey,
      selectedBorderColor: DarkAppPallete.primary,
      textStyle: TextStyle(color: DarkAppPallete.text),
    ),
  );
}

