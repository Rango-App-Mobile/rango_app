import 'package:flutter/painting.dart';

/// Turns the `photo` name stored on a category into its bundled image.
///
/// Null without a name, so the Food Card draws its placeholder; a name with no
/// file also ends on the placeholder, through the card's `errorBuilder`.
ImageProvider<Object>? foodPhoto(String? name) =>
    name == null ? null : AssetImage('assets/images/food/$name.jpg');
