import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rango_app/models/app_user.dart';

part 'profile_state.freezed.dart';

/// What the Profile Sheet shows about the person (Figma `Profile Sheet`,
/// `Mode=Visitante` and `Mode=Conta`).
@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    required bool isGuest,
    required String name,
    String? subtitle,
    String? photoUrl,
  }) = _ProfileState;

  factory ProfileState.fromUser(AppUser user) {
    if (user.isAnonymous) return guest;

    final name = user.name?.trim();
    final hasName = name != null && name.isNotEmpty;
    return ProfileState(
      isGuest: false,
      name: hasName ? name : user.email ?? 'Sua conta',
      subtitle: hasName ? user.email : null,
      photoUrl: user.photoUrl,
    );
  }

  static const guest = ProfileState(
    isGuest: true,
    name: 'Visitante',
    subtitle: 'Sessão anônima neste aparelho',
  );
}
