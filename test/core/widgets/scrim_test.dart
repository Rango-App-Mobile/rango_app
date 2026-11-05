import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/theme/app_colors.dart';
import 'package:rango_app/core/widgets/scrim.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('modal calls onDismiss on tap', (tester) async {
    var dismissed = 0;
    await tester.pumpWidget(_wrap(Scrim.modal(onDismiss: () => dismissed++)));

    await tester.tap(find.byType(Scrim));
    expect(dismissed, 1);
  });

  testWidgets('modal is bgInverse at 0.45 opacity and fills the screen', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(Scrim.modal(onDismiss: () {})));

    final box = tester.widget<ColoredBox>(
      find.descendant(
        of: find.byType(Scrim),
        matching: find.byType(ColoredBox),
      ),
    );
    expect(
      box.color,
      AppColors.light.bgInverse.withValues(alpha: Scrim.modalOpacity),
    );
    expect(Scrim.modalOpacity, 0.45);
    expect(
      tester.getSize(find.byType(Scrim)),
      tester.getSize(find.byType(Scaffold)),
    );
  });

  testWidgets('modal exposes a Fechar button to screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_wrap(Scrim.modal(onDismiss: () {})));

    expect(find.bySemanticsLabel('Fechar'), findsOneWidget);
    handle.dispose();
  });
}
