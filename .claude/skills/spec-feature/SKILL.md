---
name: spec-feature
description: Use when the user wants to write, draft or start a spec for a user story or GitHub issue in the Rango repository ("escreve a spec da issue #12", "cria a spec", "planeja essa história", "spec-feature"). Produces docs/specs/NNN-slug/spec.md and, after approval, plan.md and tasks.md.
---

# Feature spec — Rango

Turns a story (GitHub issue) into `spec.md`, then `plan.md`, then `tasks.md`,
following `docs/sdd.md`. Specs are project docs, so their content is in
**Portuguese**; identifiers stay in English.

## The one rule

**Do not invent requirements.** Anything not in the issue or in
`docs/contexto.md` becomes a question in the "Decisões" table with status
`em aberto` — not an answer of yours.

## Steps

1. Read the issue: `gh issue view <N> --comments`. Note the epic (parent issue),
   sprint (milestone), front (`frente:*` label) and acceptance criteria. Stories
   are generated from `.github/backlog/backlog.yml`; the `backlog-id` marker in
   the body tells you which entry.
2. Read the sections of `docs/contexto.md` the story touches (§6, §7, §8, §9
   almost always) and `ls docs/specs/` for related specs. If the feature already
   shipped something, read `docs/<feature>.md`.
3. Next number: highest `NNN` in `docs/specs/` + 1 (start at `001`). Short slug,
   English, kebab-case (`001-category-tree`). The number never changes.
4. Copy `references/spec.md` to `docs/specs/NNN-slug/spec.md` and fill it.
   Acceptance criteria must be testable, in "Dado / quando / então" form.
5. **Stop and show the spec.** List open questions at the end. Wait for approval
   before the plan.
6. With the spec approved: `plan.md` from `references/plan.md`, reading the
   current code (layers, existing providers, repository interfaces). Respect
   `.claude/rules/`. **Stop again.**
7. With the plan approved: `tasks.md` from `references/tasks.md`. Each task fits
   a small PR and has a verifiable "pronto quando". Suggest the
   `gh issue create` commands for the sub-issues (label `type:task`, same
   milestone and `frente:*`), **without running them**.

## Output

The files in the spec folder and a short chat summary: open decisions, risks,
number of tasks. No emojis.

## Limits

- A decision that goes beyond the story (architecture, stack, business rule) is
  flagged for `docs/contexto.md` §11 — do not edit §11 yourself.
- Never change `backlog.yml` from here; suggest the change instead.
