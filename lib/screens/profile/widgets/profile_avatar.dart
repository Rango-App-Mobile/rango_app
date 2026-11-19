import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/food_theme.dart';

/// The sheet's header picture: the Avatar Button at 1.5x, not tappable. Shows
/// the person's photo, or the guest icon when there is none or it fails.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({this.photoUrl, super.key});

  final String? photoUrl;

  static const double size = 72;
  static const double _iconSize = 36;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    final guestIcon = Center(
      child: Icon(
        Icons.person_outline,
        size: _iconSize,
        color: FoodTheme.mustard.foreground,
      ),
    );

    return ExcludeSemantics(
      child: ClipOval(
        child: SizedBox.square(
          dimension: size,
          child: ColoredBox(
            color: FoodTheme.mustard.background,
            child: url == null
                ? guestIcon
                : Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => guestIcon,
                  ),
          ),
        ),
      ),
    );
  }
}
