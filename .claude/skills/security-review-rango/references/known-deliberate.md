# Deliberate decisions — do not report as bugs

A cache of documented decisions. Before using an entry to **not** report
something, confirm the cited source still says the same. If it changed, report
it under "Skill desatualizada".

- **Google Places key on the client**, restricted by app (bundle id / package +
  certificate). A Cloud Functions proxy is the future path and is still an open
  question. (`docs/contexto.md` §12, `docs/guia-setup.md` step 4)
- **Firebase project ids are committed** in `lib/firebase_options.dart`; the
  Firebase API keys are not (they come from `env.json` via `Env`). A literal
  `AIza…` key, or a committed `google-services.json` / `GoogleService-Info.plist`,
  **is** a finding. (`.claude/rules/firebase.md`, `docs/contexto.md` §11
  2026-10-24)
- **`Fake...` repositories are the provider default** until the story that
  brings the real backend. (`CLAUDE.md`, "Fakes first")
- **Generated files are committed**; CI does not run `build_runner`.
  (`CLAUDE.md`)
- **Riverpod without codegen.** (`CLAUDE.md` Stack, `.claude/rules/riverpod.md`)
- **`public_member_api_docs` and `one_member_abstracts` disabled** in
  `analysis_options.yaml`: this is an app, not a published package.
  (`docs/guia-setup.md` §1.2)
- **Buttons as an alternative to the swipe gesture** — accessibility, not a
  missing gesture. (`.claude/rules/flutter.md`)
- **Anonymous auth only**, no sign-up in the MVP. (`docs/contexto.md` §3, §9)
