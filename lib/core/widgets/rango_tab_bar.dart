import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/theme/app_shadows.dart';
import 'package:rango_app/core/theme/theme_context.dart';

/// Floating bottom navigation pill, Figma component `Tab Bar`.
///
/// Two fixed tabs (Home, Histórico). It does not position itself: the shell
/// places it centered above the bottom edge. Only the cream pill behind the
/// active item animates when the tab changes.
class RangoTabBar extends StatelessWidget {
  const RangoTabBar({
    required this.currentIndex,
    required this.onSelected,
    super.key,
  });

  final int currentIndex;

  /// Called on every tap, including on the already active tab.
  final ValueChanged<int> onSelected;

  static const _padding = 6.0;
  static const _itemWidth = 92.0;
  static const _itemHeight = 52.0;
  static const _iconSize = 22.0;
  static const _dotSize = 5.0;
  static const _slide = Duration(milliseconds: 200);

  static const List<({IconData icon, String label})> _items = [
    (icon: Icons.home_outlined, label: 'Home'),
    (icon: Icons.history, label: 'Histórico'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : _slide;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bgInverse,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: AppShadows.floating,
      ),
      child: Padding(
        padding: const EdgeInsets.all(_padding),
        child: SizedBox(
          width: _itemWidth * _items.length,
          height: _itemHeight,
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: duration,
                curve: Curves.ease,
                left: currentIndex * _itemWidth,
                top: 0,
                width: _itemWidth,
                height: _itemHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.bgCanvas,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < _items.length; i++)
                    _TabItem(
                      icon: _items[i].icon,
                      label: _items[i].label,
                      semanticLabel:
                          '${_items[i].label}, '
                          'aba ${i + 1} de ${_items.length}',
                      selected: i == currentIndex,
                      onTap: () => onSelected(i),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.semanticLabel,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String semanticLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final iconColor = selected ? colors.iconDefault : colors.iconInverse;
    final textColor = selected ? colors.textPrimary : colors.textInverse;

    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: SizedBox(
        width: RangoTabBar._itemWidth,
        height: RangoTabBar._itemHeight,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            customBorder: const StadiumBorder(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: RangoTabBar._iconSize, color: iconColor),
                    Text(
                      label,
                      style: context.textStyles.tab.copyWith(color: textColor),
                    ),
                  ],
                ),
                if (selected)
                  Positioned(
                    top: 8,
                    right: 28,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.actionAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox.square(
                        dimension: RangoTabBar._dotSize,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
