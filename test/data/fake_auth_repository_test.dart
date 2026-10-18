import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/data/fake_auth_repository.dart';

void main() {
  test('returns the same anonymous uid on repeated calls', () async {
    final repository = FakeAuthRepository();

    final first = await repository.ensureSignedIn();
    final second = await repository.ensureSignedIn();

    expect(first.isAnonymous, isTrue);
    expect(second.uid, first.uid);
  });
}
