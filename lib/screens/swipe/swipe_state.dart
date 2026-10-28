import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rango_app/models/duel_state.dart';
import 'package:rango_app/models/food_category.dart';

part 'swipe_state.freezed.dart';

@freezed
abstract class SwipeState with _$SwipeState {
  const factory SwipeState({
    required FoodCategory current,
    required List<FoodCategory> options,
    @Default(<FoodCategory>[]) List<FoodCategory> history,

    /// Null at the root; set once the user picks Salgado or Doce.
    DuelState? duel,
    FoodCategory? result,
  }) = _SwipeState;

  const SwipeState._();

  bool get hasConverged => result != null;

  /// Headline for the current level: "A ou\nb?" built from the two options.
  String get title {
    if (history.isEmpty || options.length != 2) {
      return 'Bora decidir\no Rango?';
    }
    final second = options[1].label;
    final lowered = second.isEmpty
        ? second
        : '${second[0].toLowerCase()}${second.substring(1)}';
    return '${options[0].label} ou\n$lowered?';
  }

  String get subtitle => switch (duel) {
    null => 'Toque ou arraste o card que deu mais vontade.',
    DuelState(streak: 0) =>
      '${current.label}, anotado. Agora é duelo: quem ganha fica.',
    DuelState(:final champion, streak: 1) =>
      '${champion.label} está ganhando com 1 vitória.',
    DuelState(:final champion) =>
      '${champion.label} está ganhando, mais uma e ele será o escolhido.',
  };
}
