import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/widgets/top_bar.dart';
import 'package:rango_app/core/widgets/top_bar_layout.dart';
import 'package:rango_app/core/widgets/top_bar_scroll_view.dart';

const _statusBar = 54.0;
const _homeIndicator = 34.0;

Future<void> pump(
  WidgetTester tester, {
  EdgeInsets padding = EdgeInsets.zero,
  bool safeBottom = true,
}) {
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
          padding: EdgeInsets.only(top: _statusBar, bottom: _homeIndicator),
        ),
        child: Scaffold(
          body: TopBarLayout(
            topBar: TopBar.flow(onBack: () {}),
            body: TopBarScrollView(
              padding: padding,
              safeBottom: safeBottom,
              child: const SizedBox(key: Key('content'), height: 2000),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('the viewport reaches the top of the screen', (tester) async {
    await pump(tester);

    expect(tester.getTopLeft(find.byType(SingleChildScrollView)).dy, 0);
  });

  testWidgets('content starts right below the bar', (tester) async {
    await pump(tester);

    expect(
      tester.getTopLeft(find.byKey(const Key('content'))).dy,
      _statusBar + TopBar.height,
    );
  });

  testWidgets('own top padding adds to the bar inset', (tester) async {
    await pump(tester, padding: const EdgeInsets.all(24));

    final content = tester.getTopLeft(find.byKey(const Key('content')));
    expect(content.dy, _statusBar + TopBar.height + 24);
    expect(content.dx, 24);
  });

  testWidgets('scrolled content passes behind the bar', (tester) async {
    await pump(tester);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.byKey(const Key('content'))).dy,
      lessThan(0),
    );
  });

  testWidgets('the viewport reaches the bottom of the screen', (tester) async {
    await pump(tester);

    expect(tester.getBottomLeft(find.byType(SingleChildScrollView)).dy, 874);
  });

  testWidgets('content ends above the home indicator by default', (
    tester,
  ) async {
    await pump(tester);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -3000),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getBottomLeft(find.byKey(const Key('content'))).dy,
      874 - _homeIndicator,
    );
  });

  testWidgets('tab screens end their content at the bottom edge', (
    tester,
  ) async {
    await pump(tester, safeBottom: false);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -3000),
    );
    await tester.pumpAndSettle();

    expect(tester.getBottomLeft(find.byKey(const Key('content'))).dy, 874);
  });
}
