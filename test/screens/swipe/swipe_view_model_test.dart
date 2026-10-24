import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/fake_category_repository.dart';
import 'package:rango_app/models/food_category.dart';
import 'package:rango_app/screens/swipe/swipe_view_model.dart';

class _MockCategoryRepository extends Mock implements CategoryRepository {}

FoodCategory _byId(String id) =>
    FakeCategoryRepository.seed.firstWhere((c) => c.id == id);

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer.test(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(FakeCategoryRepository()),
      ],
    );
  });

  test('starts at the root with its two options', () async {
    final state = await container.read(swipeViewModelProvider.future);

    expect(state.current.id, 'root');
    expect(state.options.map((c) => c.id), ['savory', 'sweet']);
    expect(state.hasConverged, isFalse);
  });

  test('converges after choosing down to a leaf', () async {
    await container.read(swipeViewModelProvider.future);
    container.read(swipeViewModelProvider.notifier)
      ..choose(_byId('savory'))
      ..choose(_byId('pasta'))
      ..choose(_byId('pizza'));

    final state = container.read(swipeViewModelProvider).requireValue;
    expect(state.result?.id, 'pizza');
    expect(state.history.map((c) => c.id), ['savory', 'pasta', 'pizza']);
  });

  test('ignores an option that is not currently offered', () async {
    await container.read(swipeViewModelProvider.future);
    container.read(swipeViewModelProvider.notifier).choose(_byId('pizza'));

    final state = container.read(swipeViewModelProvider).requireValue;
    expect(state.current.id, 'root');
    expect(state.history, isEmpty);
  });

  test('reset goes back to the root and clears history', () async {
    await container.read(swipeViewModelProvider.future);
    container.read(swipeViewModelProvider.notifier)
      ..choose(_byId('sweet'))
      ..reset();

    final state = container.read(swipeViewModelProvider).requireValue;
    expect(state.current.id, 'root');
    expect(state.history, isEmpty);
  });

  group('derived state', () {
    test('title and subtitle at the root', () async {
      final state = await container.read(swipeViewModelProvider.future);

      expect(state.title, 'Bora decidir\no Rango?');
      expect(state.subtitle, 'Toque ou arraste o card que deu mais vontade.');
    });

    test('title and subtitle after choosing Salgado', () async {
      await container.read(swipeViewModelProvider.future);
      container.read(swipeViewModelProvider.notifier).choose(_byId('savory'));

      final state = container.read(swipeViewModelProvider).requireValue;
      expect(state.title, 'Massa ou\nlanche?');
      expect(state.subtitle, 'Salgado, anotado. Agora afunila.');
    });
  });

  test('exposes the error when the repository fails', () async {
    final repository = _MockCategoryRepository();
    when(repository.fetchAll).thenThrow(Exception('offline'));
    final failing = ProviderContainer.test(
      overrides: [categoryRepositoryProvider.overrideWithValue(repository)],
      retry: (_, _) => null,
    );

    await expectLater(
      failing.read(swipeViewModelProvider.future),
      throwsA(isA<Exception>()),
    );
  });
}
