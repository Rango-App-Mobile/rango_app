import 'package:flutter/painting.dart';

/// Raw palette from the Figma "Primitives" collection. Widgets never use these
/// directly: they read the semantic tokens in `AppColors` and `FoodColors`,
/// which point here the same way the Figma variables alias the primitives.
abstract final class AppPrimitives {
  static const cream = Color(0xFFFFF8EE);
  static const paper = Color(0xFFFFFDF8);
  static const sand = Color(0xFFF2EADB);
  static const line = Color(0xFFE6DCCB);
  static const ink900 = Color(0xFF1B1B1E);
  static const ink700 = Color(0xFF313131);
  static const ink500 = Color(0xFF6D676E);
  static const ink300 = Color(0xFFB7AFA6);

  static const rango = Color(0xFFCA5F60);
  static const crimson = Color(0xFF96031A);

  static const tomato = Color(0xFFFF5B2E);
  static const mustard = Color(0xFFFFC83D);
  static const lilac = Color(0xFFE4A6E0);
  static const lime = Color(0xFFD6F16B);
  static const pistachio = Color(0xFF2F5D3A);
  static const sky = Color(0xFFBDE5F4);
  static const plum = Color(0xFF4B1466);
  static const copper = Color(0xFFBE8A4E);
  static const cocoa = Color(0xFF2B2118);
  static const bubblegum = Color(0xFFFFB8C9);
}
