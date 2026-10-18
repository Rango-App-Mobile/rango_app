import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';

/// The person using the app. Anonymous users are guests: nothing of theirs
/// is saved (`docs/contexto.md` R1).
@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String uid,
    required bool isAnonymous,
  }) = _AppUser;
}
