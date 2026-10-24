import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/fake_category_repository.dart';
import 'package:rango_app/screens/result/result_view_model.dart';

ProviderContainer makeContainer() {
  final container = ProviderContainer(
    overrides: [
      categoryRepositoryProvider.overrideWithValue(FakeCategoryRepository()),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('resolves the path in order and exposes the last as result', () async {
    final container = makeContainer();
    final state = await container.read(
      resultViewModelProvider('savory,pasta,spaghetti').future,
    );

    expect(state.path.map((c) => c.id), ['savory', 'pasta', 'spaghetti']);
    expect(state.result.id, 'spaghetti');
  });

  test('formats the path label and counts the choices', () async {
    final container = makeContainer();
    final state = await container.read(
      resultViewModelProvider('savory,pasta,spaghetti').future,
    );

    expect(state.pathLabel, 'Salgado, massa, macarrão');
    expect(state.choiceCount, 3);
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
