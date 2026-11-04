import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/fake_history_repository.dart';
import 'package:rango_app/data/history_repository.dart';
import 'package:rango_app/data/local_category_repository.dart';
import 'package:rango_app/screens/history_detail/history_detail_state.dart';
import 'package:rango_app/screens/history_detail/history_detail_view_model.dart';

class _MockHistoryRepository extends Mock implements HistoryRepository {}

ProviderContainer makeContainer({HistoryRepository? history}) =>
    ProviderContainer.test(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(LocalCategoryRepository()),
        historyRepositoryProvider.overrideWithValue(
          history ?? FakeHistoryRepository(),
        ),
      ],
      retry: (_, _) => null,
    );

/// Loads what the Histórico loads before the user can tap a card.
Future<ProviderContainer> afterHistory() async {
  final container = makeContainer();
  await container.read(historyEntriesProvider.future);
  await container.read(categoriesProvider.future);
  return container;
}

void main() {
  test('is ready at once when the history is already loaded', () async {
    final container = await afterHistory();

    final detail = container.read(historyDetailViewModelProvider('h9'));

    expect(detail, isA<AsyncData<HistoryDetailState>>());
  });

  test('resolves the decision, its food and its group', () async {
    final container = await afterHistory();
    final state = container
        .read(historyDetailViewModelProvider('h9'))
        .requireValue;

    expect(state.food.label, 'Macarrão');
    expect(state.entry.restaurantName, 'Cantina da Nona');
    expect(state.path, ['Salgado', 'Macarrão']);
  });

  test('the date label has the day, the short month and the time', () async {
    final container = await afterHistory();
    final state = container
        .read(historyDetailViewModelProvider('h9'))
        .requireValue;

    expect(state.dateLabel, '1 nov, 12:30');
  });

  test('hours and minutes keep two digits', () async {
    final container = await afterHistory();
    final state = container
        .read(historyDetailViewModelProvider('h3'))
        .requireValue;

    expect(state.dateLabel, '20 set, 13:00');
  });

  test('opened cold, it loads and then shows the decision', () async {
    final container = makeContainer();
    final provider = historyDetailViewModelProvider('h9');
    container.listen(provider, (_, _) {});

    expect(container.read(provider), isA<AsyncLoading<HistoryDetailState>>());
    await container.read(historyEntriesProvider.future);
    await container.read(categoriesProvider.future);
    expect(container.read(provider).requireValue.food.id, 'spaghetti');
  });

  test('an unknown id is an error', () async {
    final container = await afterHistory();

    expect(
      container.read(historyDetailViewModelProvider('nope')),
      isA<AsyncError<HistoryDetailState>>(),
    );
  });

  test('a failing history is an error', () async {
    final failing = _MockHistoryRepository();
    when(failing.fetchAll).thenThrow(Exception('offline'));
    final container = makeContainer(history: failing);
    final provider = historyDetailViewModelProvider('h9');
    container.listen(provider, (_, _) {});

    await expectLater(
      container.read(historyEntriesProvider.future),
      throwsA(isA<Exception>()),
    );
    expect(container.read(provider), isA<AsyncError<HistoryDetailState>>());
  });
}
