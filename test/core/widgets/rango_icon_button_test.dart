import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/theme/app_colors.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/theme/app_shadows.dart';
import 'package:rango_app/core/widgets/rango_icon_button.dart';

Future<void> pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

Material buttonMaterial(WidgetTester tester) => tester.widget<Material>(
  find.descendant(
    of: find.byType(RangoIconButton),
    matching: find.byType(Material),
  ),
);

RangoIconButton make(RangoIconButtonStyle style, {VoidCallback? onPressed}) =>
    RangoIconButton(
      icon: Icons.close,
      semanticLabel: 'Fechar',
      style: style,
      onPressed: onPressed ?? () {},
    );

void main() {
  const colors = AppColors.light;

  testWidgets('is at least 48x48', (tester) async {
    await pump(tester, make(RangoIconButtonStyle.surface));
    final size = tester.getSize(find.byType(RangoIconButton));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('exposes the semantic label', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, make(RangoIconButtonStyle.surface));
    expect(find.bySemanticsLabel('Fechar'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('tap calls onPressed', (tester) async {
    var taps = 0;
    await pump(
      tester,
      make(RangoIconButtonStyle.surface, onPressed: () => taps++),
    );
    await tester.tap(find.byType(RangoIconButton));
    expect(taps, 1);
  });

  testWidgets('surface has surface fill, card shadow and default icon', (
    tester,
  ) async {
    await pump(tester, make(RangoIconButtonStyle.surface));
    expect(buttonMaterial(tester).color, colors.bgSurface);
    expect(tester.widget<Icon>(find.byType(Icon)).color, colors.iconDefault);
    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(RangoIconButton),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect((box.decoration as BoxDecoration).boxShadow, AppShadows.card);
  });

  testWidgets('inverse has inverse fill and inverse icon', (tester) async {
    await pump(tester, make(RangoIconButtonStyle.inverse));
    expect(buttonMaterial(tester).color, colors.bgInverse);
    expect(tester.widget<Icon>(find.byType(Icon)).color, colors.iconInverse);
  });

  testWidgets('outline has strong border and no fill', (tester) async {
    await pump(tester, make(RangoIconButtonStyle.outline));
    final material = buttonMaterial(tester);
    expect(material.color, Colors.transparent);
    final side = (material.shape! as CircleBorder).side;
    expect(side.color, colors.borderStrong);
    expect(side.width, AppRadius.stroke);
    expect(tester.widget<Icon>(find.byType(Icon)).color, colors.iconDefault);
  });
}
