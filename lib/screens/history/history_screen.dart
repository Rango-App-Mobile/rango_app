import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/core/widgets/empty_card.dart';
import 'package:rango_app/core/widgets/page_header.dart';
import 'package:rango_app/core/widgets/rango_button.dart';
import 'package:rango_app/core/widgets/rango_tab_bar.dart';
import 'package:rango_app/core/widgets/top_bar.dart';

/// Histórico tab, empty state (Figma "10 Histórico vazio").
///
/// Static for now: there is no ViewModel until story #60 brings the data.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  /// Figma shows a compact card here, not the 392 default of [EmptyCard].
  static const _emptyCardHeight = 232.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Profile Sheet is story #64.
            const TopBar.principal(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.lg,
                  0,
                  AppSpace.lg,
                  RangoTabBar.reservedHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpace.lg,
                  children: [
                    const PageHeader(title: 'Seu histórico'),
                    const EmptyCard(
                      label: 'Seu primeiro rango',
                      height: _emptyCardHeight,
                    ),
                    Text(
                      'Cada decisão aparece aqui, com a comida e o '
                      'restaurante que você escolheu.',
                      textAlign: TextAlign.center,
                      style: context.textStyles.body.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    RangoButton(
                      label: 'Decidir meu rango',
                      expand: true,
                      onPressed: () => context.go('/home'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
