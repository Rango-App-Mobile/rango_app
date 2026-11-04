import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/models/delivery_links.dart';

void main() {
  group('deliveryUriFor', () {
    test('prefers the iFood link', () {
      const links = DeliveryLinks(
        ifood: 'https://www.ifood.com.br/r/1',
        others: ['https://other.com/1'],
      );
      expect(
        deliveryUriFor(links, 'Casa'),
        Uri.parse('https://www.ifood.com.br/r/1'),
      );
    });

    test('falls back to the first https link in others', () {
      const links = DeliveryLinks(
        others: ['https://a.com/x', 'https://b.com/y'],
      );
      expect(deliveryUriFor(links, 'Casa'), Uri.parse('https://a.com/x'));
    });

    test('skips non-https and malformed links', () {
      const links = DeliveryLinks(
        ifood: 'javascript:alert(1)',
        others: [
          'http://insecure.com',
          'intent://x#Intent;end',
          'https://',
          'not a url',
          'https://ok.com/z',
        ],
      );
      expect(deliveryUriFor(links, 'Casa'), Uri.parse('https://ok.com/z'));
    });

    test('falls back to a Google search when links are null', () {
      final uri = deliveryUriFor(null, 'Casa da Mãe');
      expect(uri.scheme, 'https');
      expect(uri.host, 'www.google.com');
      expect(uri.path, '/search');
      expect(uri.queryParameters['q'], 'Casa da Mãe delivery');
    });

    test('falls back to a Google search when no link is usable', () {
      final uri = deliveryUriFor(
        const DeliveryLinks(ifood: 'http://x.com'),
        'Casa',
      );
      expect(uri.host, 'www.google.com');
      expect(uri.queryParameters['q'], contains('Casa'));
    });

    test('falls back to a Google search for empty links', () {
      final uri = deliveryUriFor(const DeliveryLinks(), 'Casa');
      expect(uri.host, 'www.google.com');
    });
  });
}
