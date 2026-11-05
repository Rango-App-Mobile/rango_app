import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/theme_context.dart';

/// Figma "Scrim": a dark full-screen veil behind sheets. Tapping it calls the
/// dismiss callback.
class Scrim extends StatelessWidget {
  const Scrim.modal({required VoidCallback this.onDismiss, super.key});

  static const double modalOpacity = 0.45;

  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Fechar',
      button: true,
      child: GestureDetector(
        onTap: onDismiss,
        behavior: HitTestBehavior.opaque,
        child: SizedBox.expand(
          child: ColoredBox(
            color: context.colors.bgInverse.withValues(alpha: modalOpacity),
          ),
        ),
      ),
    );
  }
}
