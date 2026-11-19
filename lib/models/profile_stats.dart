import 'package:rango_app/models/food_category.dart';
import 'package:rango_app/models/history_entry.dart';

/// A summary of the account's locally cached history.
class ProfileStats {
  const ProfileStats({
    required this.decisionCount,
    this.favoriteFood,
    this.favoriteRestaurant,
  });

  factory ProfileStats.fromHistory({
    required List<HistoryEntry> entries,
    required List<FoodCategory> categories,
  }) {
    final categoryNames = {
      for (final category in categories) category.id: category.label,
    };
    final restaurantNames = <String, String>{};
    final restaurantLatestAt = <String, DateTime>{};
    for (final entry in entries) {
      final latestAt = restaurantLatestAt[entry.restaurantId];
      final previousName = restaurantNames[entry.restaurantId];
      final name = entry.restaurantName.trim();
      if (latestAt == null ||
          previousName == null ||
          entry.decidedAt.isAfter(latestAt) ||
          (entry.decidedAt == latestAt && name.compareTo(previousName) < 0)) {
        restaurantLatestAt[entry.restaurantId] = entry.decidedAt;
        restaurantNames[entry.restaurantId] = name.isEmpty
            ? 'Restaurante indisponível'
            : name;
      }
    }

    final favoriteFoodId = _favoriteId(
      entries,
      (entry) => entry.foodId,
      (id) => categoryNames[id] ?? 'Comida indisponível',
    );
    final favoriteRestaurantId = _favoriteId(
      entries,
      (entry) => entry.restaurantId,
      (id) => restaurantNames[id] ?? 'Restaurante indisponível',
    );

    return ProfileStats(
      decisionCount: entries.length,
      favoriteFood: favoriteFoodId == null
          ? null
          : categoryNames[favoriteFoodId] ?? 'Comida indisponível',
      favoriteRestaurant: favoriteRestaurantId == null
          ? null
          : restaurantNames[favoriteRestaurantId] ?? 'Restaurante indisponível',
    );
  }

  final int decisionCount;
  final String? favoriteFood;
  final String? favoriteRestaurant;
}

String? _favoriteId(
  List<HistoryEntry> entries,
  String Function(HistoryEntry) idOf,
  String Function(String) nameOf,
) {
  if (entries.isEmpty) return null;

  final counts = <String, int>{};
  final latestAt = <String, DateTime>{};
  for (final entry in entries) {
    final id = idOf(entry);
    counts.update(id, (count) => count + 1, ifAbsent: () => 1);
    final latest = latestAt[id];
    if (latest == null || entry.decidedAt.isAfter(latest)) {
      latestAt[id] = entry.decidedAt;
    }
  }

  return counts.keys.reduce((best, candidate) {
    final candidateCount = counts[candidate] ?? 0;
    final bestCount = counts[best] ?? 0;
    final countComparison = candidateCount.compareTo(bestCount);
    if (countComparison != 0) return countComparison > 0 ? candidate : best;

    final candidateDate = latestAt[candidate];
    final bestDate = latestAt[best];
    if (candidateDate != null && bestDate != null) {
      final recencyComparison = candidateDate.compareTo(bestDate);
      if (recencyComparison != 0) {
        return recencyComparison > 0 ? candidate : best;
      }
    }

    final nameComparison = nameOf(candidate).compareTo(nameOf(best));
    if (nameComparison != 0) return nameComparison < 0 ? candidate : best;
    return candidate.compareTo(best) < 0 ? candidate : best;
  });
}
