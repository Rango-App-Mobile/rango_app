import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Registered in `ios/Runner/AppDelegate.swift`.
const appleSignInButtonViewType = 'rango/apple_sign_in_button';

/// HIG default and recommended iOS button height. The system (and the
/// fallback) draw the title at 43% of the height, so 44 gives ~19pt text.
const _height = 44.0;

/// "Continuar com a Apple" (HIG). On iOS it hosts the system
/// `ASAuthorizationAppleIDButton`, which localizes its own title; elsewhere
/// (and in widget tests) it falls back to the package button. Only the widget
/// is used: the sign-in itself goes through Firebase. A null [onPressed]
/// ignores taps and dims the button.
class AppleSignInButton extends StatefulWidget {
  const AppleSignInButton({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  /// Widget tests of screens have no native side: they set this to false to
  /// render the package button (tappable by text) on a simulated iOS.
  @visibleForTesting
  static bool debugNativeOnIOS = true;

  @override
  State<AppleSignInButton> createState() => _AppleSignInButtonState();
}

class _AppleSignInButtonState extends State<AppleSignInButton> {
  MethodChannel? _channel;

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('rango/apple_sign_in_button_$id')
      ..setMethodCallHandler((call) async {
        if (call.method == 'onPressed') widget.onPressed?.call();
      });
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final Widget button;
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        AppleSignInButton.debugNativeOnIOS) {
      button = UiKitView(
        viewType: appleSignInButtonViewType,
        creationParams: const <String, Object>{'cornerRadius': _height / 2},
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else {
      button = SignInWithAppleButton(
        text: 'Continuar com a Apple',
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onPressed: widget.onPressed ?? () {},
      );
    }
    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Continuar com a Apple',
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: IgnorePointer(
          ignoring: !enabled,
          child: SizedBox(height: _height, child: button),
        ),
      ),
    );
  }
}
