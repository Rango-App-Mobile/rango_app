import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/core/widgets/progressive_blur.dart';
import 'package:rango_app/core/widgets/rango_tab_bar.dart';

/// Frame of the two root tabs: the active branch plus the floating Tab Bar, on
/// a progressive blur so what scrolls behind it is not cut in a straight line.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  /// Figma: Tab Bar centered, 20 px above the bottom edge.
  static const _tabBarBottom = 20.0;

  /// Figma 07d: the blur rises 114 px from the bottom edge, around the Tab Bar.
  static const _tabBarBlurHeight = 114.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          navigationShell,
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _tabBarBlurHeight,
            child: ProgressiveBlur(edge: ProgressiveBlurEdge.bottom),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: _tabBarBottom,
            child: Center(
              child: RangoTabBar(
                currentIndex: navigationShell.currentIndex,
                onSelected: (index) => navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
