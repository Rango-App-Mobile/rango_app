import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/theme_context.dart';

/// The edge of the screen a [ProgressiveBlur] grows towards.
enum ProgressiveBlurEdge { top, bottom }

/// Blur that grows towards an edge of the screen, for content passing behind
/// the Top Bar or the Tab Bar (Figma: background blur, progressive, radius 26).
///
/// A `BackdropFilter` cannot be masked with a gradient, so it is built from
/// overlapping bands whose blur adds up, each one shorter and stronger than the
/// last, under a fading canvas tint that hides the steps and keeps what floats
/// on it legible. Ignores pointers: taps reach the content behind it.
class ProgressiveBlur extends StatelessWidget {
  const ProgressiveBlur({
    required this.edge,
    this.bandCount = 12,
    this.sigmaAtEdge = 13,
    this.tintAtEdge = 0.7,
    super.key,
  });

  final ProgressiveBlurEdge edge;

  /// Fewer bands are enough for a short blur, and cost less to draw.
  final int bandCount;

  /// Figma's radius 26 is a sigma of 13.
  final double sigmaAtEdge;

  /// Opacity of the canvas tint at the edge. Zero when something else over the
  /// blur already fades to the canvas.
  final double tintAtEdge;

  /// Widest first. Blurs add up in quadrature, so these sigmas make the total
  /// grow in even steps towards the edge: a big step would show as a stair on
  /// any vertical edge passing behind the blur.
  List<({double heightFactor, double sigma})> get _bands => [
    for (var i = 0; i < bandCount; i++)
      (
        heightFactor: 1 - i / bandCount,
        sigma: sigmaAtEdge * math.sqrt(2 * i + 1) / bandCount,
      ),
  ];

  @override
  Widget build(BuildContext context) {
    final canvas = context.colors.bgCanvas;
    final (edgeAlignment, innerAlignment) = switch (edge) {
      ProgressiveBlurEdge.top => (Alignment.topCenter, Alignment.bottomCenter),
      ProgressiveBlurEdge.bottom => (
        Alignment.bottomCenter,
        Alignment.topCenter,
      ),
    };

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          for (final band in _bands)
            Align(
              alignment: edgeAlignment,
              child: FractionallySizedBox(
                heightFactor: band.heightFactor,
                widthFactor: 1,
                child: ClipRect(
                  child: BackdropFilter(
                    key: const Key('progressive-blur-band'),
                    filter: ImageFilter.blur(
                      sigmaX: band.sigma,
                      sigmaY: band.sigma,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: edgeAlignment,
                end: innerAlignment,
                colors: [
                  canvas.withValues(alpha: tintAtEdge),
                  canvas.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
