import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';

/// Figma `Chip` variants: `Style` property.
enum RangoChipStyle { outline, solid, soft }

/// Small non-interactive pill label, Figma component `Chip`. Its outline is
/// 1px (the `BorderSide` default), not `stroke/default`, as in Figma.
class RangoChip extends StatelessWidget {
  const RangoChip({
    required this.label,
    this.style = RangoChipStyle.outline,
    this.icon,
    super.key,
  });

  final String label;
  final RangoChipStyle style;

  /// Figma "Show icon": drawn before the label when non-null.
  final IconData? icon;

  /// Figma Chip padding, no space token.
  static const _horizontalPadding = 10.0;

  static const _iconSize = 14.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final (fill, ink, border) = switch (style) {
      RangoChipStyle.outline => (
        Colors.transparent,
        colors.textPrimary,
        BorderSide(color: colors.borderStrong),
      ),
      RangoChipStyle.solid => (
        colors.bgInverse,
        colors.textInverse,
        BorderSide.none,
      ),
      RangoChipStyle.soft => (
        colors.bgMuted,
        colors.textPrimary,
        BorderSide.none,
      ),
    };

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: fill,
        shape: StadiumBorder(side: border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpace.xxs,
          horizontal: _horizontalPadding,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: _iconSize, color: ink),
              const SizedBox(width: AppSpace.xxs),
            ],
            Text(label, style: context.textStyles.chip.copyWith(color: ink)),
          ],
        ),
      ),
    );
  }
}
