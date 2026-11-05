import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/widgets/top_bar.dart';
import 'package:rango_app/core/widgets/top_bar_layout.dart';

const _statusBar = 54.0;

Future<void> pump(WidgetTester tester, {required Widget body, Widget? bar}) {
  tester.view
    ..physicalSize = const Size(402, 874)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: MediaQuery(
        data: const MediaQueryData(
          size: Size(402, 874),
          padding: EdgeInsets.only(top: _statusBar),
        ),
        child: Scaffold(
          body: TopBarLayout(
            topBar: bar ?? TopBar.flow(onBack: () {}),
            body: body,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('tells the body how far the bar reaches', (tester) async {
    late double inset;
    await pump(
      tester,
      body: Builder(
        builder: (context) {
          inset = MediaQuery.paddingOf(context).top;
          return const SizedBox.expand();
        },
      ),
    );

    expect(inset, _statusBar + TopBar.height);
  });

  testWidgets('the body starts at the top of the screen, behind the bar', (
    tester,
  ) async {
    await pump(tester, body: const SizedBox.expand(key: Key('body')));

    expect(tester.getTopLeft(find.byKey(const Key('body'))).dy, 0);
  });

  testWidgets('the bar sits right below the status bar', (tester) async {
    await pump(tester, body: const SizedBox.expand());

    expect(tester.getTopLeft(find.byType(TopBar)).dy, _statusBar);
  });

  testWidgets('blur stops inside the bar, so content at rest stays sharp', (
    tester,
  ) async {
    await pump(tester, body: const SizedBox.expand());

    final widest =
        find
                .byKey(const Key('progressive-blur-band'))
                .evaluate()
                .first
                .renderObject!
            as RenderBox;
    final bottom = widest.localToGlobal(Offset.zero).dy + widest.size.height;

    expect(bottom, greaterThan(_statusBar));
    expect(bottom, lessThan(_statusBar + TopBar.height));
  });

  testWidgets('taps pass through the blur to the content', (tester) async {
    var taps = 0;
    await pump(
      tester,
      body: Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: () => taps++,
          child: const SizedBox.square(
            dimension: 40,
            child: ColoredBox(color: Color(0xFF000000)),
          ),
        ),
      ),
    );

    await tester.tapAt(const Offset(390, 10));

    expect(taps, 1);
  });

  testWidgets('the bar stays tappable above the content', (tester) async {
    var taps = 0;
    await pump(
      tester,
      body: const SizedBox.expand(),
      bar: TopBar.flow(onBack: () => taps++),
    );

    await tester.tap(find.byIcon(Icons.arrow_back));

    expect(taps, 1);
  });
}
