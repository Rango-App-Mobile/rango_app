import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/theme/food_theme.dart';
import 'package:rango_app/core/widgets/rango_chip.dart';
import 'package:rango_app/core/widgets/restaurant_card.dart';

Future<void> pump(WidgetTester tester, Widget card) async {
  tester.view.physicalSize = const Size(375, 667);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: card),
      ),
    ),
  );
}

RestaurantCard full({
  RestaurantCardLayout layout = RestaurantCardLayout.vertical,
  VoidCallback? onTap,
}) => RestaurantCard(
  name: 'Cantina do Zé',
  foodTheme: FoodTheme.tomato,
  layout: layout,
  cuisine: 'Italiana · Rua A, 10',
  rating: 4.7,
  distanceMeters: 1234,
  deliveryTime: '25–35 min',
  onTap: onTap,
);

void main() {
  for (final layout in RestaurantCardLayout.values) {
    testWidgets('renders name, cuisine and three chips in $layout', (
      tester,
    ) async {
      await pump(tester, full(layout: layout));
      expect(find.text('Cantina do Zé'), findsOneWidget);
      expect(find.text('Italiana · Rua A, 10'), findsOneWidget);
      expect(find.text('4,7'), findsOneWidget);
      expect(find.text('1,2 km'), findsOneWidget);
      expect(find.text('25–35 min'), findsOneWidget);
      expect(find.byType(RangoChip), findsNWidgets(3));
    });

    testWidgets('does not overflow with long text at 375x667 in $layout', (
      tester,
    ) async {
      await pump(
        tester,
        RestaurantCard(
          name:
              'Um restaurante com um nome extremamente comprido que passa '
              'de duas linhas sem nenhum problema',
          foodTheme: FoodTheme.plum,
          layout: layout,
          cuisine: 'Uma descrição de cozinha e endereço muito longa também',
          rating: 4.7,
          distanceMeters: 12500,
          deliveryTime: '125–135 min',
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('hides chips for missing data', (tester) async {
    await pump(
      tester,
      const RestaurantCard(
        name: 'Sem dados',
        foodTheme: FoodTheme.tomato,
        distanceMeters: 850,
      ),
    );
    expect(find.byType(RangoChip), findsOneWidget);
    expect(find.text('850 m'), findsOneWidget);
  });

  testWidgets('fires onTap', (tester) async {
    var taps = 0;
    await pump(tester, full(onTap: () => taps++));
    await tester.tap(find.text('Cantina do Zé'));
    expect(taps, 1);
  });

  testWidgets('exposes one merged semantics label', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, full(onTap: () {}));
    expect(
      find.bySemanticsLabel(
        'Cantina do Zé, Italiana · Rua A, 10, nota 4,7, a 1,2 km, '
        '25 a 35 minutos',
      ),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('omits missing parts from the semantics label', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(
      tester,
      const RestaurantCard(name: 'Só nome', foodTheme: FoodTheme.tomato),
    );
    expect(find.bySemanticsLabel('Só nome'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('draws the placeholder icon without a photo', (tester) async {
    await pump(tester, full());
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
  });

  testWidgets('falls back to the placeholder when the photo fails', (
    tester,
  ) async {
    await pump(
      tester,
      RestaurantCard(
        name: 'Foto quebrada',
        foodTheme: FoodTheme.tomato,
        photo: MemoryImage(Uint8List.fromList([1, 2, 3])),
      ),
    );
    await tester.pump();
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
  });

  testWidgets('loading skeleton renders without chips', (tester) async {
    await pump(tester, const RestaurantCard.loading());
    expect(find.byType(RangoChip), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
