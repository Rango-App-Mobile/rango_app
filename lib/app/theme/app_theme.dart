import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_colors.dart';
import 'package:rango_app/core/theme/app_text_styles.dart';
import 'package:rango_app/core/theme/food_colors.dart';

/// Composes the `ThemeData` from the design tokens in `lib/core/theme/`.
/// No literals here: every color and style comes from a token.
abstract final class AppTheme {
  static ThemeData get light {
    const colors = AppColors.light;
    final text = AppTextStyles.standard;

    TextStyle ink(TextStyle style) => style.copyWith(color: colors.textPrimary);

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyles.aleo,
      scaffoldBackgroundColor: colors.bgCanvas,
      colorScheme: ColorScheme.light(
        primary: colors.actionPrimary,
        onPrimary: colors.actionOnPrimary,
        secondary: colors.actionAccent,
        onSecondary: colors.actionOnPrimary,
        surface: colors.bgSurface,
        onSurface: colors.textPrimary,
        onSurfaceVariant: colors.textSecondary,
        outline: colors.borderStrong,
        outlineVariant: colors.borderDefault,
        error: colors.textDanger,
        onError: colors.textInverse,
        inverseSurface: colors.bgInverse,
        onInverseSurface: colors.textInverse,
        surfaceContainerHighest: colors.bgMuted,
      ),
      textTheme: TextTheme(
        displayLarge: ink(text.displayLarge),
        displayMedium: ink(text.displayMedium),
        displaySmall: ink(text.displayMedium),
        headlineLarge: ink(text.heading),
        headlineMedium: ink(text.heading),
        headlineSmall: ink(text.heading),
        titleLarge: ink(text.heading),
        titleMedium: ink(text.bodyStrong),
        titleSmall: ink(text.label),
        bodyLarge: ink(text.body),
        bodyMedium: ink(text.body),
        bodySmall: ink(text.caption),
        labelLarge: ink(text.label),
        labelMedium: ink(text.label),
        labelSmall: ink(text.caption),
      ),
      extensions: <ThemeExtension<dynamic>>[
        colors,
        text,
        FoodColors.fallback,
      ],
    );
  }
}
