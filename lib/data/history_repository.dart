import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/data/firestore_history_repository.dart';
import 'package:rango_app/models/history_entry.dart';

/// Decisions of one account user. Callers keep guests out
/// (`docs/contexto.md` R1); the repository only knows the uid.
abstract interface class HistoryRepository {
  /// The user's finished decisions, in any order. Throws a `Failure`.
  Future<List<HistoryEntry>> fetchAll(String uid);

  /// Saves [entry] under a new id. Never throws: a lost save must not stop
  /// the person from ordering.
  Future<void> save(String uid, HistoryEntry entry);
}

/// Real Firestore by default; `main.dart` swaps in the fake when Firebase is
/// not configured, and tests override this provider.
final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => FirestoreHistoryRepository(FirebaseFirestore.instance),
);

/// The decisions, loaded once and kept, so the detail of one of them is
/// ready on the first frame after the Histórico opens it. Reloads when the
/// account changes (sign-in, sign-up, sign-out); a guest has none (R1).
// Riverpod's automatic retry is off: it would keep this in loading for
// ~40s and hide the error state.
final historyEntriesProvider = FutureProvider<List<HistoryEntry>>((ref) async {
  final repository = ref.watch(historyRepositoryProvider);
  final uid = await ref.watch(
    currentUserProvider.selectAsync(
      (user) => user.isAnonymous ? null : user.uid,
    ),
  );
  if (uid == null) return const [];
  return repository.fetchAll(uid);
}, retry: (_, _) => null);
