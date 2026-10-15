import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/widgets/list_end.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('renders the message without an action', (tester) async {
    await tester.pumpWidget(_wrap(const ListEnd(message: 'Fim da lista')));

    expect(find.text('Fim da lista'), findsOneWidget);
    expect(find.byType(TextButton), findsNothing);
  });

  testWidgets('shows the action when given', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ListEnd(
          message: 'Fim da lista',
          action: TextButton(onPressed: () {}, child: const Text('Voltar')),
        ),
      ),
    );

    expect(find.text('Fim da lista'), findsOneWidget);
    expect(find.text('Voltar'), findsOneWidget);
  });
}
