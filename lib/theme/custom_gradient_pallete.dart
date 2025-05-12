import 'package:flutter/material.dart';
import 'app_pallete.dart';

class GradientPalette {
  // Light theme gradients
  static List<Color> get lightPrimaryGradient => [
        LightAppPallete.primary,
        LightAppPallete.primaryLight,
        LightAppPallete.accent,
        LightAppPallete.accentLight,
        LightAppPallete.success,
        LightAppPallete.successBackground,
        LightAppPallete.warningBackground,
        LightAppPallete.infoBackground,
        LightAppPallete.primary,
      ];

  static List<Color> get lightSecondaryGradient => [
        LightAppPallete.successBackground,
        LightAppPallete.success,
        LightAppPallete.accentLight,
        LightAppPallete.accent,
        LightAppPallete.primaryLight,
        LightAppPallete.primary,
        LightAppPallete.infoBackground,
        LightAppPallete.info,
        LightAppPallete.successBackground,
      ];

  // Dark theme gradients
  static List<Color> get darkPrimaryGradient => [
        DarkAppPallete.primary,
        DarkAppPallete.primaryLight,
        DarkAppPallete.accent,
        DarkAppPallete.accentLight,
        DarkAppPallete.success,
        DarkAppPallete.successBackground,
        DarkAppPallete.info,
        DarkAppPallete.infoBackground,
        DarkAppPallete.primary,
      ];

  static List<Color> get darkSecondaryGradient => [
        DarkAppPallete.successBackground,
        DarkAppPallete.success,
        DarkAppPallete.accentLight,
        DarkAppPallete.accent,
        DarkAppPallete.primaryLight,
        DarkAppPallete.primary,
        DarkAppPallete.infoBackground,
        DarkAppPallete.info,
        DarkAppPallete.successBackground,
      ];
}