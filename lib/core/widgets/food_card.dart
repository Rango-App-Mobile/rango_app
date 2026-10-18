import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_colors.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/theme/app_shadows.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/food_theme.dart';
import 'package:rango_app/core/theme/food_theme_scope.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/core/widgets/rango_chip.dart';

/// Figma `Food Card` variants: `Size` property.
enum FoodCardSize { hero, medium, compact, expanded }

/// Figma component `Food Card`: a category, dish or restaurant card painted in
/// the colors of its [FoodTheme].
///
/// The width comes from the parent; the height follows the content, with the
/// photo height fixed per size. Hero and Medium are the swipe cards, Compact is
/// a list row, Expanded is the result detail with the path that led here.
class FoodCard extends StatelessWidget {
  const FoodCard({
    required this.title,
    required this.foodTheme,
    this.size = FoodCardSize.hero,
    this.subtitle,
    this.chipLabel,
    this.photo,
    this.photoLabel = 'Foto do prato',
    this.cuisine,
    this.path = const [],
    super.key,
  });

  /// Figma "Title".
  final String title;

  /// The Food Theme mode of the instance (`food-card/bg` and `food-card/on`).
  final FoodTheme foodTheme;

  final FoodCardSize size;

  /// Figma "Restaurant". Null is "Show restaurant" off. In Expanded it is the
  /// name of the restaurant where the user ordered.
  final String? subtitle;

  /// Figma "Show chip": null hides it.
  final String? chipLabel;

  /// Null draws the Figma placeholder.
  final ImageProvider<Object>? photo;

  /// Caption of the placeholder.
  final String photoLabel;

  /// Expanded only: the cuisine line under the restaurant name.
  final String? cuisine;

  /// Expanded only: "O caminho até aqui", one chip per choice.
  final List<String> path;

  /// Figma Medium padding, no space token between `sm` and `md`.
  static const _mediumPadding = 12.0;

  /// Figma gap between the title and the meta row, no space token.
  static const _headerGap = 6.0;

  static const _heroPhotoHeight = 330.0;
  static const _mediumPhotoHeight = 160.0;
  static const _expandedPhotoHeight = 200.0;
  static const _compactHeight = 88.0;
  static const _compactThumb = 64.0;
  static const _restaurantThumb = 56.0;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    final chipLabel = this.chipLabel;
    final isExpanded = size == FoodCardSize.expanded;
    final spoken = [
      title,
      ?subtitle,
      ?chipLabel,
      if (isExpanded) ...[?cuisine, ...path],
    ].join(', ');

    return FoodThemeScope(
      theme: foodTheme,
      child: Builder(
        builder: (context) => Semantics(
          container: true,
          label: spoken,
          excludeSemantics: true,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.foodColors.background,
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: AppShadows.card,
            ),
            child: switch (size) {
              FoodCardSize.hero => _vertical(
                context,
                padding: AppSpace.md,
                photoHeight: _heroPhotoHeight,
                titleStyle: context.textStyles.cardTitleLarge,
              ),
              FoodCardSize.medium => _vertical(
                context,
                padding: _mediumPadding,
                photoHeight: _mediumPhotoHeight,
                titleStyle: context.textStyles.cardTitleMedium,
              ),
              FoodCardSize.expanded => _expanded(context),
              FoodCardSize.compact => _compact(context),
            },
          ),
        ),
      ),
    );
  }

  Widget _vertical(
    BuildContext context, {
    required double padding,
    required double photoHeight,
    required TextStyle titleStyle,
  }) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpace.sm,
        children: [
          _header(context, titleStyle: titleStyle),
          _Photo(photo: photo, label: photoLabel, height: photoHeight),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, {required TextStyle titleStyle}) {
    final subtitle = this.subtitle;
    final chipLabel = this.chipLabel;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: _headerGap,
      children: [
        _title(context, titleStyle),
        if (subtitle != null || chipLabel != null)
          Row(
            spacing: AppSpace.xs,
            children: [
              if (subtitle != null)
                Expanded(
                  child: Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.label.copyWith(
                      color: context.foodColors.foreground,
                    ),
                  ),
                ),
              if (chipLabel != null) _FoodChip(label: chipLabel),
            ],
          ),
      ],
    );
  }

  Widget _title(BuildContext context, TextStyle style) {
    return Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: style.copyWith(color: context.foodColors.foreground),
    );
  }

  Widget _compact(BuildContext context) {
    final subtitle = this.subtitle;
    final chipLabel = this.chipLabel;
    final styles = context.textStyles;
    final ink = context.foodColors.foreground;
    return SizedBox(
      height: _compactHeight,
      child: Padding(
        padding: const EdgeInsets.all(_mediumPadding),
        child: Row(
          spacing: _mediumPadding,
          children: [
            _Photo(
              photo: photo,
              label: photoLabel,
              height: _compactThumb,
              width: _compactThumb,
              showLabel: false,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title(context, styles.cardTitleSmall),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: styles.caption.copyWith(color: ink),
                    ),
                ],
              ),
            ),
            if (chipLabel != null) _FoodChip(label: chipLabel),
          ],
        ),
      ),
    );
  }

  Widget _expanded(BuildContext context) {
    final chipLabel = this.chipLabel;
    final subtitle = this.subtitle;
    final cuisine = this.cuisine;
    final styles = context.textStyles;
    final colors = context.colors;
    final ink = context.foodColors.foreground;

    return Padding(
      padding: const EdgeInsets.all(AppSpace.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpace.md,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: _headerGap,
            children: [
              _title(context, styles.cardTitleLarge),
              if (chipLabel != null) _FoodChip(label: chipLabel),
            ],
          ),
          _Photo(
            photo: photo,
            label: photoLabel,
            height: _expandedPhotoHeight,
          ),
          if (path.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpace.xs,
              children: [
                Text(
                  'O caminho até aqui',
                  style: styles.caption.copyWith(color: ink),
                ),
                Wrap(
                  spacing: AppSpace.xs,
                  runSpacing: AppSpace.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (var i = 0; i < path.length; i++) ...[
                      if (i > 0)
                        Text('→', style: styles.label.copyWith(color: ink)),
                      _FoodChip(label: path[i]),
                    ],
                  ],
                ),
              ],
            ),
          if (subtitle != null || cuisine != null)
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.bgSurface,
                borderRadius: BorderRadius.circular(AppRadius.photo),
              ),
              child: Padding(
                padding: const EdgeInsets.all(_mediumPadding),
                child: Row(
                  spacing: _mediumPadding,
                  children: [
                    _Photo(
                      photo: null,
                      label: '',
                      height: _restaurantThumb,
                      width: _restaurantThumb,
                      showLabel: false,
                      tint: colors.bgPlaceholder,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Onde você pediu',
                            style: styles.caption.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: styles.bodyStrong.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                          if (cuisine != null)
                            Text(
                              cuisine,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: styles.caption.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Outline [RangoChip] whose ink follows `food-card/on`, so it keeps its
/// contrast on dark modes such as plum and cocoa.
class _FoodChip extends StatelessWidget {
  const _FoodChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = context.foodColors.foreground;
    final extensions = {...theme.extensions}
      ..[AppColors] = context.colors.copyWith(
        textPrimary: ink,
        borderStrong: ink,
      );
    return Theme(
      data: theme.copyWith(extensions: extensions.values),
      child: RangoChip(label: label),
    );
  }
}

/// The dish photo, or the Figma placeholder: a tint of the card color with an
/// image icon and the [label].
class _Photo extends StatelessWidget {
  const _Photo({
    required this.photo,
    required this.label,
    required this.height,
    this.width,
    this.showLabel = true,
    this.tint,
  });

  final ImageProvider<Object>? photo;
  final String label;
  final double height;
  final double? width;
  final bool showLabel;

  /// Overrides the derived placeholder color.
  final Color? tint;

  static const _iconSize = 28.0;

  @override
  Widget build(BuildContext context) {
    final photo = this.photo;
    final placeholder = _placeholder(context);
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.photo),
        child: photo == null
            ? placeholder
            : Image(
                image: photo,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
              ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    final food = context.foodColors;
    // The Figma placeholder is the card color one step darker, and there is no
    // token for it per mode: blend a little ink over the mode's background.
    final fill =
        tint ??
        Color.alphaBlend(
          context.colors.textPrimary.withValues(alpha: 0.12),
          food.background,
        );
    final ink = tint == null ? food.foreground : context.colors.iconMuted;
    return ColoredBox(
      color: fill,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpace.xxs,
          children: [
            Icon(
              Icons.image_outlined,
              size: showLabel ? _iconSize : _iconSize - AppSpace.xs,
              color: ink,
            ),
            if (showLabel)
              Text(
                label,
                style: context.textStyles.caption.copyWith(color: ink),
              ),
          ],
        ),
      ),
    );
  }
}
