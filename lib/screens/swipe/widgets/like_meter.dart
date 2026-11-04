import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';

/// Figma `Like Meter`: one heart per like the food on top already has, out of
/// [total]. Read-only; the hearts alone carry it, so the count is spoken.
class LikeMeter extends StatelessWidget {
  const LikeMeter({required this.likes, required this.total, super.key});

  final int likes;
  final int total;

  /// Figma heart size and the padding of the pill (no 6 px space token).
  static const _heartSize = 16.0;
  static const _verticalPadding = 6.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: '$likes de $total curtidas',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: colors.borderDefault),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.sm,
            vertical: _verticalPadding,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpace.xxs,
            children: [
              for (var i = 0; i < total; i++)
                Icon(
                  i < likes ? Icons.favorite : Icons.favorite_border,
                  size: _heartSize,
                  color: i < likes ? colors.actionAccent : colors.iconMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
