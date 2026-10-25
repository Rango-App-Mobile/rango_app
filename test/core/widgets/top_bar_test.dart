import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/widgets/avatar_button.dart';
import 'package:rango_app/core/widgets/top_bar.dart';

Future<void> pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Align(alignment: Alignment.topCenter, child: child),
      ),
    ),
  );
}

void main() {
  group('TopBar.principal', () {
    testWidgets('shows the logo and the avatar, no back button', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(tester, TopBar.principal(onProfile: () {}));
      expect(find.text('Rango'), findsOneWidget);
      expect(find.byType(AvatarButton), findsOneWidget);
      expect(find.bySemanticsLabel('Voltar'), findsNothing);
      handle.dispose();
    });

    testWidgets('tapping the avatar calls onProfile', (tester) async {
      var taps = 0;
      await pump(tester, TopBar.principal(onProfile: () => taps++));
      await tester.tap(find.byType(AvatarButton));
      expect(taps, 1);
    });

    testWidgets('logo is decorative and not in the semantics tree', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(tester, TopBar.principal(onProfile: () {}));
      expect(find.bySemanticsLabel('Rango'), findsNothing);
      handle.dispose();
    });

    testWidgets('is 64 high', (tester) async {
      await pump(tester, TopBar.principal(onProfile: () {}));
      expect(tester.getSize(find.byType(TopBar)).height, 64);
    });
  });

  group('TopBar.flow', () {
    testWidgets('shows only the back button', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, TopBar.flow(onBack: () {}));
      expect(find.bySemanticsLabel('Voltar'), findsOneWidget);
      expect(find.text('Rango'), findsNothing);
      expect(find.byType(AvatarButton), findsNothing);
      handle.dispose();
    });

    testWidgets('tapping back calls onBack', (tester) async {
      var taps = 0;
      await pump(tester, TopBar.flow(onBack: () => taps++));
      await tester.tap(find.byIcon(Icons.arrow_back));
      expect(taps, 1);
    });

    testWidgets('is 64 high', (tester) async {
      await pump(tester, TopBar.flow(onBack: () {}));
      expect(tester.getSize(find.byType(TopBar)).height, 64);
    });
  });
}
