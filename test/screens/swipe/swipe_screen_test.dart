import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/fake_category_repository.dart';
import 'package:rango_app/screens/swipe/swipe_screen.dart';

void main() {
  testWidgets('walks the choices until a food type', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoryRepositoryProvider.overrideWithValue(
            FakeCategoryRepository(),
          ),
        ],
        child: const MaterialApp(home: SwipeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salgado'));
    await tester.pump();
    await tester.tap(find.text('Massa'));
    await tester.pump();
    await tester.tap(find.text('Pizza'));
    await tester.pump();

    expect(find.text('Bora de Pizza!'), findsOneWidget);
  });
}
