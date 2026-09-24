---
paths:
  - "lib/**/*.dart"
  - "test/**/*.dart"
---

# Dart style

## Naming

- Everything that is code — symbols, comments, test names — and commit messages
  in English. Project docs (`README`, `docs/`) and UI strings in Portuguese.
- Types in `UpperCamelCase`, members and functions in `lowerCamelCase`,
  constants in `lowerCamelCase` (not `SCREAMING_CAPS`).
- Files in `snake_case` with their role in the name:
  `swipe_session_notifier.dart`, `firestore_category_repository.dart`,
  `swipe_screen.dart`, `food_category.dart`.
- Consistent suffixes: `...Screen`, `...Notifier`, `...State`, `...Repository`,
  `...Service`, `...Failure`. Fakes are `Fake...`.
- No invented abbreviations: `category`, not `cat`; `restaurant`, not `rest`.

## Writing

- `final` by default; `var` only when it changes; `const` constructors whenever
  possible (the lints enforce it).
- No `dynamic`. If a type is really unknown, `Object?` and narrow it.
- No `!` to silence the analyzer — fix the type or handle the null.
- `package:rango_app/...` imports, never relative imports across features.
- No `print`. `debugPrint` only while developing; remove it before the PR.
- Comments explain **why**. If one has to explain *what*, rewrite the code.
- One public class per file, named like the file (small private helpers are
  fine).

## Async

- `async`/`await`, never chained `.then()`.
- Every `Future` is awaited or explicitly passed on (`unawaited(...)` with a
  comment saying why). No floating futures.
- Every call to the network has a timeout (see `firebase.md` for `dio`).

## Errors

- Code outside `data/` never sees an SDK exception. `data/` catches
  `FirebaseException`, `DioException`, permission errors and returns a
  `Failure` (`lib/core/error/failure.dart`). The screen draws from the type.
- Never swallow an error with an empty `catch {}` without a comment explaining
  why.
- Never show a raw exception message to the user: it leaks internals and is in
  English.

## Tests

- `test/` mirrors `lib/`: `lib/features/swipe/view_model/x.dart` →
  `test/features/swipe/view_model/x_test.dart`.
- Test names describe behavior, in English: `'converges after choosing down to
  a leaf'`, not `'test choose'`.
- **Model:** plain unit test, no providers.
- **ViewModel:** `ProviderContainer.test(overrides: [...])` replacing the
  repository provider with a `Fake...` or a `mocktail` mock. To test errors pass
  `retry: (_, _) => null` — Riverpod 3 retries failing providers.
- **View:** `testWidgets` with `ProviderScope(overrides: [...])` and
  `MaterialApp(home: ...)`, always overriding the repository explicitly, even
  if the default is a fake. When the default becomes Firestore, the test still
  runs offline.
- No test touches the network, real Firebase or GPS. CI has no credentials.
- When fixing a bug, write the failing test first. Every acceptance criterion
  of a spec becomes at least one test.
- `flutter test` must pass without `env.json`.
