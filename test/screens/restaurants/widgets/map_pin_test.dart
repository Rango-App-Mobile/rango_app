import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/screens/restaurants/widgets/map_pin.dart';

Future<void> _pump(WidgetTester tester, Widget pin) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: pin)),
  ),
);

void main() {
  testWidgets('default pin is 44x57 with no balloon', (tester) async {
    await _pump(
      tester,
      const MapPin(name: 'Cantina', foodTheme: 'tomato', rating: 4.7),
    );

    expect(
      tester.getSize(find.byType(MapPin)),
      MapPin.defaultSize,
    );
    expect(find.byIcon(Icons.restaurant), findsOneWidget);
    expect(find.textContaining('★'), findsNothing);
  });

  testWidgets('selected pin is 56x73 with name and rating balloon', (
    tester,
  ) async {
    await _pump(
      tester,
      const MapPin(
        name: 'Cantina',
        foodTheme: 'tomato',
        rating: 4.7,
        selected: true,
      ),
    );

    expect(tester.getSize(find.byType(MapPin)), MapPin.selectedSize);
    expect(find.text('Cantina ★ 4,7'), findsOneWidget);
  });

  testWidgets('balloon hides the rating when there is none', (tester) async {
    await _pump(
      tester,
      const MapPin(name: 'Cantina', foodTheme: null, selected: true),
    );

    expect(find.text('Cantina'), findsOneWidget);
  });

  testWidgets('is a button with name, rating and distance', (tester) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await _pump(
      tester,
      MapPin(
        name: 'Cantina',
        foodTheme: 'tomato',
        rating: 4.7,
        distanceMeters: 1200,
        onTap: () => taps++,
      ),
    );

    final node = find.bySemanticsLabel('Cantina, nota 4,7, a 1,2 km');
    expect(node, findsOneWidget);
    await tester.tap(node);
    expect(taps, 1);
    handle.dispose();
  });
}
