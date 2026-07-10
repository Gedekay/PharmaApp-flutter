import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color cardBackground;
  final Color surface;
  final Color text;
  final Color textSecondary;
  final Color title;
  final Color border;
  final Color disabled;
  final Color primary;
  final Color secondary;
  final Color success;
  final Color error;
  final Color warning;
  final Color info;

  const AppColors({
    required this.background,
    required this.cardBackground,
    required this.surface,
    required this.text,
    required this.textSecondary,
    required this.title,
    required this.border,
    required this.disabled,
    required this.primary,
    required this.secondary,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
  });

  @override
  AppColors copyWith({
    Color? background,
    Color? cardBackground,
    Color? surface,
    Color? text,
    Color? textSecondary,
    Color? title,
    Color? border,
    Color? disabled,
    Color? primary,
    Color? secondary,
    Color? success,
    Color? error,
    Color? warning,
    Color? info,
  }) {
    return AppColors(
      background: background ?? this.background,
      cardBackground: cardBackground ?? this.cardBackground,
      surface: surface ?? this.surface,
      text: text ?? this.text,
      textSecondary: textSecondary ?? this.textSecondary,
      title: title ?? this.title,
      border: border ?? this.border,
      disabled: disabled ?? this.disabled,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;

    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      text: Color.lerp(text, other.text, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      title: Color.lerp(title, other.title, t)!,
      border: Color.lerp(border, other.border, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}