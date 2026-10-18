import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/data/fake_category_repository.dart';
import 'package:rango_app/models/food_category.dart';

// Mirrors the FoodTheme modes in the Figma file. Kept as plain strings so the
// model tests stay free of Flutter imports.
const _validThemes = {
  'tomato',
  'mustard',
  'lilac',
  'lime',
  'pistachio',
  'sky',
  'plum',
  'copper',
  'cocoa',
  'bubblegum',
};

void main() {
  group('FoodCategory', () {
    test('round-trips examples and foodTheme through JSON', () {
      const category = FoodCategory(
        id: 'savory',
        label: 'Salgado',
        parentId: 'root',
        examples: 'Coxinha, pastel, pizza',
        foodTheme: 'tomato',
      );

      final decoded = FoodCategory.fromJson(category.toJson());

      expect(decoded, category);
      expect(decoded.examples, 'Coxinha, pastel, pizza');
      expect(decoded.foodTheme, 'tomato');
    });

    test('keeps examples and foodTheme optional', () {
      final decoded = FoodCategory.fromJson(const {
        'id': 'root',
        'label': 'O que bate hoje?',
      });

      expect(decoded.examples, isNull);
      expect(decoded.foodTheme, isNull);
    });
  });

  group('FakeCategoryRepository.seed', () {
    final nonRoot = FakeCategoryRepository.seed.where(
      (c) => c.parentId != null,
    );

    test('gives every non-root node examples and a valid foodTheme', () {
      for (final category in nonRoot) {
        expect(category.examples, isNotEmpty, reason: category.id);
        expect(_validThemes, contains(category.foodTheme), reason: category.id);
      }
    });

    test('uses different themes for the two options of a pair', () {
      final byParent = <String?, Set<String?>>{};
      for (final category in nonRoot) {
        byParent
            .putIfAbsent(category.parentId, () => {})
            .add(category.foodTheme);
      }
      for (final entry in byParent.entries) {
        expect(entry.value, hasLength(2), reason: entry.key);
      }
    });
  });
}
