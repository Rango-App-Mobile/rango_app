---
paths: "lib/**/data/**"
---

# Data layer: Firebase, Places, device services

Firestore data model in `docs/contexto.md` §8.

## Repositories

- Every repository has an **interface** (`abstract interface class`) and its
  implementations: `Fake...` (in memory, the provider default until the story
  that brings the real backend, and used by tests) and `Firestore...` /
  `Places...`. ViewModels and tests depend on the interface.
- The repository provider lives in the same file as the interface and returns
  the default implementation. Swapping Fake for Firestore changes only its body.
- Convert everything to models at the edge: `FoodCategory.fromJson(doc.data())`.
  `DocumentSnapshot`, `dio`'s `Response` and `geolocator`'s `Position` never
  leave `data/`.
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
- `firebase_options.dart`, `google-services.json` and
  `GoogleService-Info.plist` identify the project; they are not secrets and are
  committed. The rules protect the data.

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
