import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/data/fake_delivery_link_repository.dart';
import 'package:rango_app/models/delivery_links.dart';

void main() {
  test('returns the links registered for the place', () async {
    const links = DeliveryLinks(ifood: 'https://ifood.com.br/x');
    final repository = FakeDeliveryLinkRepository({'p1': links});

    expect(await repository.linksFor('p1'), links);
  });

  test('returns null for an unknown place', () async {
    expect(await FakeDeliveryLinkRepository().linksFor('p1'), isNull);
  });
}
