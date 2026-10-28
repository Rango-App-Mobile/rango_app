import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/local_category_repository.dart';
import 'package:rango_app/models/food_category.dart';
import 'package:rango_app/screens/swipe/swipe_view_model.dart';

import '../../helpers/in_order_random.dart';

class _MockCategoryRepository extends Mock implements CategoryRepository {}

FoodCategory _byId(String id) =>
    LocalCategoryRepository.seed.firstWhere((c) => c.id == id);

void main() {
  late ProviderContainer container;

  SwipeViewModel viewModel() => container.read(swipeViewModelProvider.notifier);

  List<String> optionIds() => container
      .read(swipeViewModelProvider)
      .requireValue
      .options
      .map((c) => c.id)
      .toList();

  setUp(() {
    container = ProviderContainer.test(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(LocalCategoryRepository()),
        duelRandomProvider.overrideWithValue(InOrderRandom()),
      ],
    );
  });

  test('starts at the root with its two options', () async {
    final state = await container.read(swipeViewModelProvider.future);

    expect(state.current.id, 'root');
    expect(state.options.map((c) => c.id), ['savory', 'sweet']);
    expect(state.duel, isNull);
    expect(state.hasConverged, isFalse);
  });

  test('choosing a group starts a duel between its foods', () async {
    await container.read(swipeViewModelProvider.future);
    viewModel().choose(_byId('savory'));

    final state = container.read(swipeViewModelProvider).requireValue;
    expect(state.current.id, 'savory');
    expect(state.duel?.streak, 0);
    expect(optionIds(), ['spaghetti', 'pizza']);
  });

  test('the champion stays and meets the next challenger', () async {
    await container.read(swipeViewModelProvider.future);
    viewModel()
      ..choose(_byId('savory'))
      ..choose(_byId('spaghetti'));

    expect(optionIds(), ['spaghetti', 'burger']);
  });

  test('the challenger who wins takes the throne', () async {
    await container.read(swipeViewModelProvider.future);
    viewModel()
      ..choose(_byId('savory'))
      ..choose(_byId('pizza'));

    final state = container.read(swipeViewModelProvider).requireValue;
    expect(state.duel?.champion.id, 'pizza');
    expect(state.duel?.streak, 1);
    expect(optionIds(), ['pizza', 'burger']);
  });

  test('three wins in a row converge on the champion', () async {
    await container.read(swipeViewModelProvider.future);
    viewModel()
      ..choose(_byId('savory'))
      ..choose(_byId('spaghetti'))
      ..choose(_byId('spaghetti'))
      ..choose(_byId('spaghetti'));

    final state = container.read(swipeViewModelProvider).requireValue;
    expect(state.result?.id, 'spaghetti');
    expect(state.options, isEmpty);
    expect(state.history.map((c) => c.id), [
      'savory',
      'spaghetti',
      'spaghetti',
      'spaghetti',
    ]);
  });

  test('ignores an option that is not currently offered', () async {
    await container.read(swipeViewModelProvider.future);
    viewModel().choose(_byId('pizza'));

    final state = container.read(swipeViewModelProvider).requireValue;
    expect(state.current.id, 'root');
    expect(state.history, isEmpty);
  });

  test('reset goes back to the root and clears the duel', () async {
    await container.read(swipeViewModelProvider.future);
    viewModel()
      ..choose(_byId('sweet'))
      ..choose(_byId('ice_cream'))
      ..reset();

    final state = container.read(swipeViewModelProvider).requireValue;
    expect(state.current.id, 'root');
    expect(state.history, isEmpty);
    expect(state.duel, isNull);
  });

  group('derived state', () {
    test('title and subtitle at the root', () async {
      final state = await container.read(swipeViewModelProvider.future);

      expect(state.title, 'Bora decidir\no Rango?');
      expect(state.subtitle, 'Toque ou arraste o card que deu mais vontade.');
    });

    test('title and subtitle when the duel starts', () async {
      await container.read(swipeViewModelProvider.future);
      viewModel().choose(_byId('savory'));

      final state = container.read(swipeViewModelProvider).requireValue;
      expect(state.title, 'Macarrão ou\npizza?');
      expect(
        state.subtitle,
        'Salgado, anotado. Agora é duelo: quem ganha fica.',
      );
    });

    test('subtitle counts the champion wins', () async {
      await container.read(swipeViewModelProvider.future);
      viewModel()
        ..choose(_byId('savory'))
        ..choose(_byId('spaghetti'));
      expect(
        container.read(swipeViewModelProvider).requireValue.subtitle,
        'Macarrão está ganhando com 1 vitória.',
      );

      viewModel().choose(_byId('spaghetti'));
      expect(
        container.read(swipeViewModelProvider).requireValue.subtitle,
        'Macarrão está ganhando, mais uma e ele será o escolhido.',
      );
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
