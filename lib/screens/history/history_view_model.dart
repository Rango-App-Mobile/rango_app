import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/history_repository.dart';
import 'package:rango_app/screens/history/history_state.dart';

final historyViewModelProvider =
    AsyncNotifierProvider<HistoryViewModel, HistoryState>(
      HistoryViewModel.new,
    );

class HistoryViewModel extends AsyncNotifier<HistoryState> {
  @override
  Future<HistoryState> build() async {
    // Both watched before the first await, so both load at the same time.
    final entriesFuture = ref.watch(historyEntriesProvider.future);
    final categoriesFuture = ref.watch(categoriesProvider.future);
    final entries = await entriesFuture;
    final categories = await categoriesFuture;
    final foods = {for (final category in categories) category.id: category};

    final items = [
      for (final entry in entries)
        // A food taken off the menu has nothing to draw: skip the entry.
        if (foods[entry.foodId] case final food?)
          HistoryItem(entry: entry, food: food),
    ]..sort((a, b) => a.entry.decidedAt.compareTo(b.entry.decidedAt));
    return HistoryState(items: items);
  }
}
