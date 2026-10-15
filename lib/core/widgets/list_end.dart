import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';

/// Figma "List End": end of a scrollable list, with a short message and an
/// optional Secondary action (passed in as a widget).
class ListEnd extends StatelessWidget {
  const ListEnd({required this.message, this.action, super.key});

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpace.sm,
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: context.textStyles.body.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        ?action,
      ],
    );
  }
}
