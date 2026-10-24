import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/theme/food_theme.dart';
import 'package:rango_app/core/theme/theme_context.dart';

/// Profile entry point, Figma component `Avatar Button` (guest variant).
///
/// A 44x44 mustard circle with a person icon inside a 48x48 touch target.
/// Photo and badge variants are future work.
class AvatarButton extends StatelessWidget {
  const AvatarButton({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  static const _label = 'Abrir perfil';
  static const _target = 48.0;
  static const _circle = 44.0;
  static const _iconSize = 24.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: _label,
      excludeSemantics: true,
      onTap: onPressed,
      child: Tooltip(
        message: _label,
        excludeFromSemantics: true,
        child: SizedBox.square(
          dimension: _target,
          child: Center(
            child: Material(
              color: FoodTheme.mustard.background,
              shape: CircleBorder(
                side: BorderSide(
                  color: colors.borderStrong,
                  width: AppRadius.stroke,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onPressed,
                customBorder: const CircleBorder(),
                child: SizedBox.square(
                  dimension: _circle,
                  child: Icon(
                    Icons.person_outline,
                    size: _iconSize,
                    color: FoodTheme.mustard.foreground,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
