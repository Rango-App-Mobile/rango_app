import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/core/widgets/rango_chip.dart';

/// Figma component `Month Header`: separates the months of the Histórico with
/// the month's name and a soft chip counting its decisions.
class MonthHeader extends StatelessWidget {
  const MonthHeader({required this.label, required this.count, super.key});

  final String label;

  /// "5 rangos".
  final String count;

  /// Figma: the 26 of the `Heading` line.
  static const height = 26.0;

  static const _gap = 10.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: _gap,
        children: [
          Semantics(
            header: true,
            child: Text(
              label,
              style: context.textStyles.heading.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ),
          RangoChip(label: count, style: RangoChipStyle.soft),
        ],
      ),
    );
  }
}
