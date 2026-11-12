import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rango_app/models/order_channel.dart';

part 'history_entry.freezed.dart';

/// One finished decision in the Histórico: the food the session converged on,
/// the restaurant picked, how it was reached and when. Saved in
/// `users/{uid}/sessions` (`docs/contexto.md` §8).
@freezed
abstract class HistoryEntry with _$HistoryEntry {
  const factory HistoryEntry({
    /// Assigned by the repository when saved; ignored by `save`.
    required String id,

    /// Id of the `FoodCategory` that won the session, e.g. "spaghetti".
    required String foodId,
    required String restaurantId,
    required String restaurantName,
    required OrderChannel channel,
    required DateTime decidedAt,

    /// Kind of place and neighborhood, e.g. "Italiana · Moinhos de Vento".
    String? cuisine,
  }) = _HistoryEntry;
}
