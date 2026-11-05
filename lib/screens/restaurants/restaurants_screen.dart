import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/resolve_food_theme.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/core/widgets/empty_state.dart';
import 'package:rango_app/core/widgets/food_photo.dart';
import 'package:rango_app/core/widgets/rango_button.dart';
import 'package:rango_app/core/widgets/rango_chip.dart';
import 'package:rango_app/core/widgets/rango_icon_button.dart';
import 'package:rango_app/core/widgets/restaurant_card.dart';
import 'package:rango_app/core/widgets/top_bar.dart';
import 'package:rango_app/core/widgets/top_bar_layout.dart';
import 'package:rango_app/models/restaurant_contact_args.dart';
import 'package:rango_app/screens/restaurants/restaurants_state.dart';
import 'package:rango_app/screens/restaurants/restaurants_view_model.dart';
import 'package:rango_app/screens/restaurants/widgets/restaurant_map.dart';

/// Restaurants on the map (Figma 08 loading, 05 map, 09 location denied, plus
/// empty and error): nearby places that serve the chosen food, nearest first
/// and already selected.
///
/// [categoryId] is the leaf category id from the `/restaurants?category=` query.
class RestaurantsScreen extends ConsumerStatefulWidget {
  const RestaurantsScreen({required this.categoryId, super.key});

  final String? categoryId;

  @override
  ConsumerState<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends ConsumerState<RestaurantsScreen> {
  int _recenterTick = 0;

  RestaurantsViewModel get _viewModel =>
      ref.read(restaurantsViewModelProvider(widget.categoryId).notifier);

  void _goHome() => context.go('/home');

  void _openContact(RestaurantsState state) {
    final selected = state.selected;
    if (selected == null) return;
    unawaited(
      context.push<void>(
        '/restaurants/contact',
        extra: RestaurantContactArgs(
          restaurant: selected,
          foodTheme: state.foodTheme,
          photoUri: state.photoUri,
        ),
      ),
    );
  }

  void _onSelect(RestaurantsState state, String placeId) {
    // The selected pin is a shortcut to the same place as the preview.
    if (placeId == state.selectedId) {
      _openContact(state);
    } else {
      unawaited(_viewModel.select(placeId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(restaurantsViewModelProvider(widget.categoryId));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHome();
      },
      child: Scaffold(
        body: switch (state.status) {
          RestaurantsStatus.locating ||
          RestaurantsStatus.searching ||
          RestaurantsStatus.ready => _mapBody(state),
          _ => _blockedBody(state),
        },
      ),
    );
  }

  Widget _mapBody(RestaurantsState state) {
    final isReady = state.status == RestaurantsStatus.ready;
    final selected = state.selected;
    return Stack(
      children: [
        Positioned.fill(
          child: RestaurantMap(
            origin: state.origin,
            restaurants: state.restaurants,
            selectedId: state.selectedId,
            foodTheme: state.foodTheme,
            recenterTick: _recenterTick,
            onSelect: (id) => _onSelect(state, id),
          ),
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopBar.flow(onBack: _goHome),
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpace.md,
                  left: AppSpace.lg,
                  right: AppSpace.lg,
                ),
                child: _Chips(state: state),
              ),
            ],
          ),
        ),
        if (isReady && selected != null)
          Positioned(
            left: AppSpace.lg,
            right: AppSpace.lg,
            bottom: 0,
            child: SafeArea(
              minimum: const EdgeInsets.only(bottom: AppSpace.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: AppSpace.lg,
                children: [
                  RangoIconButton(
                    icon: Icons.my_location,
                    semanticLabel: 'Centralizar em você',
                    onPressed: () => setState(() => _recenterTick++),
                  ),
                  RestaurantCard(
                    layout: RestaurantCardLayout.row,
                    name: selected.name,
                    cuisine: selected.cuisine,
                    rating: selected.rating,
                    distanceMeters: selected.distanceMeters,
                    foodTheme: resolveFoodTheme(state.foodTheme),
                    photo: state.photoUri != null
                        ? NetworkImage(state.photoUri!)
                        : foodPhoto(state.foodPhoto),
                    onTap: () => _openContact(state),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _blockedBody(RestaurantsState state) {
    final viewModel = _viewModel;
    final food = state.foodLabel.toLowerCase();
    final (icon, title, message, primary, secondary) = switch (state.status) {
      RestaurantsStatus.locationDenied => (
        Icons.place_outlined,
        'Precisamos da sua localização',
        _locationMessage,
        _Action('Permitir localização', viewModel.requestPermissionAgain),
        _Action('Abrir ajustes do celular', viewModel.openSettings),
      ),
      RestaurantsStatus.locationDeniedForever => (
        Icons.place_outlined,
        'Precisamos da sua localização',
        _locationMessage,
        _Action('Abrir ajustes do celular', viewModel.openSettings),
        _Action('Voltar ao início', _goHome),
      ),
      RestaurantsStatus.locationServiceOff => (
        Icons.location_off_outlined,
        'Sua localização está desligada',
        'Ligue a localização do celular para achar lugares perto de você.',
        _Action('Abrir ajustes de localização', viewModel.openSettings),
        _Action('Tentar de novo', viewModel.retry),
      ),
      RestaurantsStatus.empty => (
        Icons.search_off,
        'Nenhum lugar perto',
        'Não achamos $food a até 3 km de você.',
        _Action('Tentar de novo', viewModel.retry),
        _Action('Voltar ao início', _goHome),
      ),
      _ => (
        Icons.error_outline,
        'Não deu para buscar',
        state.errorMessage,
        _Action('Tentar de novo', viewModel.retry),
        _Action('Voltar ao início', _goHome),
      ),
    };

    return ColoredBox(
      color: context.colors.bgCanvas,
      child: TopBarLayout(
        topBar: TopBar.flow(onBack: _goHome),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpace.lg,
                children: [
                  EmptyState(icon: icon, title: title, message: message),
                  RangoButton(
                    label: primary.label,
                    onPressed: primary.onPressed,
                  ),
                  RangoButton(
                    label: secondary.label,
                    style: RangoButtonStyle.secondary,
                    onPressed: secondary.onPressed,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const _locationMessage =
      'O Rango usa sua localização só para achar lugares perto de você. '
      'Ela não fica salva.';
}

class _Action {
  const _Action(this.label, this.onPressed);

  final String label;
  final VoidCallback onPressed;
}

class _Chips extends StatelessWidget {
  const _Chips({required this.state});

  final RestaurantsState state;

  @override
  Widget build(BuildContext context) {
    if (state.status != RestaurantsStatus.ready) {
      // Scales down instead of overflowing on narrow phones or long names.
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: RangoChip(
          label: 'Procurando ${state.foodLabel.toLowerCase()} perto de você',
          style: RangoChipStyle.solid,
          icon: Icons.autorenew,
        ),
      );
    }
    final count = state.restaurants.length;
    return Wrap(
      spacing: AppSpace.xs,
      runSpacing: AppSpace.xs,
      children: [
        RangoChip(
          label: state.foodLabel,
          style: RangoChipStyle.solid,
          icon: Icons.restaurant,
        ),
        DecoratedBox(
          decoration: ShapeDecoration(
            color: context.colors.bgSurface,
            shape: const StadiumBorder(),
          ),
          child: RangoChip(
            label: count == 1
                ? '1 lugar em até 3 km'
                : '$count lugares em até 3 km',
            icon: Icons.place_outlined,
          ),
        ),
      ],
    );
  }
}
