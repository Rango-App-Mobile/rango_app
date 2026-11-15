import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';

/// Full-screen loading: the canvas color with a spinner and an optional
/// [message]. Its visual is provisional and will be replaced by the splash
/// design from Figma.
class RangoLoadingView extends StatelessWidget {
  const RangoLoadingView({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final message = this.message;

    // Material: shown above the Scaffold, so the text needs its own.
    return Material(
      color: colors.bgCanvas,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpace.md,
          children: [
            CircularProgressIndicator(color: colors.actionAccent),
            if (message != null)
              Text(
                message,
                style: context.textStyles.body.copyWith(
                  color: colors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
