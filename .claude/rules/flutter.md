---
paths: "lib/**"
---

# Flutter: MVVM, feature-first

Layers and boundaries come from `docs/contexto.md` §5. The import table is in
`docs/guia-setup.md` §3.2.

## Where things live

- One feature = one folder in `lib/features/` with `model/`, `data/`,
  `view_model/`, `view/`. Create only the layers the story needs.
- Code shared between features goes to `lib/core/`; `core/` never imports from
  `features/`, and a feature never imports another feature's `data/` or
  `view_model/`. Circular dependencies block any refactor.
- Composition (routes, theme, `MaterialApp`) lives in `lib/app/`. It is the only
  place, besides `view/`, that may know every feature.

## Boundaries

- `model/` does not import `package:flutter`, Riverpod, Firebase or `dio`.
  Business rules need pure unit tests.
- `view/` imports nothing from `data/`. If a screen knows the repository, the
  ViewModel stopped being the boundary.
- No `BuildContext` outside `view/` and `app/`. A ViewModel with a
  `BuildContext` cannot be tested without pumping widgets.
- Navigation through `go_router` (`context.go` / `context.push`), called by the
  View in response to state. The ViewModel exposes state; it does not navigate.

## Widgets

- A screen is a `ConsumerWidget` (or `ConsumerStatefulWidget` when it needs an
  animation or text controller). Child widgets without Riverpod when possible:
  pass data in, callbacks out.
- Async state is drawn with `AsyncValue.when` or a `switch`: loading, error and
  data always handled. A screen without an error state becomes a blank screen
  on the reviewer's phone.
- Every screen has empty and error states with a way out (retry, back, settings
  for denied location).
- Colors and text styles come from the theme (`Theme.of(context)`), never
  literals: the palette is defined by the Marketing front
  (`docs/marketing/identidade.md`) and changes in one place.
- UI strings in Portuguese, inline in the widget, until an i18n decision exists
  in `docs/contexto.md` §11.
- Swipe gestures always have a button alternative (accessibility, and the
  simulator).
