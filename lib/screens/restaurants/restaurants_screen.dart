import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/widgets/empty_state.dart';
import 'package:rango_app/core/widgets/rango_button.dart';
import 'package:rango_app/core/widgets/top_bar.dart';

/// Placeholder for the restaurants map, which story #17 replaces.
///
/// [categoryId] (the leaf category id from the query string, may be null) is
/// already kept so the `/restaurants?category=<id>` route contract is final.
/// There is no ViewModel on purpose: nothing to manage yet.
class RestaurantsScreen extends StatelessWidget {
  const RestaurantsScreen({required this.categoryId, super.key});

  final String? categoryId;

  @override
  Widget build(BuildContext context) {
    void goHome() => context.go('/home');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) goHome();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              TopBar.flow(onBack: goHome),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.lg,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: AppSpace.lg,
                      children: [
                        const EmptyState(
                          icon: Icons.map_outlined,
                          title: 'Restaurantes em breve',
                          message:
                              'Logo aqui você vai ver no mapa os lugares '
                              'perto que servem o que você escolheu.',
                        ),
                        RangoButton(
                          label: 'Voltar ao início',
                          style: RangoButtonStyle.secondary,
                          onPressed: goHome,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
