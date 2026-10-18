import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/core/widgets/page_header.dart';
import 'package:rango_app/core/widgets/rango_button.dart';
import 'package:rango_app/core/widgets/rango_icon_button.dart';
import 'package:rango_app/models/food_category.dart';
import 'package:rango_app/screens/swipe/swipe_state.dart';
import 'package:rango_app/screens/swipe/swipe_view_model.dart';
import 'package:rango_app/screens/swipe/widgets/swipe_choice_cards.dart';
import 'package:rango_app/screens/swipe/widgets/swipe_result.dart';

/// Binary-choice screen: two tilted cards, tap or drag one to pick it.
class SwipeScreen extends ConsumerWidget {
  const SwipeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(swipeViewModelProvider);
    // Read at call time: invalidating the provider replaces the notifier.
    SwipeViewModel viewModel() => ref.read(swipeViewModelProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: session.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _LoadError(
            onRetry: () => ref.invalidate(swipeViewModelProvider),
          ),
          data: (state) => _SwipeContent(
            state: state,
            onUndo: () => viewModel().undo(),
            onChoose: (option) => viewModel().choose(option),
            onReset: () => viewModel().reset(),
          ),
        ),
      ),
    );
  }
}

class _SwipeContent extends StatelessWidget {
  const _SwipeContent({
    required this.state,
    required this.onUndo,
    required this.onChoose,
    required this.onReset,
  });

  final SwipeState state;
  final VoidCallback onUndo;
  final ValueChanged<FoodCategory> onChoose;
  final VoidCallback onReset;

  /// Height of the Icon Button, reserved even when Voltar is hidden.
  static const _backButtonSlot = 48.0;

  @override
  Widget build(BuildContext context) {
    final result = state.result;
    final header = result == null
        ? PageHeader(title: state.title, subtitle: state.subtitle)
        : PageHeader(
            title: 'Agora é só escolher onde.',
            subtitle:
                'Vamos buscar restaurantes que servem '
                '${result.label.toLowerCase()} perto de você.',
            size: PageHeaderSize.medium,
          );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpace.md,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
            // Fixed height so the header does not jump when Voltar appears.
            child: SizedBox(
              height: _backButtonSlot,
              child: Align(
                alignment: Alignment.centerLeft,
                child: state.canUndo
                    ? RangoIconButton(
                        icon: Icons.arrow_back,
                        semanticLabel: 'Voltar',
                        onPressed: onUndo,
                      )
                    : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
            child: header,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
            child: switch ((result, state.options)) {
              (final result?, _) => SwipeResult(
                result: result,
                history: state.history,
                onRestart: onReset,
              ),
              (null, [final first, final second]) => Center(
                child: SwipeChoiceCards(
                  key: ValueKey(state.current.id),
                  first: first,
                  second: second,
                  onChosen: onChoose,
                ),
              ),
              _ => const SizedBox.shrink(),
            },
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
              'Não deu para carregar as opções.',
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
