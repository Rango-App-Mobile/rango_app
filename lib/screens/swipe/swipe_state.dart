import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rango_app/models/food_category.dart';
import 'package:rango_app/models/like_state.dart';

part 'swipe_state.freezed.dart';

@freezed
abstract class SwipeState with _$SwipeState {
  const factory SwipeState({
    /// The root, then the group the user picked (Salgado or Doce).
    required FoodCategory current,

    /// The two root options; empty once the game is on.
    required List<FoodCategory> options,

    /// The group, then every swiped card (liked or passed), in order.
    @Default(<FoodCategory>[]) List<FoodCategory> history,

    /// Null at the root; set once the user picks Salgado or Doce.
    LikeState? game,
    FoodCategory? result,
  }) = _SwipeState;

  const SwipeState._();

  bool get hasConverged => result != null;

  /// Only the root has a header: on the card screen the card speaks for
  /// itself (Figma "02 Card único": meter, deck and buttons only).
  String? get title => switch (game) {
    null => 'Bora decidir\no Rango?',
    LikeState() => null,
  };

  String? get subtitle => switch (game) {
    null => 'Toque ou arraste o card que deu mais vontade.',
    LikeState() => null,
  };
}
