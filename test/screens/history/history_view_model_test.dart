import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/fake_auth_repository.dart';
import 'package:rango_app/data/fake_history_repository.dart';
import 'package:rango_app/data/history_repository.dart';
import 'package:rango_app/data/local_category_repository.dart';
import 'package:rango_app/models/app_user.dart';
import 'package:rango_app/models/history_entry.dart';
import 'package:rango_app/models/order_channel.dart';
import 'package:rango_app/screens/history/history_state.dart';
import 'package:rango_app/screens/history/history_view_model.dart';

class _MockHistoryRepository extends Mock implements HistoryRepository {}

Future<HistoryState> load(List<HistoryEntry> entries) {
  final container = ProviderContainer.test(
    overrides: [
      categoryRepositoryProvider.overrideWithValue(LocalCategoryRepository()),
      currentUserProvider.overrideWithValue(
        const AsyncData(AppUser(uid: 'u1', isAnonymous: false)),
      ),
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
  restaurantId: 'p-$id',
  restaurantName: 'Restaurante $id',
  channel: OrderChannel.delivery,
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

  test('groups the decisions by month, oldest first', () async {
    final state = await load([
      entry('a', 'acai', DateTime(2026, 8, 30)),
      entry('b', 'pizza', DateTime(2026, 10, 2)),
      entry('c', 'pastel', DateTime(2026, 10, 20)),
    ]);

    expect(state.months, [
      (label: 'Agosto', countLabel: '1 rango', firstIndex: 0),
      (label: 'Outubro', countLabel: '2 rangos', firstIndex: 1),
    ]);
  });

  test('the same month of another year is another group', () async {
    final state = await load([
      entry('a', 'acai', DateTime(2025, 9, 2)),
      entry('b', 'pizza', DateTime(2026, 9, 2)),
    ]);

    expect(state.months.map((month) => month.firstIndex), [0, 1]);
  });

  test('no decisions have no months', () async {
    final state = await load(const []);

    expect(state.months, isEmpty);
  });

  test('each item shows the day and the short month', () async {
    final state = await load([entry('a', 'pizza', DateTime(2026, 9, 21))]);

    expect(state.items.single.dateLabel, '21 set');
  });

  test('the sample history has decisions over more than one month', () async {
    final state = await load(FakeHistoryRepository.sample);

    expect(state.items, hasLength(FakeHistoryRepository.sample.length));
    expect(state.months.map((month) => month.label), [
      'Setembro',
      'Outubro',
      'Novembro',
    ]);
  });

  test('exposes the error when the repository fails', () async {
    final repository = _MockHistoryRepository();
    when(() => repository.fetchAll(any())).thenThrow(Exception('offline'));
    final container = ProviderContainer.test(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(LocalCategoryRepository()),
        currentUserProvider.overrideWithValue(
          const AsyncData(AppUser(uid: 'u1', isAnonymous: false)),
        ),
        historyRepositoryProvider.overrideWithValue(repository),
      ],
      retry: (_, _) => null,
    );

    await expectLater(
      container.read(historyViewModelProvider.future),
      throwsA(isA<Exception>()),
    );
  });

  group('who is signed in', () {
    late FakeAuthRepository auth;
    late ProviderContainer container;

    setUp(() {
      auth = FakeAuthRepository();
      container = ProviderContainer.test(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          categoryRepositoryProvider.overrideWithValue(
            LocalCategoryRepository(),
          ),
          historyRepositoryProvider.overrideWithValue(FakeHistoryRepository()),
        ],
      )..listen(historyViewModelProvider, (_, _) {});
    });

    test('a guest sees the empty state, not the sample (R1)', () async {
      final state = await container.read(historyViewModelProvider.future);

      expect(state.isEmpty, isTrue);
    });

    test('reloads on sign-up and on sign-out', () async {
      await container.read(historyViewModelProvider.future);

      await auth.signUp(name: 'Ana', email: 'ana@x.com', password: '12345678');
      await Future<void>.delayed(Duration.zero);
      final signedIn = await container.read(historyViewModelProvider.future);
      expect(signedIn.items, hasLength(FakeHistoryRepository.sample.length));

      await auth.signOut();
      await Future<void>.delayed(Duration.zero);
      final signedOut = await container.read(historyViewModelProvider.future);
      expect(signedOut.isEmpty, isTrue);
    });
  });
}
