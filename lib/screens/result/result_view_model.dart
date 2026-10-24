import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/screens/result/result_state.dart';

/// Family argument is the comma-joined path ids (e.g. "savory,pasta,spaghetti")
/// rather than a List, because family arguments need value equality.
// The family type is not exported by Riverpod, so it cannot be annotated.
// ignore: specify_nonobvious_property_types
final resultViewModelProvider =
    AsyncNotifierProvider.family<ResultViewModel, ResultState, String>(
      ResultViewModel.new,
    );

class ResultViewModel extends AsyncNotifier<ResultState> {
  ResultViewModel(this.pathKey);

  final String pathKey;

  @override
  Future<ResultState> build() async {
    final ids = pathKey.split(',').where((id) => id.isNotEmpty).toList();
    if (ids.isEmpty) throw ArgumentError('Empty result path');

    final categories = await ref.watch(categoryRepositoryProvider).fetchAll();
    final byId = {for (final category in categories) category.id: category};
    final path = [
      for (final id in ids)
        byId[id] ?? (throw ArgumentError.value(id, 'id', 'Unknown category')),
    ];
    return ResultState(result: path.last, path: path);
  }
}
