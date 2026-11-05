import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/models/geo_point.dart';
import 'package:rango_app/models/restaurant.dart';
import 'package:rango_app/screens/restaurants/widgets/drawn_restaurant_map.dart';
import 'package:rango_app/screens/restaurants/widgets/map_pin.dart';
import 'package:rango_app/screens/restaurants/widgets/osm_restaurant_map.dart';
import 'package:rango_app/screens/restaurants/widgets/user_location_marker.dart';

const _origin = GeoPoint(lat: -30.0277, lng: -51.2287);

const _near = Restaurant(
  placeId: 'near',
  name: 'Cantina da Nona',
  rating: 4.6,
  location: GeoPoint(lat: -30.0257, lng: -51.2277),
);

const _far = Restaurant(
  placeId: 'far',
  name: 'Forno e Lenha',
  rating: 4.7,
  location: GeoPoint(lat: -30.0357, lng: -51.2327),
);

/// Keeps the tests off the network: every tile is a transparent pixel.
class _BlankTiles extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(TileProvider.transparentImage);
}

Widget _map({
  GeoPoint? origin = _origin,
  List<Restaurant> restaurants = const [_near, _far],
  String? selectedId,
  int recenterTick = 0,
  ValueChanged<String>? onSelect,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    builder: (context, child) => MediaQuery(
      // The halo pulses forever; reduced motion lets pumpAndSettle finish.
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: child ?? const SizedBox.shrink(),
    ),
    home: Scaffold(
      body: OsmRestaurantMap(
        origin: origin,
        restaurants: restaurants,
        selectedId: selectedId,
        foodTheme: null,
        onSelect: onSelect ?? (_) {},
        recenterTick: recenterTick,
        createTileProvider: _BlankTiles.new,
      ),
    ),
  );
}

Finder _pin(String name) => find.byWidgetPredicate(
  (widget) => widget is MapPin && widget.name == name,
);

Offset _mapCenter(WidgetTester tester) =>
    tester.getCenter(find.byType(FlutterMap));

/// The point of the drop, which must sit on the restaurant's coordinate.
Offset _tip(WidgetTester tester, String name) {
  final rect = tester.getRect(_pin(name));
  return Offset(rect.center.dx, rect.bottom - MapPin.tipInset);
}

void main() {
  testWidgets('shows one pin per restaurant', (tester) async {
    await tester.pumpWidget(_map());
    await tester.pumpAndSettle();

    expect(_pin('Cantina da Nona'), findsOneWidget);
    expect(_pin('Forno e Lenha'), findsOneWidget);
  });

  testWidgets('tapping a pin reports its restaurant', (tester) async {
    final selected = <String>[];
    await tester.pumpWidget(_map(onSelect: selected.add));
    await tester.pumpAndSettle();

    await tester.tap(_pin('Cantina da Nona'));

    expect(selected, ['near']);
  });

  testWidgets('only the selected pin shows the balloon', (tester) async {
    await tester.pumpWidget(_map(selectedId: 'near'));
    await tester.pumpAndSettle();

    expect(find.text('Cantina da Nona ★ 4,6'), findsOneWidget);
    expect(find.textContaining('Forno e Lenha'), findsNothing);
  });

  testWidgets('selecting a restaurant brings its pin tip to the center', (
    tester,
  ) async {
    await tester.pumpWidget(_map());
    await tester.pumpAndSettle();

    await tester.pumpWidget(_map(selectedId: 'far'));
    await tester.pumpAndSettle();

    final tip = _tip(tester, 'Forno e Lenha');
    final center = _mapCenter(tester);
    expect(tip.dx, closeTo(center.dx, 1));
    expect(tip.dy, closeTo(center.dy, 1));
  });

  testWidgets('a restaurant selected from the start is centered too', (
    tester,
  ) async {
    await tester.pumpWidget(_map(selectedId: 'far'));
    await tester.pumpAndSettle();

    final tip = _tip(tester, 'Forno e Lenha');
    final center = _mapCenter(tester);
    expect(tip.dx, closeTo(center.dx, 1));
    expect(tip.dy, closeTo(center.dy, 1));
  });

  testWidgets('recentering brings the person back to the center', (
    tester,
  ) async {
    await tester.pumpWidget(_map(selectedId: 'far'));
    await tester.pumpAndSettle();
    final you = find.byType(UserLocationMarker);
    expect(tester.getCenter(you), isNot(_mapCenter(tester)));

    await tester.pumpWidget(_map(selectedId: 'far', recenterTick: 1));
    await tester.pumpAndSettle();

    final position = tester.getCenter(you);
    final center = _mapCenter(tester);
    expect(position.dx, closeTo(center.dx, 1));
    expect(position.dy, closeTo(center.dy, 1));
  });

  testWidgets('uses the drawn map until the position is known', (tester) async {
    await tester.pumpWidget(_map(origin: null, restaurants: const []));
    await tester.pumpAndSettle();

    expect(find.byType(DrawnRestaurantMap), findsOneWidget);
    expect(find.byType(FlutterMap), findsNothing);
  });

  testWidgets('loads tiles only through the given provider', (tester) async {
    await tester.pumpWidget(_map());
    await tester.pumpAndSettle();

    final layer = tester.widget<TileLayer>(find.byType(TileLayer));
    expect(layer.tileProvider, isA<_BlankTiles>());
    expect(
      layer.tileProvider.headers['User-Agent'],
      'flutter_map (br.senac.rango_app)',
    );
    expect(layer.urlTemplate, 'https://tile.openstreetmap.org/{z}/{x}/{y}.png');
  });
}
