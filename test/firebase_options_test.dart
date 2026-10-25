import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/firebase_options.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  group('without the Firebase keys in env.json', () {
    test('has no options on Android', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      expect(DefaultFirebaseOptions.currentPlatform, isNull);
    });

    test('has no options on iOS', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      expect(DefaultFirebaseOptions.currentPlatform, isNull);
    });
  });

  test('throws on a platform other than Android and iOS', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

    expect(
      () => DefaultFirebaseOptions.currentPlatform,
      throwsUnsupportedError,
    );
  });

  test('keeps no literal API key', () {
    expect(DefaultFirebaseOptions.android.apiKey, isEmpty);
    expect(DefaultFirebaseOptions.ios.apiKey, isEmpty);
  });
}
