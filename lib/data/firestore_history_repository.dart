import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/history_repository.dart';
import 'package:rango_app/models/history_entry.dart';
import 'package:rango_app/models/order_channel.dart';

/// One document per decision in `users/{uid}/sessions/{autoId}`.
class FirestoreHistoryRepository implements HistoryRepository {
  FirestoreHistoryRepository(
    this._firestore, {
    this.timeout = const Duration(seconds: 10),
  });

  final FirebaseFirestore _firestore;
  final Duration timeout;

  CollectionReference<Map<String, dynamic>> _sessions(String uid) =>
      _firestore.collection('users').doc(uid).collection('sessions');

  @override
  Future<List<HistoryEntry>> fetchAll(String uid) async {
    try {
      // ponytail: newest 100 only; paginate when someone has more.
      final snapshot = await _sessions(uid)
          .orderBy('decidedAt', descending: true)
          .limit(100)
          // A save still waiting for the server has no decidedAt yet.
          .get(
            const GetOptions(
              serverTimestampBehavior: ServerTimestampBehavior.estimate,
            ),
          )
          .timeout(timeout);
      return [for (final doc in snapshot.docs) ?_parse(doc.id, doc.data())];
    } on FirebaseException catch (e) {
      // TEMP(debug): remove after the device check.
      debugPrint('RANGO_FIRESTORE ${e.code}: ${e.message}');
      throw e.code == 'unavailable'
          ? const NetworkFailure()
          : const UnexpectedFailure();
    } on TimeoutException {
      throw const NetworkFailure();
    }
  }

  /// [HistoryEntry.id] and [HistoryEntry.decidedAt] are ignored: Firestore
  /// picks the id and the server the time.
  @override
  Future<void> save(String uid, HistoryEntry entry) async {
    // Not awaited: Firestore applies the write locally at once, but the
    // future only completes when the server confirms, never while offline.
    unawaited(_add(uid, entry));
  }

  Future<void> _add(String uid, HistoryEntry entry) async {
    try {
      await _sessions(uid).add({
        'foodId': entry.foodId,
        'restaurantId': entry.restaurantId,
        'restaurantName': entry.restaurantName,
        'cuisine': entry.cuisine,
        'channel': entry.channel.name,
        'decidedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException {
      // A lost decision is not worth interrupting the order for.
    }
  }

  /// A document with a missing or wrong field is skipped, not fatal.
  HistoryEntry? _parse(String id, Map<String, dynamic> data) {
    if (data case {
      'foodId': final String foodId,
      'restaurantId': final String restaurantId,
      'restaurantName': final String restaurantName,
      'channel': final String channelName,
      'decidedAt': final Timestamp decidedAt,
    }) {
      final channel = OrderChannel.values.asNameMap()[channelName];
      if (channel == null) return null;
      final cuisine = data['cuisine'];
      return HistoryEntry(
        id: id,
        foodId: foodId,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        cuisine: cuisine is String ? cuisine : null,
        channel: channel,
        decidedAt: decidedAt.toDate(),
      );
    }
    return null;
  }
}
