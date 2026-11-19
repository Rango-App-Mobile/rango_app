import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';

/// Figma `Inline Alert`: an error about the whole form, shown above the
/// fields. An error about one field goes in that field.
class InlineAlert extends StatelessWidget {
  const InlineAlert({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.photo),
          border: Border.all(color: colors.textDanger, width: AppRadius.stroke),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.md,
            vertical: AppSpace.sm,
          ),
          child: Row(
            spacing: AppSpace.sm,
            children: [
              ExcludeSemantics(
                child: Icon(Icons.error_outline, color: colors.textDanger),
              ),
              Expanded(
                child: Text(
                  message,
                  style: context.textStyles.label.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
