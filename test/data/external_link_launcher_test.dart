import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/data/external_link_launcher.dart';

void main() {
  test('allows only https and tel', () {
    expect(isAllowedExternalUri(Uri.parse('https://ifood.com.br/x')), isTrue);
    expect(isAllowedExternalUri(Uri.parse('tel:+5551333300')), isTrue);
    expect(isAllowedExternalUri(Uri.parse('http://example.com')), isFalse);
    expect(isAllowedExternalUri(Uri.parse('javascript:alert(1)')), isFalse);
    expect(isAllowedExternalUri(Uri.parse('intent://x#Intent;end')), isFalse);
    expect(isAllowedExternalUri(Uri.parse('file:///etc/passwd')), isFalse);
  });

  test('the real launcher refuses other schemes without launching', () async {
    const launcher = UrlLauncherExternalLinkLauncher();
    expect(await launcher.open(Uri.parse('http://example.com')), isFalse);
  });
}
