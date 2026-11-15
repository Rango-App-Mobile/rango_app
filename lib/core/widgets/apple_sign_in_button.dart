import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Apple's official "Continuar com a Apple" button (HIG). Only the widget is
/// used: the sign-in itself goes through Firebase. The package button has no
/// disabled state, so a null [onPressed] ignores taps and dims it.
class AppleSignInButton extends StatelessWidget {
  const AppleSignInButton({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Semantics(
      enabled: enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: IgnorePointer(
          ignoring: !enabled,
          child: SignInWithAppleButton(
            text: 'Continuar com a Apple',
            height: 56,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            onPressed: onPressed ?? () {},
          ),
        ),
      ),
    );
  }
}
