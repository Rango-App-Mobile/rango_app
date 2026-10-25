---
name: implement-task
description: Use when the user asks to implement, code or start a Rango story or issue ("implementa a issue #8", "implementa a sessão anônima", "implement-task"). Works test-first from the issue's acceptance criteria; no spec files.
---

# Implement a story — Rango

No spec, plan or tasks files are written before coding (`docs/sdd.md`). The
issue's acceptance criteria are the contract.

## Before writing code

1. Read the issue (`gh issue view <N>` or its entry in
   `.github/backlog/backlog.yml`), `CLAUDE.md`, the `docs/contexto.md` sections
   it touches, and every `.claude/rules/` file whose `paths:` match the files
   you will change.
2. Check the branch: `feat/<issue>-<slug>` off `dev`. If you are on `dev` or
   `main`, stop and say so.
3. If a criterion is ambiguous or contradicts `docs/contexto.md`, ask instead
   of inventing. Keep any planning in the chat, not in files.

## Cycle (one criterion at a time)

1. Write the test for the criterion and run it: it must fail for the right
   reason.
2. Implement the minimum to pass, in the right layer (`CLAUDE.md`, rules).
3. `dart run build_runner build --delete-conflicting-outputs` if a model changed.
4. `dart format .`, `flutter analyze`, `flutter test` — all green.
5. Propose the commit message (`feat(<screen>): ... (#<issue>)`). Commit only
   if asked.

## When the story is done

Write or update `docs/<feature>.md` (Portuguese) from
`references/feature-doc.md`: what was shipped and how it works.

## Limits

- Do not widen the scope. Anything outside the story becomes a suggested issue.
- New dependency: ask first.
- Never push, open a PR or close an issue without being asked.
