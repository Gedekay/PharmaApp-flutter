import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'theme_extension.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppLightColors.background,

    colorScheme: const ColorScheme.light(
      primary: AppLightColors.primary,
      secondary: AppLightColors.secondary,
      error: AppLightColors.error,
    ),

    extensions: const [
      AppColors(
        background: AppLightColors.background,
        cardBackground: AppLightColors.cardBackground,
        surface: AppLightColors.surface,
        text: AppLightColors.text,
        textSecondary: AppLightColors.textSecondary,
        title: AppLightColors.title,
        border: AppLightColors.border,
        disabled: AppLightColors.disabled,
        primary: AppLightColors.primary,
        secondary: AppLightColors.secondary,
        success: AppLightColors.success,
        error: AppLightColors.error,
        warning: AppLightColors.warning,
        info: AppLightColors.info,
      ),
    ],
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppDarkColors.background,

    colorScheme: const ColorScheme.dark(
      primary: AppDarkColors.primary,
      secondary: AppDarkColors.secondary,
      error: AppDarkColors.error,
    ),

    extensions: const [
      AppColors(
        background: AppDarkColors.background,
        cardBackground: AppDarkColors.cardBackground,
        surface: AppDarkColors.surface,
        text: AppDarkColors.text,
        textSecondary: AppDarkColors.textSecondary,
        title: AppDarkColors.title,
        border: AppDarkColors.border,
        disabled: AppDarkColors.disabled,
        primary: AppDarkColors.primary,
        secondary: AppDarkColors.secondary,
        success: AppDarkColors.success,
        error: AppDarkColors.error,
        warning: AppDarkColors.warning,
        info: AppDarkColors.info,
      ),
    ],
  );
}
