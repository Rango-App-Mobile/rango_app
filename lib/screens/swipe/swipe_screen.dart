import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/core/widgets/page_header.dart';
import 'package:rango_app/core/widgets/rango_button.dart';
import 'package:rango_app/core/widgets/rango_tab_bar.dart';
import 'package:rango_app/core/widgets/top_bar.dart';
import 'package:rango_app/models/food_category.dart';
import 'package:rango_app/models/like_state.dart';
import 'package:rango_app/screens/swipe/swipe_state.dart';
import 'package:rango_app/screens/swipe/swipe_view_model.dart';
import 'package:rango_app/screens/swipe/widgets/food_card_deck.dart';
import 'package:rango_app/screens/swipe/widgets/like_meter.dart';
import 'package:rango_app/screens/swipe/widgets/swipe_button.dart';
import 'package:rango_app/screens/swipe/widgets/swipe_choice_cards.dart';

/// Where the swipe screen lives, which decides its chrome.
enum SwipeMode {
  /// Home tab, level 1: Top Bar Principal and room for the floating Tab Bar.
  root,

  /// Levels 2+: full screen, Top Bar Flow. Voltar leaves the whole flow.
  flow,
}

/// The decision screen. At the root: two tilted cards (Salgado or Doce), tap
/// or drag one to pick it. Then: one card at a time, swipe right to like or
/// left to pass, until a food gets enough likes.
class SwipeScreen extends ConsumerWidget {
  const SwipeScreen({this.mode = SwipeMode.root, super.key});

  final SwipeMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(swipeViewModelProvider);
    // Read at call time: invalidating the provider replaces the notifier.
    SwipeViewModel viewModel() => ref.read(swipeViewModelProvider.notifier);
    final isFlow = mode == SwipeMode.flow;

    // The root and the flow screen are both mounted and hear the same
    // provider: only the one on top may navigate.
    ref.listen(swipeViewModelProvider, (previous, next) {
      final state = next.value;
      if (state == null || !state.hasConverged) return;
      if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;

      final path = state.history.map((c) => c.id).join(',');
      final location = '/result?path=$path';
      if (isFlow) {
        context.pushReplacement(location);
      } else {
        unawaited(context.push(location));
      }
      viewModel().reset();
    });

    void exit() {
      viewModel().reset();
      context.pop();
    }

    void onChoose(FoodCategory option) {
      viewModel().choose(option);
      final next = ref.read(swipeViewModelProvider).value;
      if (!isFlow && next != null && !next.hasConverged) {
        unawaited(context.push('/choose'));
      }
    }

    final body = Scaffold(
      body: SafeArea(
        bottom: isFlow,
        child: Column(
          children: [
            if (isFlow) TopBar.flow(onBack: exit) else const TopBar.principal(),
            Expanded(
              child: session.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _LoadError(
                  onRetry: () => ref.invalidate(swipeViewModelProvider),
                ),
                data: (state) => switch (state.game) {
                  null => _SwipeContent(
                    state: state,
                    bottomInset: isFlow ? 0 : RangoTabBar.reservedHeight,
                    onChoose: onChoose,
                  ),
                  final game => _DeckContent(
                    game: game,
                    swipeCount: state.history.length,
                    onLike: () => viewModel().like(),
                    onPass: () => viewModel().pass(),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (!isFlow) return body;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) exit();
      },
      child: body,
    );
  }
}

class _SwipeContent extends StatelessWidget {
  const _SwipeContent({
    required this.state,
    required this.bottomInset,
    required this.onChoose,
  });

  final SwipeState state;
  final double bottomInset;
  final ValueChanged<FoodCategory> onChoose;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpace.md,
        children: [
          if (state.title case final title?)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
              child: PageHeader(title: title, subtitle: state.subtitle),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
            child: switch (state.options) {
              [final first, final second] => Center(
                child: SwipeChoiceCards(
                  key: ValueKey(state.history.length),
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

/// The single-card game, nothing else (Figma "02 Card único"): the likes of
/// the food on top, the deck and the two buttons that do what the swipe does.
class _DeckContent extends StatelessWidget {
  const _DeckContent({
    required this.game,
    required this.swipeCount,
    required this.onLike,
    required this.onPass,
  });

  final LikeState game;
  final int swipeCount;
  final VoidCallback onLike;
  final VoidCallback onPass;

  @override
  Widget build(BuildContext context) {
    final food = game.current;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.lg,
        0,
        AppSpace.lg,
        AppSpace.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpace.sm,
        children: [
          Center(
            child: LikeMeter(
              likes: game.likesOf(food),
              total: game.likesToMatch,
            ),
          ),
          // Loose, so the buttons sit right under the card and the spare
          // room stays at the bottom; the deck only shrinks when it must.
          Flexible(
            child: FoodCardDeck(
              current: food,
              next: game.next,
              swipeCount: swipeCount,
              onLike: onLike,
              onPass: onPass,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: AppSpace.lg,
            children: [
              SwipeButton(
                action: SwipeAction.pass,
                foodLabel: food.label,
                onPressed: onPass,
              ),
              SwipeButton(
                action: SwipeAction.like,
                foodLabel: food.label,
                onPressed: onLike,
              ),
            ],
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
