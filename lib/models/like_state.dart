import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rango_app/models/food_category.dart';

part 'like_state.freezed.dart';

/// One moment of a `LikeGame`: the card on top, the cards still to come in
/// this round, the likes so far and the foods passed for good.
@freezed
abstract class LikeState with _$LikeState {
  const factory LikeState({
    required FoodCategory current,

    /// Cards after [current]. Never empty while the game is on: the game
    /// deals the next round as soon as the last card of a round is on top.
    required List<FoodCategory> queue,

    /// Likes one food needs to win the game.
    required int likesToMatch,

    /// Likes per food id. They add up across rounds and never reset.
    @Default(<String, int>{}) Map<String, int> likes,

    /// Ids of the foods passed in this session; they are out of the deck.
    @Default(<String>{}) Set<String> passedIds,
    FoodCategory? winner,
  }) = _LikeState;

  const LikeState._();

  bool get isOver => winner != null;

  /// The card behind [current], peeking out of the stack.
  FoodCategory? get next => queue.isEmpty ? null : queue.first;

  int likesOf(FoodCategory food) => likes[food.id] ?? 0;
}
