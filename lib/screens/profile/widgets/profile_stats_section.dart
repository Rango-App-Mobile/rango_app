import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/core/widgets/rango_button.dart';
import 'package:rango_app/models/profile_stats.dart';
import 'package:rango_app/screens/profile/profile_view_model.dart';

/// Account-only summary of the decisions already loaded for the History tab.
class ProfileStatsSection extends ConsumerWidget {
  const ProfileStatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(profileStatsProvider)
        .when(
          data: (stats) => _StatsGrid(stats: stats),
          error: (_, _) => _StatsError(
            onRetry: () =>
                ref.read(profileViewModelProvider.notifier).retryStatistics(),
          ),
          loading: () => const _StatsLoading(),
        );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final ProfileStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        color: context.colors.bgMuted,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        spacing: AppSpace.xs,
        children: [
          Expanded(
            child: _Stat(
              value: stats.decisionCount == 0
                  ? '—'
                  : stats.decisionCount.toString(),
              label: 'rangos decididos',
            ),
          ),
          Expanded(
            child: _Stat(
              value: stats.favoriteFood ?? '—',
              label: 'comida favorita',
            ),
          ),
          Expanded(
            child: _Stat(
              value: stats.favoriteRestaurant ?? '—',
              label: 'restaurante favorito',
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpace.xxs,
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.heading.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.caption.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatsLoading extends StatelessWidget {
  const _StatsLoading();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Carregando estatísticas',
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpace.md),
        decoration: BoxDecoration(
          color: context.colors.bgMuted,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: AppSpace.xs,
          children: [
            const SizedBox.square(
              dimension: AppSpace.md,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            Text(
              'Carregando estatísticas…',
              style: context.textStyles.caption.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsError extends StatelessWidget {
  const _StatsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        color: context.colors.bgMuted,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpace.xs,
        children: [
          Text(
            'Não foi possível carregar as estatísticas.',
            style: context.textStyles.body.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          RangoButton(
            label: 'Tentar de novo',
            size: RangoButtonSize.medium,
            style: RangoButtonStyle.ghost,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
