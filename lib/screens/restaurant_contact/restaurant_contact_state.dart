import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rango_app/models/delivery_links.dart';
import 'package:rango_app/models/restaurant_contact_args.dart';

part 'restaurant_contact_state.freezed.dart';

@freezed
abstract class RestaurantContactState with _$RestaurantContactState {
  const factory RestaurantContactState({
    required RestaurantContactArgs args,

    /// True until phone, links and photo have resolved.
    @Default(true) bool loadingDetails,
    DeliveryLinks? links,
    String? phone,
    String? photoUri,

    /// An external app could not be opened; the View shows a message once.
    @Default(false) bool openFailed,
  }) = _RestaurantContactState;

  const RestaurantContactState._();

  /// Registered link (R5) or a Google search for the restaurant.
  Uri get deliveryUri => deliveryUriFor(links, args.restaurant.name);

  /// `tel:` URI with only digits and a leading `+`; null without a phone.
  Uri? get phoneUri {
    final raw = phone?.trim();
    if (raw == null) return null;
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    final plus = raw.startsWith('+') ? '+' : '';
    return Uri(scheme: 'tel', path: '$plus$digits');
  }
}
