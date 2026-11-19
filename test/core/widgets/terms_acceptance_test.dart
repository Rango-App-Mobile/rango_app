import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/widgets/terms_acceptance.dart';

Future<void> _pump(
  WidgetTester tester, {
  bool value = false,
  ValueChanged<bool>? onChanged,
  String? error,
}) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: TermsAcceptance(
        value: value,
        onChanged: onChanged ?? (_) {},
        error: error,
      ),
    ),
  ),
);

void main() {
  testWidgets('the switch reports the new value', (tester) async {
    bool? received;
    await _pump(tester, onChanged: (v) => received = v);

    await tester.tap(find.byType(Switch));
    expect(received, isTrue);
  });

  testWidgets('shows the error below the row, only when there is one', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.text('Aceite os termos para criar a conta.'), findsNothing);

    await _pump(tester, error: 'Aceite os termos para criar a conta.');
    expect(find.text('Aceite os termos para criar a conta.'), findsOneWidget);
  });

  testWidgets('tapping the label opens the terms text and it closes', (
    tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.textContaining('Li e aceito', findRichText: true));
    await tester.pumpAndSettle();

    expect(
      find.text('Termos de Uso e Política de Privacidade'),
      findsOneWidget,
    );
    expect(find.text('1. Quem somos'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('1. Quem somos'), findsNothing);
  });
}
