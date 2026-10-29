import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Platform boundary for leaving the app (browser, delivery app, dialer).
abstract interface class ExternalLinkLauncher {
  /// Opens [uri] outside the app. False when it was refused or could not be
  /// opened; never throws.
  Future<bool> open(Uri uri);
}

/// Only `https` and `tel` may leave the app.
bool isAllowedExternalUri(Uri uri) =>
    uri.scheme == 'https' || uri.scheme == 'tel';

class UrlLauncherExternalLinkLauncher implements ExternalLinkLauncher {
  const UrlLauncherExternalLinkLauncher();

  @override
  Future<bool> open(Uri uri) async {
    if (!isAllowedExternalUri(uri)) return false;
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on PlatformException {
      return false;
    }
  }
}

final externalLinkLauncherProvider = Provider<ExternalLinkLauncher>(
  (ref) => const UrlLauncherExternalLinkLauncher(),
);
