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

  /// "Salgado, massa, macarrão": the first label as is, the rest lowercase.
  String get pathLabel => [
    for (final (index, choice) in path.indexed)
      if (index == 0) choice.label else _lowerFirst(choice.label),
  ].join(', ');

  int get choiceCount => path.length;

  static String _lowerFirst(String text) =>
      text.isEmpty ? text : '${text[0].toLowerCase()}${text.substring(1)}';
}
