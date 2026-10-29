import 'package:rango_app/data/delivery_link_repository.dart';
import 'package:rango_app/models/delivery_links.dart';

/// In-memory links, keyed by place id. Default when Firebase is not
/// configured; the empty default makes ordering fall back to a Google search.
class FakeDeliveryLinkRepository implements DeliveryLinkRepository {
  FakeDeliveryLinkRepository([this.links = const {}]);

  final Map<String, DeliveryLinks> links;

  @override
  Future<DeliveryLinks?> linksFor(String placeId) async => links[placeId];
}
