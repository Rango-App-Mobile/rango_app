---
paths: "lib/**"
---

# Flutter: MVVM by screens

Layers and boundaries come from `docs/contexto.md` §5. The import table is in
`docs/guia-setup.md` §3.2.

## Where things live

- One screen = one folder in `lib/screens/<screen>/` with `<screen>_screen.dart`
  (View), `<screen>_view_model.dart` (ViewModel + provider), `<screen>_state.dart`
  (freezed state, when needed) and `widgets/` (widgets used only there). The
  folder is born with the screen's story.
- Domain data used by more than one screen lives in `lib/models/`; repositories
  and services in `lib/data/`. They do not belong to a screen, because the same
  category or restaurant flows through several screens.
- Code shared by everything (env, `Failure`, generic widgets) goes to
  `lib/core/`; `core/` never imports `models/`, `data/` or `screens/`.
- Composition (routes, theme, `MaterialApp`) lives in `lib/app/`. It is the only
  place that may know every screen.

## Boundaries

- `lib/models/` does not import `package:flutter`, Riverpod, Firebase or `dio`.
  Business rules need pure unit tests.
- A View (`*_screen.dart`, `widgets/`) imports nothing from `lib/data/`. If a
  screen knows the repository, the ViewModel stopped being the boundary.
- A screen never imports another screen's ViewModel or state. What passes from
  one screen to the next goes through the route (a parameter) or a provider in
  `lib/data/`, decided in the story's plan.
- No `BuildContext` outside Views and `app/`. A ViewModel with a `BuildContext`
  cannot be tested without pumping widgets.
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
