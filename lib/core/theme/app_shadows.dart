import 'package:flutter/painting.dart';
import 'package:rango_app/core/theme/app_primitives.dart';

/// Figma effect styles `Elevation/Card` and `Elevation/Floating`.
abstract final class AppShadows {
  static final card = [
    BoxShadow(
      color: AppPrimitives.ink900.withValues(alpha: 0.10),
      offset: const Offset(0, 10),
      blurRadius: 28,
      spreadRadius: -6,
    ),
  ];

  static final floating = [
    BoxShadow(
      color: AppPrimitives.ink900.withValues(alpha: 0.22),
      offset: const Offset(0, 14),
      blurRadius: 32,
      spreadRadius: -8,
    ),
  ];
}
