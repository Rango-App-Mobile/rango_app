import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/screens/profile/profile_state.dart';

/// Riverpod's automatic retry is off: the session was already created behind
/// the startup gate, so a failure here has nothing to wait for.
final profileViewModelProvider =
    AsyncNotifierProvider<ProfileViewModel, ProfileState>(
      ProfileViewModel.new,
      retry: (_, _) => null,
    );

class ProfileViewModel extends AsyncNotifier<ProfileState> {
  @override
  Future<ProfileState> build() async {
    final user = await ref.watch(authRepositoryProvider).ensureSignedIn();
    return ProfileState.fromUser(user);
  }
}
