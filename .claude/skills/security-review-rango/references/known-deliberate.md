# Deliberate decisions — do not report as bugs

A cache of documented decisions. Before using an entry to **not** report
something, confirm the cited source still says the same. If it changed, report
it under "Skill desatualizada".

- **Google Places key on the client**, restricted by app (bundle id / package +
  certificate). A Cloud Functions proxy is the future path and is still an open
  question. (`docs/contexto.md` §12, `docs/guia-setup.md` step 4)
- **Firebase config files are committed** (`firebase_options.dart`,
  `google-services.json`, `GoogleService-Info.plist`). They identify the project;
  Security Rules protect the data. (`.claude/rules/firebase.md`)
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
