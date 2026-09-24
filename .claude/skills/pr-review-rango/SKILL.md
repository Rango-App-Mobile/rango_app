---
name: pr-review-rango
description: Use when the user asks to review, check, look over, or give feedback on a pull request, branch, or diff in the Rango Flutter repository (Flutter + Riverpod + Firebase + Google Places), including bare asks like "review this", "revisa esse PR" or "o que achou desse PR".
---

# PR Review — Rango

Review pull requests for **Rango**, a Flutter app (Riverpod 3 as the ViewModel
layer, Firebase Auth/Firestore, Google Places). Review against **this project's**
rules — MVVM boundaries, fakes-first repositories, spec-driven stories — not
generic Flutter advice. A generic reviewer flags deliberate decisions as bugs
and misses what matters here: a ViewModel that reaches the network, a key in the
diff, a screen with no error state, a spec criterion nobody tested.

**Install this skill as a sibling of `security-review-rango`** (both directly
under `.claude/skills/`). Step 3b reads paths relative to that layout.

The `-rango` suffix on the security skill is not decoration: Claude Code ships a
built-in `security-review` skill, and a project skill with the same name would
make every reference below ambiguous. Keep the suffix.

## The one rule that outranks the rest

**Do not invent problems.** A clean PR is a valid — and common — outcome. Every
finding must point at a real problem in the actual diff: something wrong,
unsafe, untested, or contradicting a project rule. If you cannot name the
concrete consequence, it is not a finding. Analyze rigorously, report only what
is real.

## Workflow

Five steps. Do not skip ahead to GitHub text — the reviewer chooses what gets
raised (step 4) before you write anything (step 5).

### Step 1 — Establish the diff and gather context

```bash
git fetch origin
git diff origin/dev...HEAD --stat
git diff origin/dev...HEAD
```

`dev` is the base branch for every PR (`main` receives `dev` at sprint
reviews). If `origin/dev` does not resolve, ask for the base branch.

Then **read beyond the diff**. Most real bugs here are interaction bugs:

- Open the provider, repository interface and screen the changed code calls
  into or is called by. A change in a `Fake...` repository must still match the
  interface the real one will implement.
- For a new screen, open `lib/app/router.dart` and check the route and how the
  screen is reached.
- If a model changed, check that the generated `*.freezed.dart` / `*.g.dart`
  changed with it (CI does not run `build_runner`).

### Step 2 — Read the relevant project docs

Always read `CLAUDE.md` and every file in `.claude/rules/` (the whole directory,
not a fixed list). Then:

```bash
ls docs/ docs/specs/ 2>/dev/null
```

| The diff touches… | Read |
|---|---|
| Any feature code | `docs/contexto.md` §5 (layers) and §7 (business rules) |
| A story with a spec | `docs/specs/NNN-slug/{spec,plan,tasks}.md` — the PR body should name it |
| Firestore, models persisted | `docs/contexto.md` §8 |
| A feature already shipped | `docs/<feature>.md` |
| `.github/`, backlog, process | `docs/git-e-prs.md`, `docs/sdd.md` |
| `pubspec.yaml` | `CLAUDE.md` Stack — new dependencies need a justification in the PR |

Anything else in `ls docs/` whose name suggests it covers the diff: read it.
`docs/contexto.md` is canonical; if the diff contradicts it and no spec
settles it, that is a Bucket B question, not a bug.

### Step 3 — Analyze

Work through `references/checklist.md` — invariants, deliberate decisions you
must NOT flag, and the gap analysis. Run the gap analysis (Part 3) as its own
pass: what happens with an empty list, no network, location denied, no
`env.json`, a double tap, going back mid-flow? Does the PR deliver every
acceptance criterion of the task it claims?

**Bucket A — PR findings**, each with a severity:

- **Critical** — secret or key in the diff, literal API key, `env.json`
  committed, Firestore rules opening another user's data, a ViewModel/View
  calling Firebase/HTTP directly in a way that breaks tests or CI.
- **High** — a real bug: mutated state that never rebuilds, missing error or
  loading state on a screen, `state` written after `await` without
  `ref.mounted`, an acceptance criterion not met, a crash path.
- **Medium** — missing test for a real path or an acceptance criterion, a
  `.claude/rules/` rule broken without consequence yet, generated files stale.
- **Low / nitpick** — naming, clarity. Only if real.

### Step 3b — Dispatch the security pass

**If a subagent tool is available:** dispatch a subagent pointed at
`security-review-rango` with the same diff; ask for its findings block only.
**If not:** read `security-review-rango/SKILL.md` and its
`references/vulnerability-checklist.md` and run that pass inline now.

Merge the results into Bucket A by severity, tagged `[security: <category>]`.
Cross-check against `security-review-rango/references/known-deliberate.md`
before accepting a security finding.

**Bucket B — Documentation inconsistencies.** The diff contradicts
`docs/contexto.md`, a spec or a feature doc, or a doc would need to change to
accommodate it (e.g. a Firestore field added with no §8 update). Surface these
as questions, outside the severity buckets.

For every finding capture file, line(s), what is wrong and the consequence.

### Step 4 — Present findings and wait

In chat (not a file):

```
## Revisão — <branch or PR>

### Bucket A — Achados
#### Críticos
#### Altos
#### Médios
#### Nitpicks

### Bucket B — Inconsistências com a documentação

### Critérios de aceitação da spec não cobertos

### Skill desatualizada
```

Omit empty groups. If the PR is clean, say so in one line. Then ask which
findings should become comments. **Stop and wait.**

### Step 5 — Write paste-ready GitHub comments

Only for the findings the reviewer picked. In Portuguese, direct, no em-dashes,
no filler, identifiers in English inside backticks. One comment per finding,
with `arquivo:linha` so it can be pasted inline. **Do not post anything** — hand
the text over.

## Keeping this skill current

If a doc, rule or `known-deliberate.md` entry no longer matches the code, list
it under "Skill desatualizada" instead of silently working around it.
