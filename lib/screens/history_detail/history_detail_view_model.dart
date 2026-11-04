import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/history_repository.dart';
import 'package:rango_app/models/food_category.dart';
import 'package:rango_app/models/history_entry.dart';
import 'package:rango_app/screens/history_detail/history_detail_state.dart';

/// Family argument is the id of the decision, from the route.
// The family type is not exported by Riverpod, so it cannot be annotated.
// ignore: specify_nonobvious_property_types
final historyDetailViewModelProvider =
    NotifierProvider.family<
      HistoryDetailViewModel,
      AsyncValue<HistoryDetailState>,
      String
    >(HistoryDetailViewModel.new);

/// Synchronous on purpose: when the Histórico opens a decision, the entries
/// and the menu are already loaded, so the detail is data on its very first
/// frame. That is what lets the card fly from the pile into this screen (a
/// Hero needs both ends on screen when the push starts). Opened cold (a deep
/// link), it goes through loading like any other screen.
class HistoryDetailViewModel extends Notifier<AsyncValue<HistoryDetailState>> {
  HistoryDetailViewModel(this.entryId);

  final String entryId;

  @override
  AsyncValue<HistoryDetailState> build() {
    final entries = ref.watch(historyEntriesProvider);
    final categories = ref.watch(categoriesProvider);
    return switch ((entries, categories)) {
      (AsyncError(:final error, :final stackTrace), _) ||
      (_, AsyncError(:final error, :final stackTrace)) => AsyncError(
        error,
        stackTrace,
      ),
      (AsyncData(value: final entries), AsyncData(value: final categories)) =>
        _resolveOrError(entries, categories),
      _ => const AsyncLoading(),
    };
  }

  AsyncValue<HistoryDetailState> _resolveOrError(
    List<HistoryEntry> entries,
    List<FoodCategory> categories,
  ) {
    final entry = entries.where((entry) => entry.id == entryId).firstOrNull;
    if (entry == null) {
      return AsyncError(
        ArgumentError.value(entryId, 'entryId', 'Unknown decision'),
        StackTrace.current,
      );
    }
    final byId = {for (final category in categories) category.id: category};
    final food = byId[entry.foodId];
    if (food == null) {
      return AsyncError(
        ArgumentError.value(entry.foodId, 'foodId', 'Unknown food'),
        StackTrace.current,
      );
    }
    final group = byId[food.parentId];
    return AsyncData(
      HistoryDetailState(
        entry: entry,
        food: food,
        path: [?group?.label, food.label],
      ),
    );
  }
}
