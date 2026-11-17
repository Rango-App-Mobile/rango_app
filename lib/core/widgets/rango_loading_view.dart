import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rango_app/core/theme/app_primitives.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/core/widgets/rango_loading_data.dart';
import 'package:rango_app/core/widgets/rango_loading_motion.dart';

/// Full-screen loading: the Figma "00 Loading" xis assembling itself on the
/// pistachio background, so the app opens without a jump from the native
/// splash. With reduced motion it shows the assembled xis, still.
class RangoLoadingView extends StatefulWidget {
  const RangoLoadingView({super.key, this.message});

  /// Optional line under the xis.
  final String? message;

  /// Timeline position of the still frame: everything built, steam drawn.
  @visibleForTesting
  static const stillPosition = 0.88;

  @override
  State<RangoLoadingView> createState() => _RangoLoadingViewState();
}

class _RangoLoadingViewState extends State<RangoLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: loadingDuration,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    final message = widget.message;
    return ColoredBox(
      // The brand green of the native splash, not a theme surface.
      color: AppPrimitives.pistachio,
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Stage(
              position: still ? RangoLoadingView.stillPosition : null,
              animation: _controller,
            ),
            if (message != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: context.textStyles.body.copyWith(
                    color: AppPrimitives.cream,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Visible width of the xis inside the 470 stage, plus breathing room: the
/// stage scales down when the screen is narrower than this.
const _contentWidth = 392.0;

class _Stage extends StatelessWidget {
  const _Stage({required this.animation, this.position});

  final Animation<double> animation;

  /// Fixed timeline position (reduced motion); null follows [animation].
  final double? position;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / _contentWidth).clamp(0.0, 1.0);
        final side = loadingStageSize * scale;
        // The stage is wider than a phone; only its middle has content.
        return SizedBox(
          height: side,
          child: OverflowBox(
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: SizedBox(
              width: side,
              height: side,
              child: FittedBox(
                child: SizedBox(
                  width: loadingStageSize,
                  height: loadingStageSize,
                  child: position != null
                      ? _layers(position!)
                      : AnimatedBuilder(
                          animation: animation,
                          builder: (_, _) => _layers(animation.value),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _layers(double t) => Stack(
    clipBehavior: Clip.none,
    children: [for (final layer in loadingStage) _buildLayer(layer, t)],
  );
}

Widget _buildLayer(LoadingLayer layer, double t) {
  final motion = layer.motion;
  final opacity = motion?.opacity?.at(t) ?? 1;
  if (opacity <= 0) return const SizedBox.shrink();

  Widget content = SizedBox.fromSize(
    size: layer.rect.size,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        if (layer.asset != null)
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/loading/${layer.asset}.svg',
              fit: BoxFit.fill,
            ),
          ),
        if (layer.strokes.isNotEmpty)
          Positioned.fill(
            child: CustomPaint(
              painter: _StrokesPainter(layer.strokes, t),
            ),
          ),
        for (final child in layer.children) _buildLayer(child, t),
      ],
    ),
  );
  if (layer.rotation != 0) {
    content = Transform.rotate(angle: layer.rotation, child: content);
  }
  if (motion != null) {
    // Animated on top of the static tilt, in the parent's axes (the pivot is
    // the layer center, as in the Figma export).
    final matrix =
        Matrix4.translationValues(
            motion.tx?.at(t) ?? 0,
            motion.ty?.at(t) ?? 0,
            0,
          )
          ..rotateZ(motion.rot?.at(t) ?? 0)
          ..scaleByDouble(motion.sx?.at(t) ?? 1, motion.sy?.at(t) ?? 1, 1, 1);
    content = Transform(
      alignment: Alignment.center,
      transform: matrix,
      child: content,
    );
    if (opacity < 1) content = Opacity(opacity: opacity, child: content);
  }
  return Positioned.fromRect(rect: layer.rect, child: content);
}

class _StrokesPainter extends CustomPainter {
  const _StrokesPainter(this.strokes, this.t);

  final List<LoadingStroke> strokes;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      stroke.paint(canvas, t);
    }
  }

  @override
  bool shouldRepaint(_StrokesPainter oldDelegate) => oldDelegate.t != t;
}
