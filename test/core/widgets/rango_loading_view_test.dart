import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/core/widgets/rango_loading_data.dart';
import 'package:rango_app/core/widgets/rango_loading_motion.dart';
import 'package:rango_app/core/widgets/rango_loading_view.dart';

Widget _app({
  String? message,
  Size size = const Size(402, 874),
  bool disableAnimations = false,
}) {
  return MediaQuery(
    data: MediaQueryData(
      size: size,
      disableAnimations: disableAnimations,
    ),
    child: MaterialApp(
      home: RangoLoadingView(message: message),
    ),
  );
}

void main() {
  group('Track', () {
    test('holds the first value, eases between keys and holds the last', () {
      const track = Track([
        (0.2, 10, Curves.linear),
        (0.6, 30, Curves.linear),
      ]);
      expect(track.at(0), 10);
      expect(track.at(0.4), closeTo(20, 1e-9));
      expect(track.at(1), 30);
    });

    test('a sampled curve interpolates its samples and may overshoot', () {
      const curve = SampledCurve([0, 1.2, 1]);
      expect(curve.transform(0.25), closeTo(0.6, 1e-9));
      expect(curve.transform(0.5), closeTo(1.2, 1e-9));
    });

    test('step-end keeps the start value until the segment ends', () {
      const track = Track([(0, 1, Threshold(1)), (0.5, 0, Curves.linear)]);
      expect(track.at(0.49), 1);
      expect(track.at(0.5), 0);
    });
  });

  testWidgets('plays through the whole timeline without exceptions', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }
    expect(tester.takeException(), isNull);
    expect(find.byType(RangoLoadingView), findsOneWidget);
  });

  testWidgets('shows the message under the xis when given', (tester) async {
    await tester.pumpWidget(_app(message: 'Entrando...'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Entrando...'), findsOneWidget);
  });

  testWidgets('has no text without a message', (tester) async {
    await tester.pumpWidget(_app());

    expect(find.byType(Text), findsNothing);
  });

  testWidgets('reduced motion shows the assembled xis and never ticks', (
    tester,
  ) async {
    await tester.pumpWidget(_app(disableAnimations: true));

    // Nothing scheduled: an infinite animation would fail this.
    expect(tester.hasRunningAnimations, isFalse);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits a 320x568 screen without overflow', (tester) async {
    tester.view
      ..physicalSize = const Size(320, 568)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(size: const Size(320, 568), message: 'Oi'));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 800));
    }

    expect(tester.takeException(), isNull);
  });

  test('the timeline lasts 4.7 s', () {
    expect(loadingDuration, const Duration(milliseconds: 4700));
  });
}
