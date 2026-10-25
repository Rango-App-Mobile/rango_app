import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:rango_app/core/config/env.dart';

/// [FirebaseOptions] of the team project (`rango-f0485`), written by hand.
///
/// The ids below identify the project and are committed. The API keys come
/// from `env.json` through [Env]: do not run `flutterfire configure`, it would
/// overwrite this file with literal keys (`docs/auth.md`).
abstract final class DefaultFirebaseOptions {
  /// Null when `env.json` has no key for the current platform (CI, a fresh
  /// clone): the app then runs without Firebase, on fakes.
  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Rango runs only on Android and iOS.');
    }
    final options = switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS => ios,
      _ => throw UnsupportedError('Rango runs only on Android and iOS.'),
    };
    return options.apiKey.isEmpty ? null : options;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: Env.firebaseAndroidApiKey,
    appId: '1:186996793800:android:0b910b03aadc475e3de0fd',
    messagingSenderId: '186996793800',
    projectId: 'rango-f0485',
    storageBucket: 'rango-f0485.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: Env.firebaseIosApiKey,
    appId: '1:186996793800:ios:ca163dc733aae7b13de0fd',
    messagingSenderId: '186996793800',
    projectId: 'rango-f0485',
    storageBucket: 'rango-f0485.firebasestorage.app',
    iosBundleId: 'br.senac.rangoApp',
  );
}
