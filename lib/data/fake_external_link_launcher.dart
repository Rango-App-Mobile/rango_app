import 'package:rango_app/data/external_link_launcher.dart';

/// Records the URIs it was asked to open instead of leaving the app.
class FakeExternalLinkLauncher implements ExternalLinkLauncher {
  FakeExternalLinkLauncher({this.succeeds = true});

  /// What [open] returns.
  bool succeeds;

  final List<Uri> opened = [];

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return succeeds;
  }
}
