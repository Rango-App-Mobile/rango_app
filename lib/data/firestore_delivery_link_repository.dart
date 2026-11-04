import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rango_app/data/delivery_link_repository.dart';
import 'package:rango_app/models/delivery_links.dart';

/// Reads the links the team registered by hand in Firestore
/// `restaurants/{placeId}`, field `deliveryLinks: {ifood, others}`.
class FirestoreDeliveryLinkRepository implements DeliveryLinkRepository {
  FirestoreDeliveryLinkRepository(
    this._firestore, {
    this.timeout = const Duration(seconds: 5),
  });

  final FirebaseFirestore _firestore;
  final Duration timeout;

  /// Any failure (Firebase error, timeout, unexpected shape) returns null:
  /// ordering must never get stuck, and the caller falls back to a Google
  /// search.
  @override
  Future<DeliveryLinks?> linksFor(String placeId) async {
    try {
      final snapshot = await _firestore
          .collection('restaurants')
          .doc(placeId)
          .get()
          .timeout(timeout);
      return _parse(snapshot.data()?['deliveryLinks']);
    } on FirebaseException {
      return null;
    } on TimeoutException {
      return null;
    }
  }

  DeliveryLinks? _parse(Object? raw) {
    if (raw is! Map<Object?, Object?>) return null;
    final ifood = switch (raw['ifood']) {
      final String s when s.trim().isNotEmpty => s.trim(),
      _ => null,
    };
    final others = switch (raw['others']) {
      final List<Object?> list => [
        for (final item in list)
          if (item is String && item.trim().isNotEmpty) item.trim(),
      ],
      _ => <String>[],
    };
    if (ifood == null && others.isEmpty) return null;
    return DeliveryLinks(ifood: ifood, others: others);
  }
}
