import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/theme/app_colors.dart';
import 'package:rango_app/core/theme/food_theme.dart';
import 'package:rango_app/core/widgets/avatar_button.dart';
import 'package:rango_app/core/widgets/glass_circle.dart';

Future<void> pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  const colors = AppColors.light;

  testWidgets('is at least 48x48', (tester) async {
    await pump(tester, AvatarButton(onPressed: () {}));
    final size = tester.getSize(find.byType(AvatarButton));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('exposes the semantic label', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, AvatarButton(onPressed: () {}));
    expect(find.bySemanticsLabel('Abrir perfil'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('tap calls onPressed', (tester) async {
    var taps = 0;
    await pump(tester, AvatarButton(onPressed: () => taps++));
    await tester.tap(find.byType(AvatarButton));
    expect(taps, 1);
  });

  testWidgets('guest variant is mustard glass with a light border', (
    tester,
  ) async {
    await pump(tester, AvatarButton(onPressed: () {}));
    final material = tester.widget<Material>(
      find.descendant(
        of: find.byType(AvatarButton),
        matching: find.byType(Material),
      ),
    );
    expect(material.color, colors.glassMustard);
    expect(material.color!.a, lessThan(1));
    final side = (material.shape! as CircleBorder).side;
    expect(side.color, colors.glassBorder);
    expect(side.width, 1);
    expect(
      find.descendant(
        of: find.byType(AvatarButton),
        matching: find.byType(GlassCircle),
      ),
      findsOneWidget,
    );
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, Icons.person_outline);
    expect(icon.color, FoodTheme.mustard.foreground);
  });
}
