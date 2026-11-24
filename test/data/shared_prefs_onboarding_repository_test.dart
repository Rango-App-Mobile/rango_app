import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/data/shared_prefs_onboarding_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('is not seen on a fresh install', () async {
    final prefs = await SharedPreferences.getInstance();

    expect(SharedPrefsOnboardingRepository(prefs).hasSeen, isFalse);
  });

  test(
    'markSeen is remembered by a new repository on the same storage',
    () async {
      final prefs = await SharedPreferences.getInstance();
      await SharedPrefsOnboardingRepository(prefs).markSeen();

      expect(SharedPrefsOnboardingRepository(prefs).hasSeen, isTrue);
    },
  );
}
