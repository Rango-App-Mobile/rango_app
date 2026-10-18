import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/models/app_user.dart';

/// Riverpod's automatic retry is off: it would hide the error state for a
/// few seconds and make "Tentar novamente" look broken.
final startupViewModelProvider =
    AsyncNotifierProvider<StartupViewModel, AppUser>(
      StartupViewModel.new,
      retry: (_, _) => null,
    );

class StartupViewModel extends AsyncNotifier<AppUser> {
  @override
  Future<AppUser> build() => ref.watch(authRepositoryProvider).ensureSignedIn();

  void retry() => ref.invalidateSelf();
}
