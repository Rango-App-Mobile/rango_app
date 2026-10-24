import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/core/widgets/page_header.dart';
import 'package:rango_app/core/widgets/rango_button.dart';
import 'package:rango_app/core/widgets/top_bar.dart';
import 'package:rango_app/screens/result/result_state.dart';
import 'package:rango_app/screens/result/result_view_model.dart';
import 'package:rango_app/screens/result/widgets/match_card.dart';

/// "Deu match" screen (Figma 04): the winning food type, how the user got
/// there and the way on to the nearby restaurants.
class ResultScreen extends ConsumerWidget {
  const ResultScreen({required this.pathIds, super.key});

  final List<String> pathIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(resultViewModelProvider(pathIds.join(',')));
    void goHome() => context.go('/home');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) goHome();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              TopBar.flow(onBack: goHome),
              Expanded(
                child: result.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => _ErrorBody(onRestart: goHome),
                  data: (state) => _ResultBody(state: state, onRestart: goHome),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({required this.state, required this.onRestart});

  final ResultState state;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.lg,
        AppSpace.lg,
        AppSpace.lg,
        AppSpace.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpace.lg,
        children: [
          MatchCard(
            result: state.result,
            pathLabel: state.pathLabel,
            choiceCount: state.choiceCount,
          ),
          PageHeader(
            size: PageHeaderSize.medium,
            title: 'Agora é só escolher onde.',
            subtitle:
                'Vamos buscar restaurantes que servem '
                '${state.result.label.toLowerCase()} perto de você.',
          ),
          RangoButton(
            label: 'Ver restaurantes perto',
            icon: Icons.place_outlined,
            expand: true,
            onPressed: () =>
                context.push('/restaurants?category=${state.result.id}'),
          ),
          RangoButton(
            label: 'Recomeçar',
            style: RangoButtonStyle.secondary,
            icon: Icons.refresh,
            expand: true,
            onPressed: onRestart,
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRestart});

  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpace.md,
          children: [
            Text(
              'Não deu para mostrar o resultado.',
              textAlign: TextAlign.center,
              style: context.textStyles.body,
            ),
            RangoButton(label: 'Recomeçar', onPressed: onRestart),
          ],
        ),
      ),
    );
  }
}
