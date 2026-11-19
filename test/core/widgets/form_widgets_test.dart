import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/theme/app_colors.dart';
import 'package:rango_app/core/widgets/inline_alert.dart';
import 'package:rango_app/core/widgets/list_row.dart';
import 'package:rango_app/core/widgets/rango_divider.dart';
import 'package:rango_app/core/widgets/rango_text_field.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(24), child: child),
  ),
);

Color _borderColor(WidgetTester tester) {
  final field = tester.widget<TextField>(find.byType(TextField));
  final border = field.decoration!.enabledBorder! as OutlineInputBorder;
  return border.borderSide.color;
}

void main() {
  group('RangoTextField', () {
    testWidgets('shows label, hint and helper, and reports typing', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      var changes = 0;
      await tester.pumpWidget(
        _wrap(
          RangoTextField(
            label: 'E-mail',
            hint: 'voce@email.com',
            helper: 'Mensagem de apoio.',
            controller: controller,
            onChanged: (_) => changes++,
          ),
        ),
      );

      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('voce@email.com'), findsOneWidget);
      expect(find.text('Mensagem de apoio.'), findsOneWidget);
      expect(_borderColor(tester), AppColors.light.borderDefault);

      await tester.enterText(find.byType(TextField), 'joana@email.com');
      expect(controller.text, 'joana@email.com');
      expect(changes, 1);
    });

    testWidgets('is 56 high', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _wrap(RangoTextField(label: 'E-mail', controller: controller)),
      );

      expect(tester.getSize(find.byType(TextField)).height, 56);
    });

    testWidgets('an error replaces the helper and paints the border', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _wrap(
          RangoTextField(
            label: 'E-mail',
            helper: 'Mensagem de apoio.',
            error: 'Confira este campo.',
            controller: controller,
          ),
        ),
      );

      expect(find.text('Confira este campo.'), findsOneWidget);
      expect(find.text('Mensagem de apoio.'), findsNothing);
      expect(_borderColor(tester), AppColors.light.textDanger);
    });

    testWidgets('a password is hidden until the eye is tapped', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _wrap(
          RangoTextField(
            label: 'Senha',
            controller: controller,
            isPassword: true,
          ),
        ),
      );
      bool obscured() =>
          tester.widget<TextField>(find.byType(TextField)).obscureText;

      expect(obscured(), isTrue);

      await tester.tap(find.byTooltip('Mostrar senha'));
      await tester.pump();
      expect(obscured(), isFalse);

      await tester.tap(find.byTooltip('Esconder senha'));
      await tester.pump();
      expect(obscured(), isTrue);
    });
  });

  testWidgets('RangoDivider shows its label between two lines', (tester) async {
    await tester.pumpWidget(_wrap(const RangoDivider()));

    expect(find.text('ou'), findsOneWidget);
  });

  testWidgets('InlineAlert shows the message with a danger border', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const InlineAlert(message: 'Sem conexão.')));

    expect(find.text('Sem conexão.'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    final box = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(InlineAlert),
        matching: find.byType(DecoratedBox),
      ),
    );
    final border = (box.decoration as BoxDecoration).border! as Border;
    expect(border.top.color, AppColors.light.textDanger);
  });

  testWidgets('ListRow shows icon and label, is 60 high and taps', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        ListRow(
          icon: Icons.logout,
          label: 'Sair da conta',
          onTap: () => taps++,
        ),
      ),
    );

    expect(find.byIcon(Icons.logout), findsOneWidget);
    expect(tester.getSize(find.byType(ListRow)).height, 60);

    await tester.tap(find.text('Sair da conta'));
    expect(taps, 1);
  });
}
