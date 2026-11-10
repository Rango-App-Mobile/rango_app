import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';

/// Figma `Divider`: a line with a short word in the middle, between two ways
/// of doing the same thing.
class RangoDivider extends StatelessWidget {
  const RangoDivider({this.label = 'ou', super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final line = Expanded(
      child: ColoredBox(
        color: colors.borderDefault,
        child: const SizedBox(height: 1),
      ),
    );

    return Row(
      spacing: AppSpace.sm,
      children: [
        line,
        Text(
          label,
          style: context.textStyles.caption.copyWith(
            color: colors.textSecondary,
          ),
        ),
        line,
      ],
    );
  }
}
