import 'package:rango_app/data/onboarding_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsOnboardingRepository implements OnboardingRepository {
  SharedPrefsOnboardingRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'onboarding_seen';

  @override
  bool get hasSeen => _prefs.getBool(_key) ?? false;

  @override
  Future<void> markSeen() => _prefs.setBool(_key, true);
}
