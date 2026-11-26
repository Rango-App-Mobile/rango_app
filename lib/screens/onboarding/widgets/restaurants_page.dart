import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/theme/food_theme.dart';
import 'package:rango_app/core/widgets/rango_chip.dart';
import 'package:rango_app/core/widgets/restaurant_card.dart';
import 'package:rango_app/screens/onboarding/widgets/clock_builder.dart';
import 'package:rango_app/screens/onboarding/widgets/onboarding_page_frame.dart';
import 'package:rango_app/screens/restaurants/widgets/drawn_restaurant_map.dart';
import 'package:rango_app/screens/restaurants/widgets/map_pin.dart';

/// Page 3: the restaurants are local, from Porto Alegre, up to 3 km away
/// (Figma "Onboarding 3", rule R4). The pins drop one by one and a restaurant
/// preview rises from the bottom. The restaurant shown is illustrative.
class RestaurantsPage extends StatelessWidget {
  const RestaurantsPage({required this.clock, super.key});

  final AnimationController clock;

  static const seconds = 5.2;
  static const _art = Size(354, 440);

  /// Top-left of each pin inside the map window, top to bottom.
  static const _pins = [
    Offset(316, 116),
    Offset(36, 130),
    Offset(126, 160),
    Offset(306, 330),
  ];
  static const _selectedPin = Offset(149, 78);
  static const _firstDrop = 1.1;
  static const _dropGap = .22;

  Widget _drop(double t, int order, Offset at, Widget pin) {
    final start = _firstDrop + order * _dropGap;
    return Positioned(
      left: at.dx,
      top: at.dy,
      child: Opacity(
        opacity: seg(t, start, start + .12),
        child: Transform.translate(
          offset: Offset(
            0,
            lerp(-110, 0, seg(t, start, start + .55, Curves.easeOutBack)),
          ),
          child: pin,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPageFrame(
      title: 'Rango de Porto Alegre',
      subtitle:
          'Os restaurantes são de gente daqui, até 3 km de você. Escolha um e '
          'peça direto no delivery.',
      artSize: _art,
      art: ClockBuilder(
        clock: clock,
        seconds: seconds,
        builder: (context, t) {
          final window = seg(t, .35, 1.1, Curves.easeOutBack);
          final chips = seg(t, .9, 1.3, Curves.easeOutBack);
          final previewStart = _firstDrop + (_pins.length + 1) * _dropGap + .2;

          return Opacity(
            opacity: seg(t, .35, .8),
            child: Transform.scale(
              scale: lerp(.92, 1, window),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DrawnRestaurantMap(
                        restaurants: const [],
                        selectedId: null,
                        foodTheme: null,
                        onSelect: (_) {},
                      ),
                    ),
                    for (var i = 0; i < _pins.length; i++)
                      _drop(
                        t,
                        i,
                        _pins[i],
                        const MapPin(name: '', foodTheme: 'tomato'),
                      ),
                    _drop(
                      t,
                      _pins.length,
                      _selectedPin,
                      const MapPin(
                        name: 'Cantina da Nona',
                        rating: 4.7,
                        foodTheme: 'tomato',
                        selected: true,
                      ),
                    ),
                    Positioned(
                      left: 14,
                      top: 14,
                      child: Opacity(
                        opacity: seg(t, .9, 1.2),
                        child: Transform.translate(
                          offset: Offset(lerp(-40, 0, chips), 0),
                          child: const Row(
                            spacing: 8,
                            children: [
                              RangoChip(
                                label: 'Porto Alegre',
                                style: RangoChipStyle.solid,
                                icon: Icons.restaurant_menu,
                              ),
                              RangoChip(
                                label: '8 lugares em até 3 km',
                                style: RangoChipStyle.soft,
                                icon: Icons.place_outlined,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Opacity(
                        opacity: seg(t, previewStart, previewStart + .2),
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            lerp(
                              150,
                              0,
                              seg(
                                t,
                                previewStart,
                                previewStart + .6,
                                Curves.easeOutBack,
                              ),
                            ),
                          ),
                          child: const RestaurantCard(
                            name: 'Cantina da Nona',
                            foodTheme: FoodTheme.tomato,
                            layout: RestaurantCardLayout.row,
                            cuisine: 'Italiana, massas frescas',
                            rating: 4.7,
                            distanceMeters: 1200,
                            deliveryTime: '25–35 min',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
