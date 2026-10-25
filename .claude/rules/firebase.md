---
paths: "lib/data/**"
---

# Data layer: Firebase, Places, device services

Firestore data model in `docs/contexto.md` §8.

## Repositories

- Every repository has an **interface** (`abstract interface class`) and its
  implementations: `Fake...` (in memory, the provider default until the story
  that brings the real backend, and used by tests) and `Firestore...` /
  `Places...`. ViewModels and tests depend on the interface.
- Data that lives in the app by decision (the food list, `docs/contexto.md`
  §8) has a real `Local...` implementation instead of a `Fake...`: it is the
  provider default and tests use it too (`LocalCategoryRepository`).
- The repository provider lives in the same file as the interface and returns
  the default implementation. Swapping Fake for Firestore changes only its body.
- Convert everything to models at the edge: `FoodCategory.fromJson(doc.data())`.
  `DocumentSnapshot`, `dio`'s `Response` and `geolocator`'s `Position` never
  leave `lib/data/`.
- Catch `FirebaseException`, `DioException` and permission errors and return a
  `Failure`. The View draws the error from its type without knowing the SDK.

## Firebase

- Firestore paths are built in one place per repository (constants), never
  scattered string literals.
- Every query on a collection that grows has a `limit`. The free tier bills per
  document read.
- Writes carry `FieldValue.serverTimestamp()` for time fields, not the device
  clock.
- Security Rules are versioned in the repo (`firestore.rules`) and change in the
  same PR as the code that needs them. The client is not trusted: ownership
  (`request.auth.uid`) is enforced by the rules, not by client-side filters.
- The Firebase API keys come only from `Env` (`FIREBASE_ANDROID_API_KEY`,
  `FIREBASE_IOS_API_KEY` in `env.json`). `lib/firebase_options.dart` is
  hand-written: project ids committed, keys from `Env`. There is no
  `google-services.json` / `GoogleService-Info.plist` (gitignored) and no
  `google-services` Gradle plugin. Never run `flutterfire configure`: it writes
  literal keys back (`docs/auth.md`).
- Without the keys `main.dart` skips Firebase and runs on fakes, so a feature
  that adds a Firestore repository also adds its fake override there. The
  rules protect the data.

## Google Places

- The API key comes only from `Env` (`lib/core/config/env.dart`). Never a
  literal, not even in tests.
- `Dio` with explicit `connectTimeout` and `receiveTimeout`. Without a timeout,
  a bad network hangs the loading state forever.
- Request only the fields used (`X-Goog-FieldMask`). The price of a call depends
  on the fields requested.
- Never log URLs or headers of Places calls (no `LogInterceptor` with headers):
  the key would end up in logs.

## Location

- Ask for permission only when the user reaches the restaurant search, with a
  clear explanation (Info.plist / AndroidManifest strings in Portuguese).
- Use the position only to search; do not persist the exact coordinates.
