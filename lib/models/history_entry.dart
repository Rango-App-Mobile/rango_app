import 'package:freezed_annotation/freezed_annotation.dart';

part 'history_entry.freezed.dart';

/// One finished decision in the Histórico: the food the session converged on,
/// the restaurant picked and when. A draft of the saved session of
/// `docs/contexto.md` §8, enough to draw the list until E2-S4 persists it.
@freezed
abstract class HistoryEntry with _$HistoryEntry {
  const factory HistoryEntry({
    required String id,

    /// Id of the `FoodCategory` that won the session, e.g. "spaghetti".
    required String foodId,
    required String restaurantName,
    required DateTime decidedAt,

    /// Kind of place and neighborhood, e.g. "Italiana · Moinhos de Vento".
    String? cuisine,
  }) = _HistoryEntry;
}
