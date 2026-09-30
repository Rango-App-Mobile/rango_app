import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/app/router.dart';
import 'package:rango_app/app/theme/app_theme.dart';

class RangoApp extends ConsumerWidget {
  const RangoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Rango',
      theme: AppTheme.light,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
