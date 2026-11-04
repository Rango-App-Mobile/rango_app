import 'package:flutter/foundation.dart';

/// Compile-time configuration injected with `--dart-define-from-file`.
abstract final class Env {
  static const firebaseAndroidApiKey = String.fromEnvironment(
    'FIREBASE_ANDROID_API_KEY',
  );
  static const firebaseIosApiKey = String.fromEnvironment(
    'FIREBASE_IOS_API_KEY',
  );

  /// Google Cloud key for Android. One key per platform, restricted by app in
  /// Google Cloud, with Maps SDK for Android and Places API (New) enabled.
  static const googleAndroidApiKey = String.fromEnvironment(
    'GOOGLE_ANDROID_API_KEY',
  );

  /// Google Cloud key for iOS. One key per platform, restricted by app in
  /// Google Cloud, with Maps SDK for iOS and Places API (New) enabled.
  static const googleIosApiKey = String.fromEnvironment('GOOGLE_IOS_API_KEY');

  /// SHA-1 of the Android signing certificate, sent as `X-Android-Cert` so the
  /// app-restricted key also works on REST calls.
  static const androidCertSha1 = String.fromEnvironment('ANDROID_CERT_SHA1');

  /// The Google key for the current platform, or '' when there is none.
  static String get googleApiKey => switch (defaultTargetPlatform) {
    TargetPlatform.iOS => googleIosApiKey,
    TargetPlatform.android => googleAndroidApiKey,
    _ => '',
  };

  /// Whether a Google key is available. Without it the app runs on a drawn map
  /// and fake restaurants.
  static bool get hasGoogleKey => googleApiKey.isNotEmpty;
}
