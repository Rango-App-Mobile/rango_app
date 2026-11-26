import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/data/fake_onboarding_repository.dart';

/// Remembers, on the device, that the onboarding was already shown. Local
/// storage on purpose: the guest (anonymous) user cannot save anything online.
abstract interface class OnboardingRepository {
  /// Synchronous so the router can decide the first route without waiting.
  bool get hasSeen;

  Future<void> markSeen();
}

/// The default says "already seen", so tests and a fresh clone never get
/// redirected; `main.dart` overrides it with the real storage.
final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => FakeOnboardingRepository(),
);
