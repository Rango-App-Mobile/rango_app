import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/resolve_food_theme.dart';
import 'package:rango_app/core/widgets/food_card.dart';
import 'package:rango_app/core/widgets/food_photo.dart';
import 'package:rango_app/core/widgets/history_card_hero.dart';
import 'package:rango_app/screens/history/history_state.dart';

/// The Histórico as a stack of cards, like a wallet: each card hides all but
/// the top strip of the one before it, and the newest one, at the bottom, is
/// drawn whole and in front.
///
/// It opens at the bottom (the newest) and scrolls up to the older ones. A
/// card that reaches the top does not leave the screen: it stops there,
/// shrinks a little and piles up behind the newer cards, leaving a thin edge
/// so the pile reads as depth.
class HistoryStack extends StatefulWidget {
  const HistoryStack({
    required this.items,
    required this.onOpen,
    this.bottomInset = 0,
    super.key,
  });

  /// From the oldest to the newest.
  final List<HistoryItem> items;

  /// Tap on a card: open that decision.
  final ValueChanged<HistoryItem> onOpen;

  /// Room left free at the bottom, for the floating Tab Bar.
  final double bottomInset;

  /// Visible part of a card under the next one: title, restaurant and date.
  static const stripHeight = 84.0;

  /// Where the pile of older cards rests, from the top of the list.
  static const pileTop = 20.0;

  /// Edge of each card that peeks out above the next one in the pile.
  static const pileStep = 6.0;

  /// Cards in the pile with a visible edge; the ones further back are hidden
  /// behind them and are not drawn.
  static const pileDepth = 3;

  /// How much smaller each card further back in the pile is.
  static const scaleStep = 0.04;

  @override
  State<HistoryStack> createState() => _HistoryStackState();
}

class _HistoryStackState extends State<HistoryStack> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    // The pile depends on the scroll extent, known only after the first
    // layout: draw once more with it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// How far the top of the list is scrolled past, in content pixels. The
  /// scroll view is reversed (it opens at the bottom), so offset 0 is the
  /// whole extent.
  double get _scrolledPast {
    if (!_controller.hasClients) return 0;
    final position = _controller.position;
    if (!position.hasContentDimensions) return 0;
    return position.maxScrollExtent - position.pixels;
  }

  Widget _card(HistoryItem item) => FoodCard(
    title: item.food.label,
    subtitle: item.entry.restaurantName,
    chipLabel: item.dateLabel,
    foodTheme: resolveFoodTheme(item.food.foodTheme),
    photo: foodPhoto(item.food.photo),
    photoLabel: 'Foto: ${item.food.label.toLowerCase()}',
    // A second title line would push the restaurant and the date under
    // the next card.
    titleMaxLines: 1,
  );

  /// The card that flies into the detail screen when tapped. Only the drawn
  /// cards are heroes: the invisible sizer would repeat the newest one's tag.
  Widget _openable(HistoryItem item) => Semantics(
    button: true,
    onTapHint: 'abrir',
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onOpen(item),
      child: HistoryCardHero(entryId: item.entry.id, child: _card(item)),
    ),
  );

  List<Widget> _placedCards() {
    final scrolled = _scrolledPast;
    final cards = <Widget>[];
    for (var i = 0; i < widget.items.length; i++) {
      // The list starts at the pile, so at the top no card is piled yet.
      final onScreen =
          HistoryStack.pileTop + i * HistoryStack.stripHeight - scrolled;
      final past = onScreen < HistoryStack.pileTop
          ? (HistoryStack.pileTop - onScreen) / HistoryStack.stripHeight
          : 0.0;
      if (past > HistoryStack.pileDepth + 1) continue;

      final depth = math.min(past, HistoryStack.pileDepth.toDouble());
      final top = past > 0
          ? HistoryStack.pileTop - depth * HistoryStack.pileStep
          : onScreen;
      cards.add(
        Positioned(
          // Back to content coordinates: the whole stack scrolls.
          top: top + scrolled,
          left: 0,
          right: 0,
          child: Transform.scale(
            scale: 1 - depth * HistoryStack.scaleStep,
            alignment: Alignment.topCenter,
            child: _openable(widget.items[i]),
          ),
        ),
      );
    }
    return cards;
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        controller: _controller,
        reverse: true,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Sizes the scroll extent: one strip per older card, then the
              // newest card whole. The cards themselves are drawn above it.
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height:
                        HistoryStack.pileTop +
                        (items.length - 1) * HistoryStack.stripHeight,
                  ),
                  Visibility(
                    visible: false,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: _card(items.last),
                  ),
                  SizedBox(height: widget.bottomInset),
                ],
              ),
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) =>
                      Stack(clipBehavior: Clip.none, children: _placedCards()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
