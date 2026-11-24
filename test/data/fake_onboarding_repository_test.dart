import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/data/fake_onboarding_repository.dart';

void main() {
  test('starts as already seen, so other tests skip the onboarding', () {
    expect(FakeOnboardingRepository().hasSeen, isTrue);
  });

  test('can start as not seen and remembers markSeen', () async {
    final repository = FakeOnboardingRepository(seen: false);

    expect(repository.hasSeen, isFalse);
    await repository.markSeen();
    expect(repository.hasSeen, isTrue);
  });
}
