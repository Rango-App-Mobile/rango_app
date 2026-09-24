---
name: implement-task
description: Use when the user asks to implement, code or start a task from a Rango spec or a sub-issue ("implementa a task 3 da spec 001", "pega a sub-issue #45", "implement-task"). Works test-first against docs/specs/NNN-slug/{spec,plan,tasks}.md.
---

# Implement a task — Rango

## Before writing code

1. Find the spec folder (by number, or from the sub-issue: its body points to
   `docs/specs/NNN-slug/tasks.md`).
2. Read `spec.md`, `plan.md` and `tasks.md` in full, `CLAUDE.md`, and every
   `.claude/rules/` file whose `paths:` match the files the plan names.
3. Check the branch: `feat/<issue>-<slug>` off `dev`. If you are on `dev` or
   `main`, stop and say so.
4. If the plan is wrong or impossible against the current code, stop and
   explain. Do not improvise a different architecture.

## Cycle (one task at a time)

1. Write the test for the task's criterion and run it: it must fail for the
   right reason.
2. Implement the minimum to pass, in the layer the plan says.
3. `dart run build_runner build --delete-conflicting-outputs` if a model changed.
4. `dart format .`, `flutter analyze`, `flutter test` — all green.
5. Tick the item in `tasks.md` and propose the commit message
   (`feat(<feature>): ... (#<issue>)`). Commit only if asked.

## When the task closes the story

The last task writes or updates `docs/<feature>.md` (Portuguese) from
`references/feature-doc.md`: what exists and why, not what was planned.

## Limits

- Do not widen the scope. Anything outside the task goes to the spec's
  "Fora de escopo" or becomes a suggested issue.
- New dependency: ask first.
- Never push, open a PR or close an issue without being asked.
