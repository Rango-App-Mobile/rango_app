import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';

/// Story-style bar: finished pages are full, the current one fills along its
/// own timeline ([clock]) and the next ones are empty.
class OnboardingProgress extends StatelessWidget {
  const OnboardingProgress({
    required this.page,
    required this.pageCount,
    required this.clock,
    super.key,
  });

  final int page;
  final int pageCount;
  final AnimationController clock;

  static const _segmentWidth = 56.0;
  static const _segmentHeight = 6.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: 'Passo ${page + 1} de $pageCount',
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: clock,
        builder: (context, _) => Row(
          spacing: AppSpace.xxs + 2,
          children: [
            for (var i = 0; i < pageCount; i++)
              SizedBox(
                width: _segmentWidth,
                height: _segmentHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.borderDefault,
                    borderRadius: BorderRadius.circular(_segmentHeight / 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(_segmentHeight / 2),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        heightFactor: 1,
                        widthFactor: i < page
                            ? 1
                            : i == page
                            ? clock.value
                            : 0,
                        child: ColoredBox(color: colors.textPrimary),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
