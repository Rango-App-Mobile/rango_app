import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_shadows.dart';
import 'package:rango_app/core/theme/food_theme.dart';

/// Figma `Swipe Button` variants: `Action` property.
enum SwipeAction {
  pass(Icons.close_rounded, FoodTheme.tomato, 'Passar'),
  like(Icons.favorite_rounded, FoodTheme.lime, 'Curtir');

  const SwipeAction(this.icon, this.foodTheme, this.verb);

  final IconData icon;

  /// Same colors as the drag stickers: tomato says no, lime says yes.
  final FoodTheme foodTheme;
  final String verb;
}

/// Figma `Swipe Button`: the round button under the card that does what the
/// swipe does, for who does not drag (and for screen readers).
class SwipeButton extends StatelessWidget {
  const SwipeButton({
    required this.action,
    required this.foodLabel,
    required this.onPressed,
    super.key,
  });

  final SwipeAction action;

  /// Name of the food on top, so the spoken label says what is being judged.
  final String foodLabel;
  final VoidCallback onPressed;

  static const size = 72.0;
  static const _iconSize = 32.0;

  @override
  Widget build(BuildContext context) {
    final label = '${action.verb} $foodLabel';
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: Tooltip(
        message: label,
        excludeFromSemantics: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: AppShadows.floating,
          ),
          child: Material(
            color: action.foodTheme.background,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: SizedBox.square(
                dimension: size,
                child: Icon(
                  action.icon,
                  size: _iconSize,
                  // The Food Theme ink: it passes contrast on both colors.
                  color: action.foodTheme.foreground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
