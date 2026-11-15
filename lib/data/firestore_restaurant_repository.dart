import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter/foundation.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/restaurant_repository.dart';
import 'package:rango_app/models/geo_point.dart';
import 'package:rango_app/models/restaurant.dart';
import 'package:rango_app/models/restaurant_ranking.dart';

/// Reads the team's restaurants from Firestore `restaurants/{id}`, written by
/// the sheet sync (`tools/restaurant_sync/`, `docs/contexto.md` §8).
class FirestoreRestaurantRepository implements RestaurantRepository {
  FirestoreRestaurantRepository(
    this._firestore, {
    this.timeout = const Duration(seconds: 10),
  });

  static const _collection = 'restaurants';

  // ponytail: reads every place that serves the food and filters the 3 km on
  // the phone. Fine for one region's few dozen places; a geohash range query
  // when the base grows past this limit.
  static const _limit = 500;

  final firestore.FirebaseFirestore _firestore;
  final Duration timeout;

  @override
  Future<List<Restaurant>> search({
    required String foodId,
    required GeoPoint near,
  }) async {
    final snapshot = await _guard(
      () => _firestore
          .collection(_collection)
          .where('foods', arrayContains: foodId)
          .limit(_limit)
          .get(),
    );
    final places = [
      for (final doc in snapshot.docs) ?_toRestaurant(doc.id, doc.data()),
    ];
    return RestaurantRanking.rank(places, near);
  }

  @override
  Future<String?> fetchPhone(String placeId) async {
    final snapshot = await _guard(
      () => _firestore.collection(_collection).doc(placeId).get(),
    );
    return _text(snapshot.data()?['phone']);
  }

  /// The sheet has no photos; the card uses the food's photo.
  @override
  Future<String?> fetchPhotoUri(String photoName) async => null;

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body().timeout(timeout);
    } on TimeoutException {
      throw const NetworkFailure();
    } on firestore.FirebaseException catch (error) {
      // TEMP(debug): remove after the device check.
      debugPrint('RANGO_FIRESTORE ${error.code}: ${error.message}');
      throw error.code == 'unavailable'
          ? const NetworkFailure()
          : const UnexpectedFailure();
    }
  }

  /// Null for a place the app must not show: removed from the sheet
  /// (`active` false) or without a name or position.
  static Restaurant? _toRestaurant(String id, Map<String, Object?> data) {
    final name = _text(data['name']);
    final location = data['location'];
    if (data['active'] != true ||
        name == null ||
        location is! firestore.GeoPoint) {
      return null;
    }
    return Restaurant(
      placeId: id,
      name: name,
      location: GeoPoint(lat: location.latitude, lng: location.longitude),
      cuisine: _text(data['cuisine']),
      address: _text(data['address']),
      rating: switch (data['rating']) {
        final num rating => rating.toDouble(),
        _ => null,
      },
    );
  }

  static String? _text(Object? value) => switch (value) {
    final String text when text.trim().isNotEmpty => text.trim(),
    _ => null,
  };
}
