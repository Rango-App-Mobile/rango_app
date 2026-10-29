import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/core/config/env.dart';

void main() {
  test('without dart-defines there is no Google key', () {
    expect(Env.googleApiKey, isEmpty);
    expect(Env.hasGoogleKey, isFalse);
  });
}
