import 'package:flutter/material.dart';

/// The 13 Figma text styles. No color: text takes `color/text/*` from where it
/// is drawn (the theme default, or `food-card/on` inside a Food Card).
@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({
    required this.brandLogo,
    required this.displayLarge,
    required this.displayMedium,
    required this.cardTitleLarge,
    required this.cardTitleMedium,
    required this.cardTitleSmall,
    required this.heading,
    required this.body,
    required this.bodyStrong,
    required this.label,
    required this.caption,
    required this.chip,
    required this.tab,
  });

  /// Family names declared in `pubspec.yaml`.
  static const aleo = 'Aleo';
  static const bowlbyOne = 'BowlbyOne';
  static const lobster = 'Lobster';

  static final standard = AppTextStyles(
    brandLogo: _style(lobster, FontWeight.w400, 40, 48),
    displayLarge: _style(bowlbyOne, FontWeight.w400, 40, 44, tracking: -1),
    displayMedium: _style(bowlbyOne, FontWeight.w400, 30, 34, tracking: -0.5),
    cardTitleLarge: _style(bowlbyOne, FontWeight.w400, 34, 36, tracking: -1),
    cardTitleMedium: _style(bowlbyOne, FontWeight.w400, 24, 26, tracking: -0.5),
    cardTitleSmall: _style(bowlbyOne, FontWeight.w400, 18, 20),
    heading: _style(aleo, FontWeight.w700, 20, 26),
    body: _style(aleo, FontWeight.w400, 16, 24),
    bodyStrong: _style(aleo, FontWeight.w600, 16, 24),
    label: _style(aleo, FontWeight.w600, 14, 18),
    caption: _style(aleo, FontWeight.w400, 12, 16),
    chip: _style(aleo, FontWeight.w600, 11, 14, tracking: 1),
    tab: _style(aleo, FontWeight.w600, 10, 12),
  );

  final TextStyle brandLogo;
  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle cardTitleLarge;
  final TextStyle cardTitleMedium;
  final TextStyle cardTitleSmall;
  final TextStyle heading;
  final TextStyle body;
  final TextStyle bodyStrong;
  final TextStyle label;
  final TextStyle caption;
  final TextStyle chip;
  final TextStyle tab;

  /// Figma gives line height in pixels and tracking in percent of the size;
  /// Flutter wants a height multiplier and letter spacing in pixels.
  static TextStyle _style(
    String family,
    FontWeight weight,
    double size,
    double lineHeight, {
    double tracking = 0,
  }) {
    return TextStyle(
      fontFamily: family,
      fontWeight: weight,
      fontSize: size,
      height: lineHeight / size,
      letterSpacing: size * tracking / 100,
    );
  }

  @override
  AppTextStyles copyWith({
    TextStyle? brandLogo,
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? cardTitleLarge,
    TextStyle? cardTitleMedium,
    TextStyle? cardTitleSmall,
    TextStyle? heading,
    TextStyle? body,
    TextStyle? bodyStrong,
    TextStyle? label,
    TextStyle? caption,
    TextStyle? chip,
    TextStyle? tab,
  }) {
    return AppTextStyles(
      brandLogo: brandLogo ?? this.brandLogo,
      displayLarge: displayLarge ?? this.displayLarge,
      displayMedium: displayMedium ?? this.displayMedium,
      cardTitleLarge: cardTitleLarge ?? this.cardTitleLarge,
      cardTitleMedium: cardTitleMedium ?? this.cardTitleMedium,
      cardTitleSmall: cardTitleSmall ?? this.cardTitleSmall,
      heading: heading ?? this.heading,
      body: body ?? this.body,
      bodyStrong: bodyStrong ?? this.bodyStrong,
      label: label ?? this.label,
      caption: caption ?? this.caption,
      chip: chip ?? this.chip,
      tab: tab ?? this.tab,
    );
  }

  @override
  AppTextStyles lerp(AppTextStyles? other, double t) {
    if (other == null) return this;
    TextStyle mix(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t) ?? a;
    return AppTextStyles(
      brandLogo: mix(brandLogo, other.brandLogo),
      displayLarge: mix(displayLarge, other.displayLarge),
      displayMedium: mix(displayMedium, other.displayMedium),
      cardTitleLarge: mix(cardTitleLarge, other.cardTitleLarge),
      cardTitleMedium: mix(cardTitleMedium, other.cardTitleMedium),
      cardTitleSmall: mix(cardTitleSmall, other.cardTitleSmall),
      heading: mix(heading, other.heading),
      body: mix(body, other.body),
      bodyStrong: mix(bodyStrong, other.bodyStrong),
      label: mix(label, other.label),
      caption: mix(caption, other.caption),
      chip: mix(chip, other.chip),
      tab: mix(tab, other.tab),
    );
  }
}
