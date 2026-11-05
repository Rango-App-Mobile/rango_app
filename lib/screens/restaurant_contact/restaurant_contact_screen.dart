import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/resolve_food_theme.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/core/widgets/rango_button.dart';
import 'package:rango_app/core/widgets/restaurant_card.dart';
import 'package:rango_app/core/widgets/top_bar.dart';
import 'package:rango_app/core/widgets/top_bar_layout.dart';
import 'package:rango_app/core/widgets/top_bar_scroll_view.dart';
import 'package:rango_app/models/restaurant_contact_args.dart';
import 'package:rango_app/screens/restaurant_contact/restaurant_contact_view_model.dart';

/// "Opções de contato" (Figma 06): how to order from the chosen restaurant.
class RestaurantContactScreen extends ConsumerWidget {
  const RestaurantContactScreen({required this.args, super.key});

  final RestaurantContactArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = restaurantContactViewModelProvider(args);
    final state = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);

    ref.listen(provider.select((s) => s.openFailed), (_, failed) {
      if (!failed) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não deu para abrir. Tente de novo.')),
      );
      viewModel.acknowledgeOpenFailed();
    });

    final restaurant = args.restaurant;
    final photoUri = state.photoUri;
    final typeLine = [?restaurant.cuisine, ?restaurant.address].join('. ');

    return Scaffold(
      body: TopBarLayout(
        topBar: TopBar.flow(onBack: context.pop),
        body: TopBarScrollView(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpace.lg,
            children: [
              RestaurantCard(
                name: restaurant.name,
                foodTheme: resolveFoodTheme(args.foodTheme),
                cuisine: typeLine.isEmpty ? null : typeLine,
                photo: photoUri == null ? null : NetworkImage(photoUri),
                rating: restaurant.rating,
                distanceMeters: restaurant.distanceMeters,
              ),
              Text(
                'Como você quer pedir?',
                style: context.textStyles.heading.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpace.sm,
                children: [
                  RangoButton(
                    label: 'Pedir no delivery',
                    icon: Icons.shopping_bag_outlined,
                    expand: true,
                    onPressed: state.loadingDetails
                        ? null
                        : viewModel.orderDelivery,
                  ),
                  if (!state.loadingDetails && state.phoneUri != null)
                    RangoButton(
                      label: 'Ligar',
                      style: RangoButtonStyle.secondary,
                      icon: Icons.phone_outlined,
                      expand: true,
                      onPressed: viewModel.callRestaurant,
                    ),
                ],
              ),
              RangoButton(
                label: 'Voltar ao início',
                style: RangoButtonStyle.ghost,
                expand: true,
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
