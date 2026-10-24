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

  String get subtitle => history.isEmpty
      ? 'Toque ou arraste o card que deu mais vontade.'
      : '${current.label}, anotado. Agora afunila.';
}
