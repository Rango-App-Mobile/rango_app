import 'dart:ui';

import 'package:flutter/animation.dart';

/// A Figma easing exported as `linear(...)`: evenly spaced samples, linearly
/// interpolated. Springs overshoot, so values may leave 0..1.
class SampledCurve extends Curve {
  const SampledCurve(this.samples);

  final List<double> samples;

  @override
  double transformInternal(double t) {
    final x = t * (samples.length - 1);
    final i = x.floor().clamp(0, samples.length - 2);
    return lerpDouble(samples[i], samples[i + 1], x - i)!;
  }
}

/// Keyframes `(t, value, curve)` with `t` in 0..1. The curve eases the
/// segment that starts at that key, like CSS `animation-timing-function`.
class Track {
  const Track(this.keys);

  final List<(double, double, Curve)> keys;

  double at(double t) {
    if (t <= keys.first.$1) return keys.first.$2;
    for (var i = 0; i < keys.length - 1; i++) {
      final (t0, v0, curve) = keys[i];
      final (t1, v1, _) = keys[i + 1];
      if (t < t1) {
        return lerpDouble(v0, v1, curve.transform((t - t0) / (t1 - t0)))!;
      }
    }
    return keys.last.$2;
  }
}

/// Animated properties of a layer. Translation is in stage pixels, scale and
/// rotation (radians) pivot on the layer's center, in the parent's axes.
class LayerMotion {
  const LayerMotion({
    this.tx,
    this.ty,
    this.sx,
    this.sy,
    this.rot,
    this.opacity,
  });

  final Track? tx;
  final Track? ty;
  final Track? sx;
  final Track? sy;
  final Track? rot;
  final Track? opacity;
}

/// A stroked path that draws on and off (Figma path-trim, `pathLength=1`
/// semantics: dash length `dash`, dash offset `offset`, both 0..1).
class LoadingStroke {
  LoadingStroke({
    required String d,
    required this.rect,
    required this.size,
    required this.width,
    required this.color,
    required this.dash,
    required this.offset,
    this.roundJoin = false,
  }) : path = _parse(d);

  /// Where the source SVG sits in the layer, and its own size.
  final Rect rect;
  final Size size;
  final double width;
  final Color color;
  final bool roundJoin;
  final Track dash;
  final Track offset;
  final Path path;

  late final PathMetric _metric = path.computeMetrics().first;

  /// Draws the visible part of the path at timeline position [t].
  void paint(Canvas canvas, double t) {
    final d = dash.at(t);
    if (d <= 0) return;
    final start = (-offset.at(t)).clamp(0.0, 1.0);
    final end = (start + d).clamp(0.0, 1.0);
    if (end <= start) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = roundJoin ? StrokeJoin.round : StrokeJoin.miter
      ..color = color;
    final visible = start <= 0 && end >= 1
        ? path
        : _metric.extractPath(start * _metric.length, end * _metric.length);
    canvas
      ..save()
      ..translate(rect.left, rect.top)
      ..scale(rect.width / size.width, rect.height / size.height)
      ..drawPath(visible, paint)
      ..restore();
  }

  /// Absolute `M` and `C` commands only, which is all the exported SVGs use.
  static Path _parse(String d) {
    final path = Path();
    final tokens = RegExp(r'[MC]|-?\d*\.?\d+(?:e-?\d+)?').allMatches(d);
    final args = <double>[];
    var command = '';
    void flush() {
      if (command == 'M' && args.length == 2) {
        path.moveTo(args[0], args[1]);
      } else if (command == 'C' && args.length == 6) {
        path.cubicTo(args[0], args[1], args[2], args[3], args[4], args[5]);
      } else {
        return;
      }
      args.clear();
    }

    for (final token in tokens) {
      final text = token.group(0)!;
      if (text == 'M' || text == 'C') {
        command = text;
      } else {
        args.add(double.parse(text));
        flush();
      }
    }
    return path;
  }
}

/// One drawable of the stage. [rect] is the unrotated box in the parent's
/// coordinates; [rotation] is the static tilt from the design, [motion] what
/// the timeline animates on top of it.
class LoadingLayer {
  LoadingLayer({
    required this.rect,
    this.asset,
    this.rotation = 0,
    this.motion,
    this.strokes = const [],
    this.children = const [],
  });

  final Rect rect;
  final String? asset;
  final double rotation;
  final LayerMotion? motion;
  final List<LoadingStroke> strokes;
  final List<LoadingLayer> children;
}
