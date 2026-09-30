---
paths: "lib/screens/**/*_view_model.dart"
---

# ViewModels with Riverpod 3

Notifiers are the ViewModels of the MVVM (`docs/contexto.md` §5).

- `Notifier<T>` for synchronous state, `AsyncNotifier<T>` when the initial
  state depends on I/O. No `StateNotifier`, `ChangeNotifier` or
  `StateProvider`: they are legacy APIs in Riverpod 3 and mixing styles confuses
  readers.
- The class is named `<Screen>ViewModel` (e.g. `SwipeViewModel`), one per
  screen, in `<screen>_view_model.dart`.
- No codegen (`riverpod_generator`). The provider is hand-written next to the
  class: `final swipeViewModelProvider = AsyncNotifierProvider<SwipeViewModel,
  SwipeState>(SwipeViewModel.new);`.
- State is an immutable `freezed` model. Update it with `copyWith` and new lists
  (`[...old, item]`); never `state.list.add(...)`. Riverpod compares
  references; mutation does not rebuild the screen.
- Dependencies come in through `ref.watch(someRepositoryProvider)` inside
  `build()`. That is the point tests override.
- Never instantiate a repository, `FirebaseFirestore`, `Dio` or `Geolocator`
  here. The ViewModel test must run without network.
- Errors from repositories arrive as `Failure`. The ViewModel decides what to
  expose; it never rethrows raw SDK exceptions.
- Public methods are user actions (`choose`, `undo`, `reset`, `retry`). Pure
  business rules (convergence, filtering, ordering) go to the model, where
  tests are cheapest.
- After an `await`, check `ref.mounted` before writing `state`: the screen may
  have been closed mid-call.
