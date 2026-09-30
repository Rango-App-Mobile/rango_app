/// Compile-time configuration injected with `--dart-define-from-file`.
abstract final class Env {
  static const placesApiKey = String.fromEnvironment('PLACES_API_KEY');

  static bool get hasPlacesKey => placesApiKey.isNotEmpty;
}
