import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';

/// Title, subtitle and the illustration of one onboarding page. The text
/// slides in once when the page appears; the illustration is animated by its
/// own page, from the shared clock.
class OnboardingPageFrame extends StatelessWidget {
  const OnboardingPageFrame({
    required this.title,
    required this.subtitle,
    required this.art,
    required this.artSize,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget art;

  /// Design size of [art]; it scales down on a small screen.
  final Size artSize;

  static const _slide = 22.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpace.lg),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: reduceMotion ? 1 : 0, end: 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * _slide),
                child: child,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpace.xs,
              children: [
                Text(
                  title,
                  style: text.displayMedium.copyWith(color: colors.textPrimary),
                ),
                Text(
                  subtitle,
                  style: text.body.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          Expanded(
            // Decorative: the title and subtitle already say it.
            child: ExcludeSemantics(
              child: Center(
                child: FittedBox(
                  child: SizedBox.fromSize(size: artSize, child: art),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
