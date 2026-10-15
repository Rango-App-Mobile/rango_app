import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/theme/app_text_styles.dart';
import 'package:rango_app/core/widgets/page_header.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: child),
);

double? _fontSize(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style?.fontSize;

void main() {
  testWidgets('renders title and subtitle', (tester) async {
    await tester.pumpWidget(
      _wrap(const PageHeader(title: 'Título', subtitle: 'Subtítulo')),
    );

    expect(find.text('Título'), findsOneWidget);
    expect(find.text('Subtítulo'), findsOneWidget);
  });

  testWidgets('omits the subtitle when null', (tester) async {
    await tester.pumpWidget(_wrap(const PageHeader(title: 'Título')));

    expect(find.byType(Text), findsOneWidget);
  });

  testWidgets('large uses Display/Large and medium Display/Medium', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const PageHeader(title: 'Grande')));
    expect(
      _fontSize(tester, 'Grande'),
      AppTextStyles.standard.displayLarge.fontSize,
    );

    await tester.pumpWidget(
      _wrap(const PageHeader(title: 'Médio', size: PageHeaderSize.medium)),
    );
    expect(
      _fontSize(tester, 'Médio'),
      AppTextStyles.standard.displayMedium.fontSize,
    );
  });

  testWidgets('title has header semantics', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_wrap(const PageHeader(title: 'Título')));

    expect(
      tester.getSemantics(find.text('Título')),
      matchesSemantics(label: 'Título', isHeader: true),
    );
    handle.dispose();
  });
}
