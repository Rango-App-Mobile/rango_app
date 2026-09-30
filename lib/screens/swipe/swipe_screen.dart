import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/screens/swipe/swipe_view_model.dart';

class SwipeScreen extends ConsumerWidget {
  const SwipeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(swipeViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rango')),
      body: Center(
        child: session.when(
          loading: () => const CircularProgressIndicator(),
          error: (error, _) => const Text('Não deu para carregar as opções.'),
          data: (state) => switch (state.result) {
            final result? => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Bora de ${result.label}!'),
                TextButton(
                  onPressed: () =>
                      ref.read(swipeViewModelProvider.notifier).reset(),
                  child: const Text('Recomeçar'),
                ),
              ],
            ),
            null => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.current.label),
                for (final option in state.options)
                  ElevatedButton(
                    onPressed: () => ref
                        .read(swipeViewModelProvider.notifier)
                        .choose(option),
                    child: Text(option.label),
                  ),
              ],
            ),
          },
        ),
      ),
    );
  }
}
