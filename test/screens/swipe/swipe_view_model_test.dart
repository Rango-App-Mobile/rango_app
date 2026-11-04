import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/local_category_repository.dart';
import 'package:rango_app/models/food_category.dart';
import 'package:rango_app/screens/swipe/swipe_state.dart';
import 'package:rango_app/screens/swipe/swipe_view_model.dart';

import '../../helpers/in_order_random.dart';

class _MockCategoryRepository extends Mock implements CategoryRepository {}

FoodCategory _byId(String id) =>
    LocalCategoryRepository.seed.firstWhere((c) => c.id == id);

void main() {
  late ProviderContainer container;

  SwipeViewModel viewModel() => container.read(swipeViewModelProvider.notifier);
  SwipeState state() => container.read(swipeViewModelProvider).requireValue;

  setUp(() {
    container = ProviderContainer.test(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(LocalCategoryRepository()),
        deckRandomProvider.overrideWithValue(InOrderRandom()),
      ],
    );
  });

  /// Likes [id] whenever it is on top and passes everything else.
  void favor(String id) {
    while (!state().hasConverged) {
      if (state().game?.current.id == id) {
        viewModel().like();
      } else {
        viewModel().pass();
      }
    }
  }

  test('starts at the root with its two options', () async {
    final initial = await container.read(swipeViewModelProvider.future);

    expect(initial.current.id, 'root');
    expect(initial.options.map((c) => c.id), ['savory', 'sweet']);
    expect(initial.game, isNull);
    expect(initial.hasConverged, isFalse);
  });

  test('choosing a group deals its foods one card at a time', () async {
    await container.read(swipeViewModelProvider.future);
    viewModel().choose(_byId('savory'));

    expect(state().current.id, 'savory');
    expect(state().options, isEmpty);
    expect(state().game?.current.id, 'spaghetti');
    expect(state().game?.next?.id, 'pizza');
    expect(state().history.map((c) => c.id), ['savory']);
  });

  test('liking counts a like and shows the next card', () async {
    await container.read(swipeViewModelProvider.future);
    viewModel()
      ..choose(_byId('savory'))
      ..like();

    expect(state().game?.likesOf(_byId('spaghetti')), 1);
    expect(state().game?.current.id, 'pizza');
  });

  test('passing takes the food out and shows the next card', () async {
    await container.read(swipeViewModelProvider.future);
    viewModel()
      ..choose(_byId('savory'))
      ..pass();

    expect(state().game?.passedIds, {'spaghetti'});
    expect(state().game?.current.id, 'pizza');
  });

  test('every swipe goes into the history', () async {
    await container.read(swipeViewModelProvider.future);
    viewModel()
      ..choose(_byId('savory'))
      ..like()
      ..pass();

    expect(state().history.map((c) => c.id), ['savory', 'spaghetti', 'pizza']);
  });

  test('three likes on the same food converge on it', () async {
    await container.read(swipeViewModelProvider.future);
    viewModel().choose(_byId('savory'));
    favor('pizza');

    expect(state().result?.id, 'pizza');
    expect(state().history.first.id, 'savory');
    expect(state().history.last.id, 'pizza');
    expect(state().history.where((c) => c.id == 'pizza'), hasLength(3));
  });

  test('swipes are ignored at the root and after the match', () async {
    await container.read(swipeViewModelProvider.future);
    viewModel()
      ..like()
      ..pass();
    expect(state().history, isEmpty);

    viewModel().choose(_byId('sweet'));
    favor('ice_cream');
    final matched = state();
    viewModel()
      ..like()
      ..pass();

    expect(state(), matched);
  });

  test('choose is ignored once the game is on', () async {
    await container.read(swipeViewModelProvider.future);
    viewModel()
      ..choose(_byId('savory'))
      ..choose(_byId('sweet'));

    expect(state().current.id, 'savory');
    expect(state().history, hasLength(1));
  });

  test('ignores an option that is not offered at the root', () async {
    await container.read(swipeViewModelProvider.future);
    viewModel().choose(_byId('pizza'));

    expect(state().current.id, 'root');
    expect(state().history, isEmpty);
  });

  test('reset goes back to the root and clears the game', () async {
    await container.read(swipeViewModelProvider.future);
    viewModel()
      ..choose(_byId('sweet'))
      ..like()
      ..reset();

    expect(state().current.id, 'root');
    expect(state().history, isEmpty);
    expect(state().game, isNull);
  });

  group('derived state', () {
    test('title and subtitle at the root', () async {
      final initial = await container.read(swipeViewModelProvider.future);

      expect(initial.title, 'Bora decidir\no Rango?');
      expect(
        initial.subtitle,
        'Toque ou arraste o card que deu mais vontade.',
      );
    });

    test('the card screen has no title or subtitle', () async {
      await container.read(swipeViewModelProvider.future);
      viewModel().choose(_byId('savory'));

      expect(state().title, isNull);
      expect(state().subtitle, isNull);
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
