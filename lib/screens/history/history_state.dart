import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rango_app/models/food_category.dart';
import 'package:rango_app/models/history_entry.dart';

part 'history_state.freezed.dart';

/// A decision ready to draw: the saved entry and the food it points to.
@freezed
abstract class HistoryItem with _$HistoryItem {
  const factory HistoryItem({
    required HistoryEntry entry,
    required FoodCategory food,
  }) = _HistoryItem;

  const HistoryItem._();

  /// "21 set": the chip on the card.
  String get dateLabel {
    final date = entry.decidedAt;
    return '${date.day} ${HistoryState.shortMonths[date.month - 1]}';
  }
}

@freezed
abstract class HistoryState with _$HistoryState {
  const factory HistoryState({
    /// From the oldest to the newest: the newest is drawn in front.
    @Default(<HistoryItem>[]) List<HistoryItem> items,
  }) = _HistoryState;

  const HistoryState._();

  bool get isEmpty => items.isEmpty;

  /// "9 rangos decididos desde setembro."
  String get subtitle {
    final count = items.length;
    final since = isEmpty ? '' : months[items.first.entry.decidedAt.month - 1];
    final noun = count == 1 ? 'rango decidido' : 'rangos decididos';
    return '$count $noun desde $since.';
  }

  static const months = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  static const shortMonths = [
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
