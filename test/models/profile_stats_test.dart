import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/models/food_category.dart';
import 'package:rango_app/models/history_entry.dart';
import 'package:rango_app/models/order_channel.dart';
import 'package:rango_app/models/profile_stats.dart';

void main() {
  const categories = [
    FoodCategory(id: 'pizza', label: 'Pizza'),
    FoodCategory(id: 'xis', label: 'Xis'),
  ];

  test('counts decisions and finds the most common food and restaurant', () {
    final stats = ProfileStats.fromHistory(
      entries: [
        _entry(
          id: '1',
          foodId: 'pizza',
          restaurantId: 'p1',
          restaurantName: 'Casa da Pizza',
          decidedAt: DateTime(2026, 11, 12),
        ),
        _entry(
          id: '2',
          foodId: 'pizza',
          restaurantId: 'p1',
          restaurantName: 'Casa da Pizza',
          decidedAt: DateTime(2026, 11, 13),
        ),
        _entry(
          id: '3',
          foodId: 'xis',
          restaurantId: 'p2',
          restaurantName: 'Xis do Bairro',
          decidedAt: DateTime(2026, 11, 14),
        ),
      ],
      categories: categories,
    );

    expect(stats.decisionCount, 3);
    expect(stats.favoriteFood, 'Pizza');
    expect(stats.favoriteRestaurant, 'Casa da Pizza');
  });

  test('breaks frequency ties by the most recent decision', () {
    final stats = ProfileStats.fromHistory(
      entries: [
        _entry(
          id: '1',
          foodId: 'pizza',
          restaurantId: 'p1',
          restaurantName: 'A Pizza',
          decidedAt: DateTime(2026, 11, 10),
        ),
        _entry(
          id: '2',
          foodId: 'xis',
          restaurantId: 'p2',
          restaurantName: 'Xis do Centro',
          decidedAt: DateTime(2026, 11, 11),
        ),
        _entry(
          id: '3',
          foodId: 'pizza',
          restaurantId: 'p1',
          restaurantName: 'A Pizza',
          decidedAt: DateTime(2026, 11, 12),
        ),
        _entry(
          id: '4',
          foodId: 'xis',
          restaurantId: 'p2',
          restaurantName: 'Xis do Centro',
          decidedAt: DateTime(2026, 11, 13),
        ),
      ],
      categories: categories,
    );

    expect(stats.favoriteFood, 'Xis');
    expect(stats.favoriteRestaurant, 'Xis do Centro');
  });

  test(
    'uses the same valid restaurant name when tied entries are reordered',
    () {
      final decidedAt = DateTime(2026, 11, 12);
      final blankName = _entry(
        id: '1',
        foodId: 'pizza',
        restaurantId: 'p1',
        restaurantName: '  ',
        decidedAt: decidedAt,
      );
      final validName = _entry(
        id: '2',
        foodId: 'pizza',
        restaurantId: 'p1',
        restaurantName: 'A Pizza',
        decidedAt: decidedAt,
      );

      final blankFirst = ProfileStats.fromHistory(
        entries: [blankName, validName],
        categories: categories,
      );
      final validFirst = ProfileStats.fromHistory(
        entries: [validName, blankName],
        categories: categories,
      );

      expect(blankFirst.favoriteRestaurant, 'A Pizza');
      expect(validFirst.favoriteRestaurant, 'A Pizza');
    },
  );

  test('keeps empty history neutral', () {
    final stats = ProfileStats.fromHistory(
      entries: const [],
      categories: categories,
    );

    expect(stats.decisionCount, 0);
    expect(stats.favoriteFood, isNull);
    expect(stats.favoriteRestaurant, isNull);
  });

  test('uses safe labels when historical ids are no longer available', () {
    final stats = ProfileStats.fromHistory(
      entries: [
        _entry(
          id: '1',
          foodId: 'removed-food',
          restaurantId: 'removed-restaurant',
          restaurantName: '  ',
          decidedAt: DateTime(2026, 11, 12),
        ),
      ],
      categories: categories,
    );

    expect(stats.favoriteFood, 'Comida indisponível');
    expect(stats.favoriteRestaurant, 'Restaurante indisponível');
  });
}

HistoryEntry _entry({
  required String id,
  required String foodId,
  required String restaurantId,
  required String restaurantName,
  required DateTime decidedAt,
}) => HistoryEntry(
  id: id,
  foodId: foodId,
  restaurantId: restaurantId,
  restaurantName: restaurantName,
  channel: OrderChannel.delivery,
  decidedAt: decidedAt,
);
