/// Rating with one decimal and a comma, e.g. `4,7`.
String formatRating(double rating) =>
    rating.toStringAsFixed(1).replaceAll('.', ',');

/// Distance in whole meters below 1 km (`850 m`), else km with one decimal
/// and a comma (`1,2 km`).
String formatDistance(double meters) {
  if (meters.round() < 1000) return '${meters.round()} m';
  return '${(meters / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';
}
