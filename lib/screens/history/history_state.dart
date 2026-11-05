import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rango_app/models/food_category.dart';
import 'package:rango_app/models/history_entry.dart';

part 'history_state.freezed.dart';

/// A month of the Histórico: its name, "5 rangos" and where it starts in
/// [HistoryState.items].
typedef HistoryMonth = ({String label, String countLabel, int firstIndex});

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

  /// The decisions grouped by month, in the same order as [items].
  List<HistoryMonth> get months {
    final months = <HistoryMonth>[];
    var first = 0;
    for (var i = 1; i <= items.length; i++) {
      if (i < items.length && _sameMonth(items[first], items[i])) continue;
      final count = i - first;
      months.add((
        label: monthNames[items[first].entry.decidedAt.month - 1],
        countLabel: '$count ${count == 1 ? 'rango' : 'rangos'}',
        firstIndex: first,
      ));
      first = i;
    }
    return months;
  }

  static bool _sameMonth(HistoryItem a, HistoryItem b) {
    final (first, second) = (a.entry.decidedAt, b.entry.decidedAt);
    return first.year == second.year && first.month == second.month;
  }

  static const monthNames = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
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
