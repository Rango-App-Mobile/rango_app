import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/core/widgets/apple_sign_in_button.dart';

Widget _host(VoidCallback? onPressed) => MaterialApp(
  home: Scaffold(body: AppleSignInButton(onPressed: onPressed)),
);

void main() {
  testWidgets('fallback calls onPressed on tap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_host(() => taps++));
    await tester.tap(find.byType(AppleSignInButton));
    expect(taps, 1);
  });

  testWidgets('fallback is dimmed and ignores taps when disabled', (
    tester,
  ) async {
    await tester.pumpWidget(_host(null));
    final opacity = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(AppleSignInButton),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacity.opacity, 0.4);
    final ignore = tester.widget<IgnorePointer>(
      find.descendant(
        of: find.byType(AppleSignInButton),
        matching: find.byType(IgnorePointer),
      ),
    );
    expect(ignore.ignoring, isTrue);
  });

  testWidgets('on iOS hosts the native button platform view', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(_host(() {}));
      final view = tester.widget<UiKitView>(find.byType(UiKitView));
      expect(view.viewType, 'rango/apple_sign_in_button');
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
