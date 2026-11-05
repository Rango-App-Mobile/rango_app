import 'package:flutter/material.dart';
import 'package:rango_app/core/widgets/progressive_blur.dart';
import 'package:rango_app/core/widgets/top_bar.dart';

/// A screen whose [body] runs under the status bar and the [topBar], which
/// float over it on a progressive blur (Figma `Top Bar`, layer `Glass`).
///
/// The [body] gets the height they cover as `MediaQuery.padding.top`, the same
/// deal as `Scaffold.extendBodyBehindAppBar`: scrolling content uses
/// `TopBarScrollView`, anything fixed goes in a `SafeArea`.
class TopBarLayout extends StatelessWidget {
  const TopBarLayout({required this.topBar, required this.body, super.key});

  final Widget topBar;
  final Widget body;

  /// A title at rest sits right below the bar and the accents of its tall
  /// letters rise above its line: the blur stops short so they stay sharp.
  static const _blurEndsAboveBarBottom = 6.0;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final barBottom = media.padding.top + TopBar.height;

    return Stack(
      fit: StackFit.expand,
      children: [
        MediaQuery(
          data: media.copyWith(padding: media.padding.copyWith(top: barBottom)),
          child: body,
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: barBottom - _blurEndsAboveBarBottom,
          child: const ProgressiveBlur(edge: ProgressiveBlurEdge.top),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(bottom: false, child: topBar),
        ),
      ],
    );
  }
}
