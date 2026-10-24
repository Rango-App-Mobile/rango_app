import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/core/widgets/food_photo.dart';

void main() {
  test('resolves a photo name to its bundled asset', () {
    expect(
      foodPhoto('pizza'),
      const AssetImage('assets/images/food/pizza.jpg'),
    );
  });

  test('returns null without a name, so the card draws its placeholder', () {
    expect(foodPhoto(null), isNull);
  });
}
