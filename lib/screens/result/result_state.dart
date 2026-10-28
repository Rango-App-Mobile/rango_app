import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rango_app/models/food_category.dart';

part 'result_state.freezed.dart';

@freezed
abstract class ResultState with _$ResultState {
  const factory ResultState({
    required FoodCategory result,
    required List<FoodCategory> path,
  }) = _ResultState;

  const ResultState._();

  /// "Salgado, pizza": the group the user picked and the duel winner.
  String get pathLabel => '${path.first.label}, ${_lowerFirst(result.label)}';

  int get choiceCount => path.length;

  static String _lowerFirst(String text) =>
      text.isEmpty ? text : '${text[0].toLowerCase()}${text.substring(1)}';
}
