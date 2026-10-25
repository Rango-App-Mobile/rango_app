import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/screens/startup/startup_view_model.dart';

/// Shown while the anonymous session is created, and when it fails. Once the
/// user is ready, `RangoApp` swaps it for the router.
class StartupScreen extends ConsumerWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startup = ref.watch(startupViewModelProvider);
    final error = startup.hasError && !startup.isLoading ? startup.error : null;

    return Scaffold(
      body: Center(
        child: switch (error) {
          null => const CircularProgressIndicator(),
          final error => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  error is Failure
                      ? error.message
                      : const UnexpectedFailure().message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.read(startupViewModelProvider.notifier).retry(),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        },
      ),
    );
  }
}
