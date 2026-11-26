import 'package:rango_app/data/onboarding_repository.dart';

class FakeOnboardingRepository implements OnboardingRepository {
  FakeOnboardingRepository({this.seen = true});

  bool seen;

  @override
  bool get hasSeen => seen;

  @override
  Future<void> markSeen() async => seen = true;
}
