import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/data/fake_history_repository.dart';
import 'package:rango_app/models/history_entry.dart';

abstract interface class HistoryRepository {
  /// The user's finished decisions, in any order.
  Future<List<HistoryEntry>> fetchAll();
}

/// Fakes first (`CLAUDE.md`): the in-memory list with sample decisions is the
/// default until E2-S4 saves sessions in Firestore. Tests override it.
final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => FakeHistoryRepository(),
);

/// The decisions, loaded once and kept, so the detail of one of them is
/// ready on the first frame after the Histórico opens it.
final historyEntriesProvider = FutureProvider<List<HistoryEntry>>(
  (ref) => ref.watch(historyRepositoryProvider).fetchAll(),
);
