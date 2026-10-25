import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/data/local_category_repository.dart';
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
      expect(decoded.photo, isNull);
    });

    test('round-trips photo through JSON', () {
      const category = FoodCategory(
        id: 'pizza',
        label: 'Pizza',
        photo: 'pizza',
      );

      expect(FoodCategory.fromJson(category.toJson()).photo, 'pizza');
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

    test('names only photos that exist in assets/images/food', () {
      for (final category in FakeCategoryRepository.seed) {
        final photo = category.photo;
        if (photo == null) continue;
        expect(
          File('assets/images/food/$photo.jpg').existsSync(),
          isTrue,
          reason: '${category.id} -> $photo',
        );
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
