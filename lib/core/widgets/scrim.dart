import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/theme_context.dart';

/// Kind of [Scrim]: a top legibility gradient or a full-screen modal veil.
enum ScrimType { top, modal }

/// Figma "Scrim": legibility veils.
///
/// [Scrim.top] is a 124 px cream gradient under the Top Bar on map screens
/// and ignores pointers. [Scrim.modal] is a dark full-screen veil behind
/// sheets; tapping it calls the dismiss callback.
class Scrim extends StatelessWidget {
  const Scrim.top({super.key}) : type = ScrimType.top, onDismiss = null;

  const Scrim.modal({required VoidCallback this.onDismiss, super.key})
    : type = ScrimType.modal;

  static const double topHeight = 124;
  static const double modalOpacity = 0.45;

  final ScrimType type;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    switch (type) {
      case ScrimType.top:
        return IgnorePointer(
          child: Container(
            height: topHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colors.bgCanvas, colors.bgCanvas.withValues(alpha: 0)],
              ),
            ),
          ),
        );
      case ScrimType.modal:
        return Semantics(
          label: 'Fechar',
          button: true,
          child: GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.opaque,
            child: SizedBox.expand(
              child: ColoredBox(
                color: colors.bgInverse.withValues(alpha: modalOpacity),
              ),
            ),
          ),
        );
    }
  }
}
