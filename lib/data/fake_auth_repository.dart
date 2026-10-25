import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/models/app_user.dart';

class FakeAuthRepository implements AuthRepository {
  static const user = AppUser(uid: 'fake-uid', isAnonymous: true);

  @override
  Future<AppUser> ensureSignedIn() async => user;
}
