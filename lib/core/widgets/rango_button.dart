import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';

/// Figma `Button` variants: `Style` property.
enum RangoButtonStyle { primary, secondary, ghost }

/// Figma `Button` variants: `Size` property.
enum RangoButtonSize { large, medium }

/// Pill button, Figma component `Button`. A null [onPressed] disables it.
class RangoButton extends StatelessWidget {
  const RangoButton({
    required this.label,
    required this.onPressed,
    this.style = RangoButtonStyle.primary,
    this.size = RangoButtonSize.large,
    this.icon,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final RangoButtonStyle style;
  final RangoButtonSize size;

  /// Figma "Show icon": drawn before the label when non-null.
  final IconData? icon;

  /// Fills the parent's width instead of hugging the content.
  final bool expand;

  static const _disabledOpacity = 0.4;
  static const _largeHeight = 56.0;
  static const _mediumHeight = 44.0;
  static const _largeIcon = 24.0;
  static const _mediumIcon = 20.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    final isLarge = size == RangoButtonSize.large;

    final (fill, ink, border) = switch (style) {
      RangoButtonStyle.primary => (
        colors.actionPrimary,
        colors.actionOnPrimary,
        BorderSide.none,
      ),
      RangoButtonStyle.secondary => (
        colors.bgSurface,
        colors.textPrimary,
        BorderSide(color: colors.borderStrong, width: AppRadius.stroke),
      ),
      RangoButtonStyle.ghost => (
        Colors.transparent,
        colors.textPrimary,
        BorderSide.none,
      ),
    };

    final labelStyle = (isLarge ? text.bodyStrong : text.label).copyWith(
      color: ink,
    );

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: isLarge ? _largeIcon : _mediumIcon, color: ink),
          const SizedBox(width: AppSpace.xs),
        ],
        Flexible(
          child: Text(
            label,
            style: labelStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final enabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: Opacity(
        opacity: enabled ? 1 : _disabledOpacity,
        child: Material(
          color: fill,
          shape: StadiumBorder(side: border),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            customBorder: const StadiumBorder(),
            child: SizedBox(
              height: isLarge ? _largeHeight : _mediumHeight,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isLarge ? AppSpace.lg : AppSpace.md,
                ),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
