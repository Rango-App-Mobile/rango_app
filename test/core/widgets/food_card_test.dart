import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/theme/app_colors.dart';
import 'package:rango_app/core/theme/food_theme.dart';
import 'package:rango_app/core/widgets/food_card.dart';
import 'package:rango_app/core/widgets/rango_chip.dart';

const _longTitle =
    'Um título extremamente comprido que não cabe em duas linhas de jeito '
    'nenhum, nem a pau';

Future<void> pump(
  WidgetTester tester,
  Widget card, {
  double width = 330,
}) async {
  tester.view.physicalSize = const Size(600, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, child: card),
        ),
      ),
    ),
  );
}

BoxDecoration cardDecoration(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find
        .descendant(
          of: find.byType(FoodCard),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );
  return box.decoration as BoxDecoration;
}

Color? inkOf(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style?.color;

void main() {
  testWidgets('renders the title', (tester) async {
    await pump(
      tester,
      const FoodCard(title: 'Massas', foodTheme: FoodTheme.tomato),
    );
    expect(find.text('Massas'), findsOneWidget);
  });

  testWidgets('shows the subtitle only when given', (tester) async {
    await pump(
      tester,
      const FoodCard(title: 'Massas', foodTheme: FoodTheme.tomato),
    );
    expect(find.text('Coxinha, pastel'), findsNothing);

    await pump(
      tester,
      const FoodCard(
        title: 'Massas',
        foodTheme: FoodTheme.tomato,
        subtitle: 'Coxinha, pastel',
      ),
    );
    expect(find.text('Coxinha, pastel'), findsOneWidget);
  });

  testWidgets('shows the chip only when given', (tester) async {
    await pump(
      tester,
      const FoodCard(title: 'Massas', foodTheme: FoodTheme.tomato),
    );
    expect(find.byType(RangoChip), findsNothing);

    await pump(
      tester,
      const FoodCard(
        title: 'Massas',
        foodTheme: FoodTheme.tomato,
        chipLabel: '12 min',
      ),
    );
    expect(find.byType(RangoChip), findsOneWidget);
    expect(find.text('12 min'), findsOneWidget);
  });

  testWidgets('uses the food theme background and ink, and follows changes', (
    tester,
  ) async {
    await pump(
      tester,
      const FoodCard(title: 'Massas', foodTheme: FoodTheme.tomato),
    );
    expect(cardDecoration(tester).color, FoodTheme.tomato.background);
    expect(inkOf(tester, 'Massas'), FoodTheme.tomato.foreground);

    await pump(
      tester,
      const FoodCard(title: 'Massas', foodTheme: FoodTheme.plum),
    );
    expect(cardDecoration(tester).color, FoodTheme.plum.background);
    expect(inkOf(tester, 'Massas'), FoodTheme.plum.foreground);
  });

  testWidgets('chip ink follows the food theme on a dark mode', (
    tester,
  ) async {
    await pump(
      tester,
      const FoodCard(
        title: 'Massas',
        foodTheme: FoodTheme.plum,
        chipLabel: '12 min',
      ),
    );
    expect(inkOf(tester, '12 min'), FoodTheme.plum.foreground);
    expect(
      inkOf(tester, '12 min'),
      isNot(AppColors.light.textPrimary),
    );
  });

  for (final (size, width) in [
    (FoodCardSize.medium, 292.0),
    (FoodCardSize.hero, 330.0),
  ]) {
    testWidgets('long title stays within 2 lines in $size', (tester) async {
      await pump(
        tester,
        FoodCard(
          title: _longTitle,
          foodTheme: FoodTheme.mustard,
          size: size,
          subtitle: 'Coxinha, pastel, pizza',
          chipLabel: '12 min',
        ),
        width: width,
      );
      final title = tester.widget<Text>(find.text(_longTitle));
      expect(title.maxLines, 2);
      expect(title.overflow, TextOverflow.ellipsis);
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(FoodCard)).width, width);
    });
  }

  for (final (size, width, height) in [
    (FoodCardSize.hero, 330.0, null),
    (FoodCardSize.medium, 220.0, null),
    (FoodCardSize.compact, 330.0, 88.0),
    (FoodCardSize.expanded, 354.0, null),
  ]) {
    testWidgets('$size builds at its Figma width without errors', (
      tester,
    ) async {
      await pump(
        tester,
        FoodCard(
          title: 'Massas',
          foodTheme: FoodTheme.lilac,
          size: size,
          subtitle: 'Cantina Bella',
          chipLabel: '12 min',
          cuisine: 'Italiana',
          path: const ['Salgado', 'Massas'],
        ),
        width: width,
      );
      expect(tester.takeException(), isNull);
      final box = tester.getSize(find.byType(FoodCard));
      expect(box.width, width);
      if (height != null) expect(box.height, height);
    });
  }

  testWidgets('compact lays the thumb, title and chip out in a row', (
    tester,
  ) async {
    await pump(
      tester,
      const FoodCard(
        title: 'Massas',
        foodTheme: FoodTheme.sky,
        size: FoodCardSize.compact,
        subtitle: 'Cantina Bella',
        chipLabel: '12 min',
      ),
    );
    final thumb = tester.getRect(find.byIcon(Icons.image_outlined));
    final title = tester.getRect(find.text('Massas'));
    final chip = tester.getRect(find.byType(RangoChip));
    expect(title.left, greaterThan(thumb.right));
    expect(chip.left, greaterThan(title.right));
    expect(chip.center.dy, closeTo(thumb.center.dy, 1));
    expect(find.text('Foto do prato'), findsNothing);
  });

  testWidgets('expanded shows the path chips, the restaurant and cuisine', (
    tester,
  ) async {
    await pump(
      tester,
      const FoodCard(
        title: 'Espaguete',
        foodTheme: FoodTheme.copper,
        size: FoodCardSize.expanded,
        subtitle: 'Cantina Bella',
        cuisine: 'Italiana',
        path: ['Salgado', 'Massas', 'Espaguete'],
      ),
      width: 354,
    );
    expect(find.text('O caminho até aqui'), findsOneWidget);
    expect(find.byType(RangoChip), findsNWidgets(3));
    expect(find.text('→'), findsNWidgets(2));
    expect(find.text('Onde você pediu'), findsOneWidget);
    expect(find.text('Cantina Bella'), findsOneWidget);
    expect(find.text('Italiana'), findsOneWidget);
  });

  testWidgets('expanded omits path and restaurant blocks when empty', (
    tester,
  ) async {
    await pump(
      tester,
      const FoodCard(
        title: 'Espaguete',
        foodTheme: FoodTheme.copper,
        size: FoodCardSize.expanded,
      ),
      width: 354,
    );
    expect(find.text('O caminho até aqui'), findsNothing);
    expect(find.text('Onde você pediu'), findsNothing);
  });

  testWidgets('shows the placeholder label when there is no photo', (
    tester,
  ) async {
    await pump(
      tester,
      const FoodCard(title: 'Massas', foodTheme: FoodTheme.tomato),
    );
    expect(find.text('Foto do prato'), findsOneWidget);
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('uses a custom placeholder label', (tester) async {
    await pump(
      tester,
      const FoodCard(
        title: 'Massas',
        foodTheme: FoodTheme.tomato,
        photoLabel: 'Foto da massa',
      ),
    );
    expect(find.text('Foto da massa'), findsOneWidget);
  });

  testWidgets('shows the image instead of the placeholder when given', (
    tester,
  ) async {
    await pump(
      tester,
      FoodCard(
        title: 'Massas',
        foodTheme: FoodTheme.tomato,
        photo: MemoryImage(_transparentPixel),
      ),
    );
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Foto do prato'), findsNothing);
  });

  testWidgets('reads title and subtitle as a single label', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(
      tester,
      const FoodCard(
        title: 'Massas',
        foodTheme: FoodTheme.tomato,
        subtitle: 'Cantina Bella',
      ),
    );
    expect(find.bySemanticsLabel('Massas, Cantina Bella'), findsOneWidget);
    handle.dispose();
  });
}

// 1x1 transparent PNG.
final _transparentPixel = Uint8List.fromList(const [
  0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1f, 0x15, 0xc4, 0x89, 0x00, 0x00, 0x00,
  0x0d, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9c, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0d, 0x0a, 0x2d, 0xb4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82,
]);
