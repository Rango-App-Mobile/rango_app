import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/data/fake_account_repository.dart';

void main() {
  test('accepting the terms is remembered per uid; deleting forgets', () async {
    final repository = FakeAccountRepository();
    expect(await repository.hasAcceptedTerms('u1'), isFalse);

    await repository.acceptTerms('u1');
    expect(await repository.hasAcceptedTerms('u1'), isTrue);
    expect(await repository.hasAcceptedTerms('u2'), isFalse);

    await repository.deleteData('u1');
    expect(await repository.hasAcceptedTerms('u1'), isFalse);
  });
}
