import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/account_repository.dart';

/// `users/{uid}`, with the history in `users/{uid}/sessions`.
class FirestoreAccountRepository implements AccountRepository {
  FirestoreAccountRepository(
    this._firestore, {
    this.timeout = const Duration(seconds: 10),
  });

  final FirebaseFirestore _firestore;
  final Duration timeout;

  // Firestore allows 500 writes per batch.
  static const _batchSize = 500;

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _firestore.collection('users').doc(uid);

  @override
  Future<bool> hasAcceptedTerms(String uid) => _guard(() async {
    final snapshot = await _user(uid).get();
    final version = snapshot.data()?['termsVersion'];
    return snapshot.exists && version is int && version >= currentTermsVersion;
  });

  @override
  Future<void> acceptTerms(String uid) => _guard(
    () => _user(uid).set({
      'termsVersion': currentTermsVersion,
      'termsAcceptedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)),
  );

  @override
  Future<void> deleteData(String uid) => _guard(() async {
    final user = _user(uid);
    final sessions = (await user.collection('sessions').get()).docs;
    for (var i = 0; i < sessions.length; i += _batchSize) {
      final batch = _firestore.batch();
      for (final doc in sessions.skip(i).take(_batchSize)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
    await user.delete();
  });

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body().timeout(timeout);
    } on FirebaseException catch (e) {
      throw e.code == 'unavailable'
          ? const NetworkFailure()
          : const UnexpectedFailure();
    } on TimeoutException {
      throw const NetworkFailure();
    }
  }
}
