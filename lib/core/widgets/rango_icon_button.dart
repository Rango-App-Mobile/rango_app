import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/theme/app_shadows.dart';
import 'package:rango_app/core/theme/theme_context.dart';

/// Figma `Icon Button` variants: `Style` property.
enum RangoIconButtonStyle { surface, inverse, outline }

/// Circular 48x48 icon button, Figma component `Icon Button`.
class RangoIconButton extends StatelessWidget {
  const RangoIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.style = RangoIconButtonStyle.surface,
    super.key,
  });

  final IconData icon;

  /// Spoken label and tooltip: an icon alone says nothing to a screen reader.
  final String semanticLabel;
  final RangoIconButtonStyle style;
  final VoidCallback? onPressed;

  static const _size = 48.0;
  static const _iconSize = 24.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final (fill, ink, border, shadows) = switch (style) {
      RangoIconButtonStyle.surface => (
        colors.bgSurface,
        colors.iconDefault,
        BorderSide.none,
        AppShadows.card,
      ),
      RangoIconButtonStyle.inverse => (
        colors.bgInverse,
        colors.iconInverse,
        BorderSide.none,
        const <BoxShadow>[],
      ),
      RangoIconButtonStyle.outline => (
        Colors.transparent,
        colors.iconDefault,
        BorderSide(color: colors.borderStrong, width: AppRadius.stroke),
        const <BoxShadow>[],
      ),
    };

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: onPressed,
      child: Tooltip(
        message: semanticLabel,
        excludeFromSemantics: true,
        child: DecoratedBox(
          decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: shadows),
          child: Material(
            color: fill,
            shape: CircleBorder(side: border),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: SizedBox.square(
                dimension: _size,
                child: Icon(icon, size: _iconSize, color: ink),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
