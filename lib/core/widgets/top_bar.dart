import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/widgets/avatar_button.dart';
import 'package:rango_app/core/widgets/rango_icon_button.dart';

/// Figma component `Top Bar`: a 64-high strip at the top of a screen.
///
/// Not an `AppBar`: screens place it with `TopBarLayout`, which adds the blur
/// behind it, or inside a `SafeArea` over the map, which has no blur.
/// Avatar and back button never appear together.
class TopBar extends StatelessWidget {
  /// `Principal` variant: only the profile avatar, on the right. Used by the
  /// root tab screens (Home and Histórico).
  const TopBar.principal({this.onProfile, super.key}) : onBack = null;

  /// `Flow` variant: back button only. Used by every screen outside the tabs.
  const TopBar.flow({required VoidCallback this.onBack, super.key})
    : onProfile = null;

  final VoidCallback? onProfile;
  final VoidCallback? onBack;

  static const height = 64.0;

  @override
  Widget build(BuildContext context) {
    final back = onBack;

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
        child: back != null
            ? Align(
                alignment: Alignment.centerLeft,
                child: RangoIconButton(
                  icon: Icons.arrow_back,
                  semanticLabel: 'Voltar',
                  style: RangoIconButtonStyle.glass,
                  onPressed: back,
                ),
              )
            : Align(
                alignment: Alignment.centerRight,
                child: AvatarButton(onPressed: onProfile),
              ),
      ),
    );
  }
}
