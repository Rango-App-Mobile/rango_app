import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rango_app/models/food_category.dart';
import 'package:rango_app/models/history_entry.dart';

part 'history_detail_state.freezed.dart';

@freezed
abstract class HistoryDetailState with _$HistoryDetailState {
  const factory HistoryDetailState({
    required HistoryEntry entry,
    required FoodCategory food,

    /// "O caminho até aqui": the group, then the food ("Salgado", "Macarrão").
    required List<String> path,
  }) = _HistoryDetailState;

  const HistoryDetailState._();

  /// "21 set, 20:14": the chip under the title.
  String get dateLabel {
    final date = entry.decidedAt;
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${date.day} ${_shortMonths[date.month - 1]}, '
        '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  }

  static const _shortMonths = [
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];
}
