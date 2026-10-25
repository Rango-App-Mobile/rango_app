import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/core/widgets/avatar_button.dart';
import 'package:rango_app/core/widgets/rango_icon_button.dart';

/// Figma component `Top Bar`: a 64-high strip at the top of a screen body.
///
/// Not an `AppBar`: screens place it themselves, inside a `SafeArea`.
/// Logo and back button never appear together.
class TopBar extends StatelessWidget {
  /// `Principal` variant: logo on the left, profile avatar on the right.
  /// Used by the root tab screens (Home and Histórico).
  const TopBar.principal({this.onProfile, super.key}) : onBack = null;

  /// `Flow` variant: back button only. Used by every screen outside the tabs.
  const TopBar.flow({required VoidCallback this.onBack, super.key})
    : onProfile = null;

  final VoidCallback? onProfile;
  final VoidCallback? onBack;

  static const _height = 64.0;

  @override
  Widget build(BuildContext context) {
    final back = onBack;

    return SizedBox(
      height: _height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
        child: back != null
            ? Align(
                alignment: Alignment.centerLeft,
                child: RangoIconButton(
                  icon: Icons.arrow_back,
                  semanticLabel: 'Voltar',
                  onPressed: back,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ExcludeSemantics(
                    child: Text(
                      'Rango',
                      style: context.textStyles.brandLogo.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                  AvatarButton(onPressed: onProfile),
                ],
              ),
      ),
    );
  }
}
