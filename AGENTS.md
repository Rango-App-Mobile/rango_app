# AGENTS.md

Instructions for AI coding agents (Codex, Cursor, Copilot, Gemini and others)
working in this repository.

**The full instructions live in [`CLAUDE.md`](CLAUDE.md). Read it before doing
anything** — commands, structure, stack, the rules that apply in every file and
the workflow are all there, and they apply to every agent, not only Claude.

Also read, depending on the task:

- `docs/contexto.md` — canonical product, architecture and decision document
  (Portuguese, cite it by section: §5 architecture, §7 business rules, §8 data
  model, §11 decisions).
- `.claude/rules/*.md` — rules per area. Each file's `paths:` frontmatter says
  which files it covers: `dart.md` (all Dart), `flutter.md` (`lib/`),
  `riverpod.md` (`*_view_model.dart`), `firebase.md` (`lib/data/`).
- `docs/sdd.md` — the spec → plan → tasks cycle. Product stories are specified
  in `docs/specs/NNN-slug/` before any code.
- `.claude/skills/*/SKILL.md` — repeatable procedures (writing a spec,
  implementing a task, reviewing a PR, security review, sprint status, marketing
  brief). Agents without skill support can follow them as plain checklists.

Non-negotiables, in short:

1. MVVM by screens (`lib/screens/<screen>/` = View + ViewModel; shared
   `lib/models/` and `lib/data/`). View has no business logic; ViewModel never
   touches Firebase/HTTP/GPS; models are pure Dart.
2. Never read or commit `env.json` / `.env*`; no literal keys.
3. Tests first; `dart format`, `flutter analyze` and `flutter test` must pass.
4. Code and commits in English; docs, specs and UI text in Portuguese.
5. Do not push, open PRs, comment on PRs or close issues without being asked.
