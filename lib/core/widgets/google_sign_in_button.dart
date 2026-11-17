import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/theme/theme_context.dart';

/// "Continuar com o Google", following Google Identity branding (light
/// theme). A null [onPressed] disables it.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  static const _label = 'Continuar com o Google';
  // Same height as the native Apple button (HIG default), so they pair.
  static const _height = 44.0;
  static const _logo = 20.0;
  static const _gap = 12.0;
  static const _disabledOpacity = 0.4;
  // Fixed by Google's branding guidelines, not by the app palette.
  static const _fill = Color(0xFFFFFFFF);
  static const _border = Color(0xFF747775);
  static const _ink = Color(0xFF1F1F1F);

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: _label,
      excludeSemantics: true,
      onTap: onPressed,
      child: Opacity(
        opacity: enabled ? 1 : _disabledOpacity,
        child: Material(
          color: _fill,
          shape: const StadiumBorder(
            side: BorderSide(color: _border, width: AppRadius.stroke),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            customBorder: const StadiumBorder(),
            child: SizedBox(
              height: _height,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/google_g.png',
                    width: _logo,
                    height: _logo,
                  ),
                  const SizedBox(width: _gap),
                  Flexible(
                    child: Text(
                      _label,
                      style: context.textStyles.bodyStrong.copyWith(
                        color: _ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
