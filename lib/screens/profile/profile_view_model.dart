import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/screens/profile/profile_state.dart';

/// Riverpod's automatic retry is off: the session was already created behind
/// the startup gate, so a failure here has nothing to wait for.
final profileViewModelProvider =
    StreamNotifierProvider<ProfileViewModel, ProfileState>(
      ProfileViewModel.new,
      retry: (_, _) => null,
    );

/// Follows the user, so the sheet changes by itself after sign-in and
/// sign-out.
class ProfileViewModel extends StreamNotifier<ProfileState> {
  @override
  Stream<ProfileState> build() =>
      ref.watch(authRepositoryProvider).watchUser().map(ProfileState.fromUser);

  Future<void> signOut() async {
    try {
      await ref.read(authRepositoryProvider).signOut();
    } on Failure {
      // The account is gone even if the new guest session could not be
      // created (offline); the startup gate creates it on the next launch.
      if (ref.mounted) state = const AsyncData(ProfileState.guest);
    }
  }
}
