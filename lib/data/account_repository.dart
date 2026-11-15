import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/data/firestore_account_repository.dart';

/// The version of the Terms of Use and Privacy Policy the app asks for.
/// Raising it makes `hasAcceptedTerms` false for everyone again.
const currentTermsVersion = 1;

/// The person's own `users/{uid}` document. Every method throws a `Failure`
/// when it cannot do its job.
abstract interface class AccountRepository {
  /// Whether the person accepted [currentTermsVersion] (or a newer one).
  Future<bool> hasAcceptedTerms(String uid);

  /// Records the acceptance of [currentTermsVersion], now.
  Future<void> acceptTerms(String uid);

  /// Deletes everything stored for [uid]: the sessions and the user document.
  Future<void> deleteData(String uid);
}

/// Real Firestore by default; `main.dart` swaps in the fake when Firebase is
/// not configured, and tests override this provider.
final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => FirestoreAccountRepository(FirebaseFirestore.instance),
);
