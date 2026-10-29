import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/data/firestore_delivery_link_repository.dart';
import 'package:rango_app/models/delivery_links.dart';

abstract interface class DeliveryLinkRepository {
  /// Links registered for [placeId], or null when there are none or they
  /// can't be read.
  Future<DeliveryLinks?> linksFor(String placeId);
}

/// Real Firestore by default; `main.dart` swaps in the fake when Firebase is
/// not configured, and tests override this provider.
final deliveryLinkRepositoryProvider = Provider<DeliveryLinkRepository>(
  (ref) => FirestoreDeliveryLinkRepository(FirebaseFirestore.instance),
);
