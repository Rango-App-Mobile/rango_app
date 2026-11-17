import 'package:rango_app/data/account_repository.dart';

/// In-memory accounts: the acceptance lives until the app closes.
class FakeAccountRepository implements AccountRepository {
  final _accepted = <String>{};

  @override
  Future<bool> hasAcceptedTerms(String uid) async => _accepted.contains(uid);

  @override
  Future<void> acceptTerms(String uid) async => _accepted.add(uid);

  @override
  Future<void> deleteData(String uid) async => _accepted.remove(uid);
}
