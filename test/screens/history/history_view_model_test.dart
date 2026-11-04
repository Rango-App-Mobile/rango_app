import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/fake_history_repository.dart';
import 'package:rango_app/data/history_repository.dart';
import 'package:rango_app/data/local_category_repository.dart';
import 'package:rango_app/models/history_entry.dart';
import 'package:rango_app/screens/history/history_state.dart';
import 'package:rango_app/screens/history/history_view_model.dart';

class _MockHistoryRepository extends Mock implements HistoryRepository {}

Future<HistoryState> load(List<HistoryEntry> entries) {
  final container = ProviderContainer.test(
    overrides: [
      categoryRepositoryProvider.overrideWithValue(LocalCategoryRepository()),
      historyRepositoryProvider.overrideWithValue(
        FakeHistoryRepository(entries: entries),
      ),
    ],
  );
  return container.read(historyViewModelProvider.future);
}

HistoryEntry entry(String id, String foodId, DateTime at) => HistoryEntry(
  id: id,
  foodId: foodId,
  restaurantName: 'Restaurante $id',
  decidedAt: at,
);

void main() {
  test('lists the decisions from the oldest to the newest', () async {
    final state = await load([
      entry('b', 'pizza', DateTime(2026, 10, 2)),
      entry('c', 'sushi', DateTime(2026, 10, 9)),
      entry('a', 'acai', DateTime(2026, 9, 6)),
    ]);

    expect(state.items.map((item) => item.entry.id), ['a', 'b', 'c']);
    expect(state.items.last.food.label, 'Sushi');
    expect(state.isEmpty, isFalse);
  });

  test('skips decisions whose food is no longer on the menu', () async {
    final state = await load([
      entry('a', 'pizza', DateTime(2026, 10, 2)),
      entry('b', 'gone', DateTime(2026, 10, 3)),
    ]);

    expect(state.items.map((item) => item.entry.id), ['a']);
  });

  test('no decisions is the empty state', () async {
    final state = await load(const []);

    expect(state.isEmpty, isTrue);
  });

  test('the subtitle counts the decisions since the first month', () async {
    final state = await load([
      entry('a', 'acai', DateTime(2026, 8, 30)),
      entry('b', 'pizza', DateTime(2026, 10, 2)),
    ]);

    expect(state.subtitle, '2 rangos decididos desde agosto.');
  });

  test('one decision is singular', () async {
    final state = await load([entry('a', 'pizza', DateTime(2026, 10, 2))]);

    expect(state.subtitle, '1 rango decidido desde outubro.');
  });

  test('each item shows the day and the short month', () async {
    final state = await load([entry('a', 'pizza', DateTime(2026, 9, 21))]);

    expect(state.items.single.dateLabel, '21 set');
  });

  test('the sample history has decisions over more than one month', () async {
    final state = await load(FakeHistoryRepository.sample);

    expect(state.items, hasLength(FakeHistoryRepository.sample.length));
    expect(state.subtitle, contains('desde setembro'));
  });

  test('exposes the error when the repository fails', () async {
    final repository = _MockHistoryRepository();
    when(repository.fetchAll).thenThrow(Exception('offline'));
    final container = ProviderContainer.test(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(LocalCategoryRepository()),
        historyRepositoryProvider.overrideWithValue(repository),
      ],
      retry: (_, _) => null,
    );

    await expectLater(
      container.read(historyViewModelProvider.future),
      throwsA(isA<Exception>()),
    );
  });
}
