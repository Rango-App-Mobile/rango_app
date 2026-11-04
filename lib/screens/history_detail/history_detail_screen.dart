import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/core/widgets/food_card.dart';
import 'package:rango_app/core/widgets/food_photo.dart';
import 'package:rango_app/core/widgets/history_card_hero.dart';
import 'package:rango_app/core/widgets/rango_button.dart';
import 'package:rango_app/core/widgets/top_bar.dart';
import 'package:rango_app/screens/history_detail/history_detail_state.dart';
import 'package:rango_app/screens/history_detail/history_detail_view_model.dart';
import 'package:rango_app/screens/swipe/widgets/resolve_food_theme.dart';

/// One decision of the Histórico, opened (Figma "12 Detalhe do histórico"):
/// the food, when, the way there and where the user ordered.
class HistoryDetailScreen extends ConsumerWidget {
  const HistoryDetailScreen({required this.entryId, super.key});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(historyDetailViewModelProvider(entryId));
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _LateFade(child: TopBar.flow(onBack: () => context.pop())),
            Expanded(
              child: detail.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => const _NotFound(),
                data: (state) => _Detail(state: state, entryId: entryId),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.state, required this.entryId});

  final HistoryDetailState state;
  final String entryId;

  @override
  Widget build(BuildContext context) {
    final food = state.food;
    void seeRestaurants() =>
        unawaited(context.push('/restaurants?category=${food.id}'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpace.md,
        children: [
          HistoryCardHero(
            entryId: entryId,
            child: FoodCard(
              title: food.label,
              size: FoodCardSize.expanded,
              chipLabel: state.dateLabel,
              foodTheme: resolveFoodTheme(food.foodTheme),
              photo: foodPhoto(food.photo),
              photoLabel: 'Foto: ${food.label.toLowerCase()}',
              path: state.path,
              subtitle: state.entry.restaurantName,
              cuisine: state.entry.cuisine,
            ),
          ),
          const SizedBox(height: AppSpace.xs),
          // "Opções de contato" (06) is still to come: both go to the
          // restaurants of this food for now.
          _LateFade(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpace.md,
              children: [
                RangoButton(
                  label: 'Pedir de novo',
                  icon: Icons.shopping_bag_outlined,
                  expand: true,
                  onPressed: seeRestaurants,
                ),
                RangoButton(
                  label: 'Ver no mapa',
                  icon: Icons.map_outlined,
                  style: RangoButtonStyle.secondary,
                  expand: true,
                  onPressed: seeRestaurants,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fades its child in at the end of the route's entrance (and out first on
/// the way back), so while the card flies only the card moves.
class _LateFade extends StatelessWidget {
  const _LateFade({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animation = ModalRoute.of(context)?.animation;
    if (animation == null) return child;
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: const Interval(0.7, 1),
      ),
      child: child,
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Text(
          'Não encontramos esse rango.',
          textAlign: TextAlign.center,
          style: context.textStyles.body.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
