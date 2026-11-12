import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/theme/theme_context.dart';

/// Figma `List Row`, `Trailing=Chevron`: a 60-high settings line with an icon
/// in a circle, a label and a chevron. The other variants come with their
/// stories.
class ListRow extends StatelessWidget {
  const ListRow({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  static const double height = 60;
  static const double _lead = 40;
  static const double _iconSize = 20;
  static const double _gap = 14;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colors.borderDefault,
                width: AppRadius.stroke,
              ),
            ),
          ),
          child: Row(
            spacing: _gap,
            children: [
              Container(
                width: _lead,
                height: _lead,
                decoration: BoxDecoration(
                  color: colors.bgMuted,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: _iconSize, color: colors.iconDefault),
              ),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyStrong.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: _iconSize,
                color: colors.iconDefault,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
