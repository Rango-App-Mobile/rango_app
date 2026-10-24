import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/core/widgets/rango_tab_bar.dart';

/// Frame of the two root tabs: the active branch plus the floating Tab Bar.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  /// Figma: Tab Bar centered, 20 px above the bottom edge.
  static const _tabBarBottom = 20.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          navigationShell,
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
