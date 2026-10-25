import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/app/router.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/screens/startup/startup_screen.dart';
import 'package:rango_app/screens/startup/startup_view_model.dart';

class RangoApp extends ConsumerWidget {
  const RangoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReady = ref.watch(startupViewModelProvider).hasValue;

    return MaterialApp.router(
      title: 'Rango',
      theme: AppTheme.light,
      routerConfig: ref.watch(routerProvider),
      // The whole app waits for the anonymous session (guest mode): nothing
      // behind it may run without a Firebase user.
      builder: (context, child) =>
          isReady && child != null ? child : const StartupScreen(),
    );
  }
}
