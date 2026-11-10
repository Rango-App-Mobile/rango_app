import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/core/widgets/empty_card.dart';
import 'package:rango_app/core/widgets/page_header.dart';
import 'package:rango_app/core/widgets/rango_button.dart';
import 'package:rango_app/core/widgets/rango_tab_bar.dart';
import 'package:rango_app/core/widgets/top_bar.dart';
import 'package:rango_app/core/widgets/top_bar_layout.dart';
import 'package:rango_app/core/widgets/top_bar_scroll_view.dart';
import 'package:rango_app/screens/history/history_state.dart';
import 'package:rango_app/screens/history/history_view_model.dart';
import 'package:rango_app/screens/history/widgets/history_stack.dart';
import 'package:rango_app/screens/profile/profile_sheet.dart';

/// Histórico tab: the user's decisions as a stack of cards, the newest in
/// front (Figma "07d Histórico"), or the empty state ("10 Histórico vazio").
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyViewModelProvider);
    return Scaffold(
      body: TopBarLayout(
        topBar: TopBar.principal(
          onProfile: () => unawaited(showProfileSheet(context)),
        ),
        body: switch (history) {
          AsyncData(:final value) when value.isEmpty => const _Empty(),
          AsyncData(:final value) => SafeArea(
            bottom: false,
            child: _Stack(state: value),
          ),
          AsyncError() => SafeArea(
            bottom: false,
            child: _LoadError(
              onRetry: () => ref.invalidate(historyViewModelProvider),
            ),
          ),
          _ => const SafeArea(
            bottom: false,
            child: Center(child: CircularProgressIndicator()),
          ),
        },
      ),
    );
  }
}

class _Stack extends StatelessWidget {
  const _Stack({required this.state});

  final HistoryState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpace.md,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpace.lg),
          child: PageHeader(title: 'Seu histórico'),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
            child: HistoryStack(
              items: state.items,
              months: state.months,
              bottomInset: RangoTabBar.reservedHeight,
              onOpen: (item) =>
                  unawaited(context.push('/history/${item.entry.id}')),
            ),
          ),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  /// Figma shows a compact card here, not the 392 default of [EmptyCard].
  static const _emptyCardHeight = 232.0;

  @override
  Widget build(BuildContext context) {
    return TopBarScrollView(
      safeBottom: false,
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
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpace.md,
          children: [
            Text(
              'Não deu para carregar seu histórico.',
              textAlign: TextAlign.center,
              style: context.textStyles.body.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            RangoButton(label: 'Tentar novamente', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
