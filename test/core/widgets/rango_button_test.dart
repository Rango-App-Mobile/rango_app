import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/theme/app_colors.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/widgets/rango_button.dart';

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
    of: find.byType(RangoButton),
    matching: find.byType(Material),
  ),
);

Color? labelColor(WidgetTester tester) =>
    tester.widget<Text>(find.text('A')).style?.color;

void main() {
  const colors = AppColors.light;

  testWidgets('renders the label', (tester) async {
    await pump(tester, RangoButton(label: 'Começar', onPressed: () {}));
    expect(find.text('Começar'), findsOneWidget);
  });

  testWidgets('primary paints the action fill without border', (tester) async {
    await pump(tester, RangoButton(label: 'A', onPressed: () {}));
    final material = buttonMaterial(tester);
    expect(material.color, colors.actionPrimary);
    expect((material.shape! as StadiumBorder).side, BorderSide.none);
    expect(labelColor(tester), colors.actionOnPrimary);
  });

  testWidgets('secondary paints surface fill and strong border', (
    tester,
  ) async {
    await pump(
      tester,
      RangoButton(
        label: 'A',
        style: RangoButtonStyle.secondary,
        onPressed: () {},
      ),
    );
    final material = buttonMaterial(tester);
    expect(material.color, colors.bgSurface);
    final side = (material.shape! as StadiumBorder).side;
    expect(side.color, colors.borderStrong);
    expect(side.width, AppRadius.stroke);
    expect(labelColor(tester), colors.textPrimary);
  });

  testWidgets('ghost has no fill and no border', (tester) async {
    await pump(
      tester,
      RangoButton(
        label: 'A',
        style: RangoButtonStyle.ghost,
        onPressed: () {},
      ),
    );
    final material = buttonMaterial(tester);
    expect(material.color, Colors.transparent);
    expect((material.shape! as StadiumBorder).side, BorderSide.none);
  });

  testWidgets('large is 56 high and medium is 44 high', (tester) async {
    await pump(tester, RangoButton(label: 'A', onPressed: () {}));
    expect(tester.getSize(find.byType(RangoButton)).height, 56);

    await pump(
      tester,
      RangoButton(label: 'A', size: RangoButtonSize.medium, onPressed: () {}),
    );
    expect(tester.getSize(find.byType(RangoButton)).height, 44);
  });

  testWidgets('shows the icon only when given', (tester) async {
    await pump(tester, RangoButton(label: 'A', onPressed: () {}));
    expect(find.byType(Icon), findsNothing);

    await pump(
      tester,
      RangoButton(label: 'A', icon: Icons.add, onPressed: () {}),
    );
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('expand fills the available width', (tester) async {
    await pump(
      tester,
      SizedBox(
        width: 300,
        child: RangoButton(label: 'A', expand: true, onPressed: () {}),
      ),
    );
    expect(tester.getSize(find.byType(RangoButton)).width, 300);
  });

  testWidgets('tap calls onPressed', (tester) async {
    var taps = 0;
    await pump(tester, RangoButton(label: 'A', onPressed: () => taps++));
    await tester.tap(find.byType(RangoButton));
    expect(taps, 1);
  });

  testWidgets('null onPressed is reported as disabled in semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(tester, const RangoButton(label: 'A', onPressed: null));
    final data = tester.getSemantics(find.byType(RangoButton));
    expect(data.label, 'A');
    expect(
      data,
      matchesSemantics(
        label: 'A',
        isButton: true,
        hasEnabledState: true,
      ),
    );
    handle.dispose();
  });
}
