import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';

/// The credit the OpenStreetMap license requires while its tiles are on
/// screen. The screen places it, because only the screen knows what else sits
/// over the map.
class MapCredit extends StatelessWidget {
  const MapCredit({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.sm,
          vertical: AppSpace.xxs,
        ),
        child: Text(
          '© OpenStreetMap contributors',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.caption.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
