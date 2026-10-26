import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rango_app/models/food_category.dart';

part 'duel_state.freezed.dart';

@freezed
abstract class DuelState with _$DuelState {
  const factory DuelState({
    required FoodCategory champion,
    required FoodCategory challenger,
    required List<FoodCategory> queue,
    @Default(0) int streak,
    FoodCategory? winner,
  }) = _DuelState;

  const DuelState._();

  bool get isOver => winner != null;
}
