# Review checklist — Rango

## Part 1 — Invariants

### Layers (`docs/contexto.md` §5, `.claude/rules/flutter.md`)
- [ ] `model/` imports no Flutter, Riverpod, Firebase or `dio`
- [ ] `view/` imports nothing from `data/`
- [ ] ViewModels reach repositories only through a provider and an interface
- [ ] No `BuildContext` in a ViewModel; navigation happens in the View
- [ ] `core/` does not import from `features/`; features do not import each
      other's `data/` or `view_model/`

### State (`.claude/rules/riverpod.md`)
- [ ] State is `freezed` and updated with `copyWith` / new lists (no mutation)
- [ ] `Notifier` / `AsyncNotifier` only — no `StateNotifier`, `ChangeNotifier`,
      `StateProvider`
- [ ] `ref.mounted` checked after `await` before writing `state`
- [ ] Every `AsyncValue` is drawn with loading, error and data

### Data (`.claude/rules/firebase.md`)
- [ ] SDK exceptions become `Failure` inside `data/`
- [ ] API keys only through `Env`; nothing literal, not even in tests
- [ ] `dio` with timeouts; Places calls with `X-Goog-FieldMask`; no header/URL
      logging
- [ ] Firestore queries on growing collections have `limit`
- [ ] Changed a collection or field? `docs/contexto.md` §8 updated in the PR
- [ ] Changed who can read/write? `firestore.rules` changed in the same PR

### Tests (`.claude/rules/dart.md`)
- [ ] Every acceptance criterion of the spec/task has a test
- [ ] ViewModel tests override the repository; no test touches network,
      Firebase or GPS
- [ ] `flutter test` passes without `env.json`
- [ ] Generated files (`*.g.dart`, `*.freezed.dart`) updated in the same commit

### Process (`docs/sdd.md`, `docs/git-e-prs.md`)
- [ ] Product story → the PR names its spec and task; spec is approved
- [ ] `Closes #<issue>`, branch `feat|fix|docs|chore/<issue>-<slug>`
- [ ] New dependency justified in the PR body
- [ ] Story finished → `docs/<feature>.md` created or updated

## Part 2 — Deliberate decisions (do NOT flag)

See `../security-review-rango/references/known-deliberate.md`. Check that the
cited source still says the same before relying on an entry.

## Part 3 — Gap analysis (run as a separate pass)

- Empty list? No network? Location denied or permanently denied? No `env.json`?
- Double tap on a button that triggers I/O? Back navigation mid-flow?
- Undo/reset at the first and at the last level of the tree?
- The screen on a small phone (overflow) and with a long restaurant name?
- Does the PR deliver everything the task says? Is what was left out written in
  the spec's "Fora de escopo" or in an issue?
- Tests that should exist but do not: the error path, the empty path, the
  boundary (first/last choice).
