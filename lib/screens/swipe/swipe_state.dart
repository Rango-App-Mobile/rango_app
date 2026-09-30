import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rango_app/models/food_category.dart';

part 'swipe_state.freezed.dart';

@freezed
abstract class SwipeState with _$SwipeState {
  const factory SwipeState({
    required FoodCategory current,
    required List<FoodCategory> options,
    @Default(<FoodCategory>[]) List<FoodCategory> history,
    FoodCategory? result,
  }) = _SwipeState;

  const SwipeState._();

  bool get hasConverged => result != null;
}
