import 'package:freezed_annotation/freezed_annotation.dart';

part 'delivery_links.freezed.dart';

/// Delivery links the team registers per restaurant in Firestore
/// `restaurants/{placeId}`.
@freezed
abstract class DeliveryLinks with _$DeliveryLinks {
  const factory DeliveryLinks({
    String? ifood,
    @Default(<String>[]) List<String> others,
  }) = _DeliveryLinks;
}

/// Where to send the person to order from [restaurantName]: the iFood link,
/// else the first other link, else a Google search. Only `https` links are
/// accepted, so nothing else (`javascript:`, `intent:`, `http:`) leaves
/// the app.
Uri deliveryUriFor(DeliveryLinks? links, String restaurantName) {
  final candidates = [?links?.ifood, ...?links?.others];
  for (final candidate in candidates) {
    final uri = Uri.tryParse(candidate.trim());
    if (uri != null && uri.scheme == 'https' && uri.host.isNotEmpty) {
      return uri;
    }
  }
  return Uri.https('www.google.com', '/search', {
    'q': '$restaurantName delivery',
  });
}
