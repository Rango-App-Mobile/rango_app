import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_primitives.dart';

/// Semantic colors from the Figma "Color" collection (`color/<group>/<role>`).
/// A theme extension, not constants, so a dark mode is a second instance.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bgCanvas,
    required this.bgSurface,
    required this.bgMuted,
    required this.bgInverse,
    required this.bgPlaceholder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textInverse,
    required this.textAccent,
    required this.textDanger,
    required this.borderDefault,
    required this.borderStrong,
    required this.actionPrimary,
    required this.actionOnPrimary,
    required this.actionAccent,
    required this.iconDefault,
    required this.iconInverse,
    required this.iconMuted,
  });

  static const light = AppColors(
    bgCanvas: AppPrimitives.cream,
    bgSurface: AppPrimitives.paper,
    bgMuted: AppPrimitives.sand,
    bgInverse: AppPrimitives.ink700,
    bgPlaceholder: AppPrimitives.line,
    textPrimary: AppPrimitives.ink900,
    textSecondary: AppPrimitives.ink500,
    textInverse: AppPrimitives.cream,
    textAccent: AppPrimitives.rango,
    textDanger: AppPrimitives.crimson,
    borderDefault: AppPrimitives.line,
    borderStrong: AppPrimitives.ink900,
    actionPrimary: AppPrimitives.ink900,
    actionOnPrimary: AppPrimitives.cream,
    actionAccent: AppPrimitives.rango,
    iconDefault: AppPrimitives.ink900,
    iconInverse: AppPrimitives.cream,
    iconMuted: AppPrimitives.ink300,
  );

  final Color bgCanvas;
  final Color bgSurface;
  final Color bgMuted;
  final Color bgInverse;
  final Color bgPlaceholder;
  final Color textPrimary;
  final Color textSecondary;
  final Color textInverse;
  final Color textAccent;
  final Color textDanger;
  final Color borderDefault;
  final Color borderStrong;
  final Color actionPrimary;
  final Color actionOnPrimary;
  final Color actionAccent;
  final Color iconDefault;
  final Color iconInverse;
  final Color iconMuted;

  @override
  AppColors copyWith({
    Color? bgCanvas,
    Color? bgSurface,
    Color? bgMuted,
    Color? bgInverse,
    Color? bgPlaceholder,
    Color? textPrimary,
    Color? textSecondary,
    Color? textInverse,
    Color? textAccent,
    Color? textDanger,
    Color? borderDefault,
    Color? borderStrong,
    Color? actionPrimary,
    Color? actionOnPrimary,
    Color? actionAccent,
    Color? iconDefault,
    Color? iconInverse,
    Color? iconMuted,
  }) {
    return AppColors(
      bgCanvas: bgCanvas ?? this.bgCanvas,
      bgSurface: bgSurface ?? this.bgSurface,
      bgMuted: bgMuted ?? this.bgMuted,
      bgInverse: bgInverse ?? this.bgInverse,
      bgPlaceholder: bgPlaceholder ?? this.bgPlaceholder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textInverse: textInverse ?? this.textInverse,
      textAccent: textAccent ?? this.textAccent,
      textDanger: textDanger ?? this.textDanger,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      actionPrimary: actionPrimary ?? this.actionPrimary,
      actionOnPrimary: actionOnPrimary ?? this.actionOnPrimary,
      actionAccent: actionAccent ?? this.actionAccent,
      iconDefault: iconDefault ?? this.iconDefault,
      iconInverse: iconInverse ?? this.iconInverse,
      iconMuted: iconMuted ?? this.iconMuted,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t) ?? a;
    return AppColors(
      bgCanvas: mix(bgCanvas, other.bgCanvas),
      bgSurface: mix(bgSurface, other.bgSurface),
      bgMuted: mix(bgMuted, other.bgMuted),
      bgInverse: mix(bgInverse, other.bgInverse),
      bgPlaceholder: mix(bgPlaceholder, other.bgPlaceholder),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textInverse: mix(textInverse, other.textInverse),
      textAccent: mix(textAccent, other.textAccent),
      textDanger: mix(textDanger, other.textDanger),
      borderDefault: mix(borderDefault, other.borderDefault),
      borderStrong: mix(borderStrong, other.borderStrong),
      actionPrimary: mix(actionPrimary, other.actionPrimary),
      actionOnPrimary: mix(actionOnPrimary, other.actionOnPrimary),
      actionAccent: mix(actionAccent, other.actionAccent),
      iconDefault: mix(iconDefault, other.iconDefault),
      iconInverse: mix(iconInverse, other.iconInverse),
      iconMuted: mix(iconMuted, other.iconMuted),
    );
  }
}
