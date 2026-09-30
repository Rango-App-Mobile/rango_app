# Rango — app

Flutter app (iOS + Android) for the Senac *Projeto de Desenvolvimento I* course.
The user makes a short run of binary choices by swipe (savory vs. sweet → pasta →
spaghetti) until the session converges on one type of food, and the app then
recommends real, nearby restaurants for it (Google Places), ready to open in a
delivery app.

> **`docs/contexto.md` is the canonical source** for product, architecture,
> business rules, data model, schedule and decisions. This file does not
> summarize it; it tells you where to look:
>
> | I need... | Section |
> |---|---|
> | The pain the app solves, for whom, differentiators | §1, §3 |
> | Stack and layers | §4, §5 |
> | MVP flow, step by step | §6 |
> | Business rules (convergence, radius, ordering) | §7 |
> | Firestore collections and fields | §8 |
> | What is MVP and what is future | §9 |
> | Sprints and deadlines | §10 |
> | Decisions already taken / still open | §11, §12 |
>
> If a task contradicts it, stop and ask. Do not "fix" the document on your own:
> a changed decision goes into §11 in the same PR, reviewed by the team.

## Commands

All of them from the repository root.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after touching a model
dart run build_runner watch --delete-conflicting-outputs   # while developing

flutter run --dart-define-from-file=env.json   # env.json is local, never committed
flutter test                                   # everything
flutter test test/screens/swipe                # one screen

dart format .
flutter analyze
dart format --output=none --set-exit-if-changed .   # what CI runs

python3 .github/scripts/backlog_sync.py --offline   # validates backlog.yml
```

If you only touched a model or a ViewModel, `flutter test` on that folder
(`test/models/`, `test/screens/<screen>/`) is enough — no need to start a
simulator.

## Structure

```
lib/main.dart                 bootstrap: ProviderScope, (later) Firebase.initializeApp
lib/app/                      composition: MaterialApp, GoRouter, theme
lib/core/                     shared: config/env.dart, error/failure.dart, widgets/
lib/models/                   domain data shared by screens: immutable (freezed),
                              pure Dart, business rules (e.g. CategoryTree)
lib/data/                     repositories/services: the only place that talks to
                              Firebase, HTTP or GPS
lib/screens/<screen>/         one folder per screen, View + ViewModel side by side:
  <screen>_screen.dart        View: renders state, captures interaction
  <screen>_view_model.dart    ViewModel: Riverpod Notifier + its provider
  <screen>_state.dart         screen state (freezed), when more than a value
  widgets/                    widgets used only by this screen
test/                         mirrors lib/
docs/                         canonical context, process, specs, marketing
.github/backlog/backlog.yml   source of the backlog (epics, stories, sprints)
.github/workflows/            CI, backlog sync, board automation, sprint report
```

Architecture is **MVVM organized by screens** (`docs/contexto.md` §5, decision
of 2026-09-28 in §11): each screen folder holds its View and ViewModel; models
and repositories are shared because several screens use the same data.
Screens planned (Figma numbering in `docs/contexto.md` §5): `swipe`, `result`,
`restaurants` (map), `restaurant_contact`, `login`, `history`, `history_detail`,
plus the Profile Sheet. The Figma file (link in §6) is the visual source: tokens
go to `lib/app/theme/`, shared components to `lib/core/widgets/`. A screen folder is born with its story. The
anonymous session has no screen: it is a repository in `lib/data/`.

> **Current state:** the skeleton from `docs/guia-setup.md` steps 1–4 is in
> place (issues #3 and #4): `swipe` is a reference slice with provisional
> buttons over `FakeCategoryRepository`. New screens follow its shape.

Docs in `docs/`, all in Portuguese:

| File | What it is |
|---|---|
| `contexto.md` | Canonical context (numbered sections, cite by §) |
| `acordo-projeto.md` (+ PDF) | Signed project agreement: scope, benchmark, schedule, team fronts |
| `guia-setup.md` | Step-by-step setup: Flutter, dependencies, MVVM, env |
| `sdd.md` | Spec-driven development cycle and templates |
| `git-e-prs.md` | Branches, commits, PRs, GitHub automation |
| `time-e-rituais.md` | Team fronts (Dev, Marketing, Produto/UX), rituals, DoR/DoD |
| `marketing/` | Positioning, identity, content calendar, briefs |
| `specs/NNN-slug/` | One folder per spec (`spec.md`, `plan.md`, `tasks.md`) |
| `<feature>.md` | One file per shipped product feature (e.g. `swipe.md`): what exists and why |

## Stack

- **Flutter** (stable) + **Dart 3**, iOS and Android only.
- **Riverpod 3** as the ViewModel layer — hand-written providers, no codegen.
- **freezed** + **json_serializable** for models; **go_router** for navigation.
- **Firebase Auth** (anonymous) and **Cloud Firestore** — from Sprint 2.
- **Google Places API** via **dio** — from Sprint 3.
- **very_good_analysis** lints; **mocktail** for tests.
- Ask before proposing a new dependency.

## Rules that apply in any file

**The View has no business logic.** A widget reads state with `ref.watch` and
calls a Notifier method. Logic inside a widget can only be tested with widget
tests, which are slow and brittle.

**A ViewModel never talks to Firebase, HTTP or GPS.** Only to a repository
interface, obtained through a provider. That is the seam tests override to run
without network. A screen never imports another screen's ViewModel: what passes
from one screen to the next goes through the route or a provider in `lib/data/`.

**Models are pure Dart.** No `package:flutter`, Riverpod, Firebase or `dio` in
`lib/models/`. The convergence rule lives there and must be unit-testable instantly.

**State is immutable.** Models are `freezed`; state changes through `copyWith`
and new lists. Riverpod only rebuilds when the reference changes.

**Generated code is committed.** `*.g.dart` and `*.freezed.dart` go in the same
commit as the model. CI does not run `build_runner`.

**No secrets in git.** Keys come from `env.json` through
`--dart-define-from-file` and are read only in `lib/core/config/env.dart`.
`env.json` and `.env*` must not be read; `env.example.json` lists the variables.
The app and `flutter test` must work without the key — CI and a fresh clone do
not have one.

**Firebase lives only in `lib/data/`.** Exception: `Firebase.initializeApp` in
`main.dart`.

**Fakes first.** Each repository ships a `Fake...` in-memory implementation that
is the provider default until the story that brings the real backend. The app
must always compile and run without Firebase or Places configured.

**Language.** Code, identifiers, test names, comments and commit messages in
English. Docs (`docs/`), specs and UI strings in Portuguese. Agent-facing files
(`CLAUDE.md`, `AGENTS.md`, `.claude/`) in English.

## Workflow

- Branch off `dev`: `feat/<issue>-<slug>`, `fix/<issue>-<slug>`,
  `docs/<issue>-<slug>`, `chore/<issue>-<slug>`. The issue number moves the card
  on the board automatically; maintenance without an issue may use
  `chore/<slug>`. Never commit directly to `dev` or `main` — `main` receives
  `dev` at each sprint review.
- Conventional Commits in English with the issue at the end:
  `feat(swipe): add session notifier (#14)`.
- Before opening a PR run `dart format .`, `flutter analyze` and `flutter test`:
  they are the three CI jobs. PR to `dev`, template filled in, `Closes #<issue>`,
  1 approval.
- **Spec before code.** Product stories go through spec → plan → tasks in
  `docs/specs/NNN-slug/` before implementation (`docs/sdd.md` says when it can be
  skipped). When implementing a task: read `spec.md` and `plan.md`, write the
  test first, do not widen the scope — anything out of scope goes to the spec's
  "Fora de escopo" or a new issue.
- **The backlog is code.** Change stories by editing
  `.github/backlog/backlog.yml`; never edit the body of a generated issue (the
  sync overwrites it). Discussion goes in issue comments.
- Changed a product rule, the data model or a decision? Update
  `docs/contexto.md` (§7, §8, §11) in the same PR.
- Do not run `flutter create`, `flutterfire configure` or `git push` without
  asking. Do not post PR comments or close issues: write the text and hand it
  over.
- Area-specific rules live in `.claude/rules/`; project skills in
  `.claude/skills/`.
