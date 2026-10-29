import 'package:flutter/material.dart';
import 'package:rango_app/core/format/restaurant_format.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/theme/app_shadows.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/food_theme.dart';
import 'package:rango_app/core/theme/food_theme_scope.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/core/widgets/rango_chip.dart';

/// Figma `Restaurant Card` variants: `Layout` property.
enum RestaurantCardLayout { vertical, row }

/// Figma component `Restaurant Card`: a nearby restaurant that serves the
/// chosen food, with photo, name, cuisine and up to three quick-decision chips
/// (rating, distance, delivery time).
///
/// The width comes from the parent. All text sits on `bg/surface`, never over
/// the photo. The whole card is one tap target for assistive technology.
class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    required this.name,
    required this.foodTheme,
    this.layout = RestaurantCardLayout.vertical,
    this.cuisine,
    this.photo,
    this.rating,
    this.distanceMeters,
    this.deliveryTime,
    this.onTap,
    super.key,
  }) : isLoading = false;

  /// Skeleton with the same size and radius, in `bg/muted`.
  const RestaurantCard.loading({
    this.layout = RestaurantCardLayout.vertical,
    super.key,
  }) : name = '',
       foodTheme = FoodTheme.tomato,
       cuisine = null,
       photo = null,
       rating = null,
       distanceMeters = null,
       deliveryTime = null,
       onTap = null,
       isLoading = true;

  final String name;

  /// Colors of the photo placeholder.
  final FoodTheme foodTheme;

  final RestaurantCardLayout layout;

  /// Cuisine type and address line.
  final String? cuisine;

  /// Null, or a photo that fails to load, draws the food-colored placeholder.
  final ImageProvider<Object>? photo;

  /// Null hides the rating chip.
  final double? rating;

  /// Null hides the distance chip.
  final double? distanceMeters;

  /// Ready-made label such as `25–35 min`. Null hides the chip.
  final String? deliveryTime;

  final VoidCallback? onTap;

  /// Skeleton state, set by [RestaurantCard.loading].
  final bool isLoading;

  static const _verticalPhotoHeight = 138.0;
  static const _rowPhotoSize = 88.0;
  static const _iconSize = 20.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final body = Padding(
      padding: const EdgeInsets.all(AppSpace.sm),
      child: switch (layout) {
        RestaurantCardLayout.vertical => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpace.sm,
          children: [
            SizedBox(height: _verticalPhotoHeight, child: _photo()),
            _text(context),
          ],
        ),
        RestaurantCardLayout.row => Row(
          spacing: AppSpace.sm,
          children: [
            SizedBox.square(dimension: _rowPhotoSize, child: _photo()),
            Expanded(child: _text(context)),
          ],
        ),
      },
    );

    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: isLoading ? colors.bgMuted : colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: isLoading ? null : AppShadows.card,
      ),
      child: isLoading
          ? Opacity(opacity: 0, child: body)
          : Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: onTap,
                child: body,
              ),
            ),
    );

    if (isLoading) {
      return Semantics(label: 'Carregando restaurante', child: card);
    }
    return Semantics(
      container: true,
      button: onTap != null,
      label: _spokenLabel(),
      excludeSemantics: true,
      onTap: onTap,
      child: card,
    );
  }

  String? get _ratingLabel {
    final rating = this.rating;
    return rating == null ? null : formatRating(rating);
  }

  String? get _distanceLabel {
    final meters = distanceMeters;
    return meters == null ? null : formatDistance(meters);
  }

  String _spokenLabel() {
    final rating = _ratingLabel;
    final distance = _distanceLabel;
    final time = deliveryTime;
    return [
      name,
      ?cuisine,
      if (rating != null) 'nota $rating',
      if (distance != null) 'a $distance',
      if (time != null) _spokenTime(time),
    ].join(', ');
  }

  /// `25–35 min` is read as "25 a 35 minutos".
  static String _spokenTime(String time) =>
      time.replaceAll('–', ' a ').replaceAll('min', 'minutos');

  Widget _photo() {
    final photo = this.photo;
    return FoodThemeScope(
      theme: foodTheme,
      child: Builder(
        builder: (context) {
          final placeholder = ColoredBox(
            color: context.foodColors.background,
            child: Center(
              child: Icon(
                Icons.image_outlined,
                size: _iconSize,
                color: context.foodColors.foreground,
              ),
            ),
          );
          return ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.photo),
            child: photo == null
                ? placeholder
                : Image(
                    image: photo,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => placeholder,
                  ),
          );
        },
      ),
    );
  }

  Widget _text(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final cuisine = this.cuisine;
    final rating = _ratingLabel;
    final distance = _distanceLabel;
    final time = deliveryTime;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpace.xxs,
      children: [
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: styles.heading.copyWith(color: colors.textPrimary),
        ),
        if (cuisine != null)
          Text(
            cuisine,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: styles.caption.copyWith(color: colors.textSecondary),
          ),
        if (rating != null || distance != null || time != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpace.xxs),
            child: Wrap(
              spacing: AppSpace.xs,
              runSpacing: AppSpace.xs,
              children: [
                if (rating != null)
                  RangoChip(
                    label: rating,
                    style: RangoChipStyle.soft,
                    icon: Icons.star_rounded,
                  ),
                if (distance != null)
                  RangoChip(
                    label: distance,
                    style: RangoChipStyle.soft,
                    icon: Icons.place_outlined,
                  ),
                if (time != null)
                  RangoChip(label: time, style: RangoChipStyle.soft),
              ],
            ),
          ),
      ],
    );
  }
}
