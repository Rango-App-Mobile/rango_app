import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/core/config/env.dart';

void main() {
  test('without dart-defines there are no Firebase keys', () {
    expect(Env.firebaseAndroidApiKey, isEmpty);
    expect(Env.firebaseIosApiKey, isEmpty);
  });
}
