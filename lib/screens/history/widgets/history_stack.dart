import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/resolve_food_theme.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/core/widgets/food_card.dart';
import 'package:rango_app/core/widgets/food_photo.dart';
import 'package:rango_app/core/widgets/history_card_hero.dart';
import 'package:rango_app/core/widgets/progressive_blur.dart';
import 'package:rango_app/screens/history/history_state.dart';
import 'package:rango_app/screens/history/widgets/month_header.dart';

/// The Histórico as a stack of cards, like a wallet, one month after the
/// other: each card covers all but the top strip of the one before it, and the
/// last card of a month shows whole, followed by a pause with the
/// [MonthHeader] of the next month.
///
/// It opens at the bottom (the newest) and scrolls up to the older ones. Inside
/// a month, a card that reaches the top stops there, shrinks a little and piles
/// up behind the newer cards, leaving a thin edge so the pile reads as depth.
/// When the last card of the month arrives it takes the pile with it, whole,
/// out under the top of the list. The label of the month on top stays there
/// until the next label pushes it out, like a section header.
class HistoryStack extends StatefulWidget {
  const HistoryStack({
    required this.items,
    required this.months,
    required this.onOpen,
    this.bottomInset = 0,
    super.key,
  });

  /// From the oldest to the newest.
  final List<HistoryItem> items;

  /// The months of [items], in the same order.
  final List<HistoryMonth> months;

  /// Tap on a card: open that decision.
  final ValueChanged<HistoryItem> onOpen;

  /// Room left free at the bottom, for the floating Tab Bar.
  final double bottomInset;

  /// Visible part of a card under the next one: title, restaurant and date.
  static const stripHeight = 84.0;

  /// Where the pile of older cards rests, from the top of the list: below the
  /// month label and the edges of the pile.
  static const pileTop = 56.0;

  /// Edge of each card that peeks out above the next one in the pile.
  static const pileStep = 6.0;

  /// Cards in the pile with a visible edge; the ones further back are hidden
  /// behind them and are not drawn.
  static const pileDepth = 3;

  /// How much smaller each card further back in the pile is.
  static const scaleStep = 0.04;

  /// Free room around a month label between two months (Figma: 12).
  static const monthGap = 12.0;

  @override
  State<HistoryStack> createState() => _HistoryStackState();
}

class _HistoryStackState extends State<HistoryStack> {
  final _controller = ScrollController();
  final GlobalKey _sizerKey = GlobalKey();

  static const _veilBlurBands = 5;
  static const _veilBlurSigma = 6.0;

  /// Solid behind the label, then eased out: a straight fade shows where it
  /// ends, as a line across the card passing under it.
  static const List<double> _veilFade = [1.0, 1.0, 0.62, 0.26, 0.07, 0.0];
  static const List<double> _veilStops = [
    0.0,
    MonthHeader.height / HistoryStack.pileTop,
    0.6,
    0.75,
    0.88,
    1.0,
  ];

  /// Height of a whole card, measured on the invisible sizer: it depends on
  /// the width and the text scale. Null until the first layout.
  double? _cardHeight;

  /// Whether the scroll extent already counts [_cardHeight]: the cards are
  /// placed from it, so they wait for it instead of flashing in the wrong spot.
  bool _laidOut = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _measureCard() {
    final sizer = _sizerKey.currentContext?.findRenderObject();
    if (sizer is! RenderBox || !sizer.hasSize) return;
    if (sizer.size.height == _cardHeight) return;
    setState(() => _cardHeight = sizer.size.height);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _laidOut = true);
    });
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

  /// Where each card sits in the list before anything piles up: one strip
  /// after the other, and where a month starts, the whole card that ended the
  /// last one plus a pause for the label.
  List<double> _cardTops(double cardHeight) {
    final monthStarts = {for (final month in widget.months) month.firstIndex};
    final tops = <double>[];
    var top = HistoryStack.pileTop;
    for (var i = 0; i < widget.items.length; i++) {
      if (i > 0) {
        top += monthStarts.contains(i)
            ? cardHeight + HistoryStack.monthGap * 2 + MonthHeader.height
            : HistoryStack.stripHeight;
      }
      tops.add(top);
    }
    return tops;
  }

  /// Which card has reached the pile, as a fraction: 2.5 is halfway from the
  /// third card to the fourth.
  double _pileFront(List<double> tops, double scrolled) {
    final anchor = HistoryStack.pileTop + scrolled;
    for (var i = 0; i < tops.length - 1; i++) {
      if (anchor < tops[i + 1]) {
        return i + math.max(0, anchor - tops[i]) / (tops[i + 1] - tops[i]);
      }
    }
    return tops.length - 1 + (anchor - tops.last) / HistoryStack.stripHeight;
  }

  /// The month label on its way up, from the top of the list.
  double _labelTop(List<double> tops, HistoryMonth month, double scrolled) =>
      tops[month.firstIndex] -
      HistoryStack.monthGap -
      MonthHeader.height -
      scrolled;

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

  List<Widget> _placedCards(
    List<double> tops,
    double scrolled,
    double cardHeight,
  ) {
    final front = _pileFront(tops, scrolled);
    final months = widget.months;
    final cards = <Widget>[];
    for (var m = 0; m < months.length; m++) {
      final first = months[m].firstIndex;
      final last = m + 1 < months.length
          ? months[m + 1].firstIndex - 1
          : widget.items.length - 1;
      // The last card of the month takes the pile with it as it leaves.
      final carried = math.min(
        0,
        tops[last] - scrolled - HistoryStack.pileTop,
      );

      for (var i = first; i <= last; i++) {
        // Stops at the month's last card, which never piles: it stays whole.
        final past = math.max(0, math.min(front, last.toDouble()) - i);
        if (past > HistoryStack.pileDepth + 1) continue;

        final depth = math.min(past, HistoryStack.pileDepth).toDouble();
        final top = past > 0
            ? HistoryStack.pileTop - depth * HistoryStack.pileStep + carried
            : tops[i] - scrolled;
        if (top + cardHeight < 0) continue;

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
    }
    return cards;
  }

  /// The label of the month on top, pushed out by the next one, and the labels
  /// still on their way up.
  List<Widget> _placedLabels(List<double> tops, double scrolled) {
    final months = widget.months;

    var current = 0;
    for (var i = 1; i < months.length; i++) {
      if (_labelTop(tops, months[i], scrolled) <= 0) current = i;
    }

    double pinnedTop() {
      if (current + 1 == months.length) return 0;
      final next = _labelTop(tops, months[current + 1], scrolled);
      return math.min(0, next - MonthHeader.height - HistoryStack.monthGap);
    }

    Widget placed(HistoryMonth month, double top) => Positioned(
      top: top + scrolled,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.centerLeft,
          child: MonthHeader(label: month.label, count: month.countLabel),
        ),
      ),
    );

    return [
      placed(months[current], pinnedTop()),
      for (final month in months.skip(current + 1))
        placed(month, _labelTop(tops, month, scrolled)),
    ];
  }

  /// Cards leave under the top of the list: this hides them behind the label
  /// and blurs them out on the way, instead of cutting them in a straight line.
  Widget _placedVeil(double scrolled) {
    final canvas = context.colors.bgCanvas;
    return Positioned(
      top: scrolled,
      left: 0,
      right: 0,
      height: HistoryStack.pileTop,
      child: IgnorePointer(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ProgressiveBlur(
              edge: ProgressiveBlurEdge.top,
              bandCount: _veilBlurBands,
              sigmaAtEdge: _veilBlurSigma,
              tintAtEdge: 0,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    for (final alpha in _veilFade)
                      canvas.withValues(alpha: alpha),
                  ],
                  stops: _veilStops,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final cardHeight = _cardHeight;
    final tops = _cardTops(cardHeight ?? HistoryStack.stripHeight);
    // The sizer changes with the width and the text scale.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _measureCard();
    });
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        controller: _controller,
        reverse: true,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Sizes the scroll extent: the strips, whole cards and labels of
              // the older months, then the newest card whole. The cards
              // themselves are drawn above it.
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: tops.last),
                  Visibility(
                    visible: false,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: KeyedSubtree(
                      key: _sizerKey,
                      child: _card(items.last),
                    ),
                  ),
                  SizedBox(height: widget.bottomInset),
                ],
              ),
              if (cardHeight != null && _laidOut)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final scrolled = _scrolledPast;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ..._placedCards(tops, scrolled, cardHeight),
                          _placedVeil(scrolled),
                          ..._placedLabels(tops, scrolled),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
