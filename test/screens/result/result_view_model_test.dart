import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/local_category_repository.dart';
import 'package:rango_app/screens/result/result_view_model.dart';

ProviderContainer makeContainer() {
  final container = ProviderContainer(
    overrides: [
      categoryRepositoryProvider.overrideWithValue(LocalCategoryRepository()),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  const duelPath = 'savory,spaghetti,pizza,pizza,pizza';

  test(
    'resolves every choice in order and exposes the last as result',
    () async {
      final container = makeContainer();
      final state = await container.read(
        resultViewModelProvider(duelPath).future,
      );

      expect(state.path.map((c) => c.id), duelPath.split(','));
      expect(state.result.id, 'pizza');
    },
  );

  test('labels the group and the winner and counts every choice', () async {
    final container = makeContainer();
    final state = await container.read(
      resultViewModelProvider(duelPath).future,
    );

    expect(state.pathLabel, 'Salgado, pizza');
    expect(state.choiceCount, 5);
  });

  test('an unknown id is an error', () async {
    final container = makeContainer();
    final provider = resultViewModelProvider('savory,nope');
    container.listen(provider, (_, _) {});
    await expectLater(container.read(provider.future), throwsArgumentError);
    expect(container.read(provider), isA<AsyncError<dynamic>>());
  });

  test('an empty path is an error', () async {
    final container = makeContainer();
    final provider = resultViewModelProvider('');
    container.listen(provider, (_, _) {});
    await expectLater(container.read(provider.future), throwsArgumentError);
    expect(container.read(provider), isA<AsyncError<dynamic>>());
  });
}
