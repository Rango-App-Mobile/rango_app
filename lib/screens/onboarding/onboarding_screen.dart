import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/core/widgets/rango_button.dart';
import 'package:rango_app/screens/onboarding/onboarding_view_model.dart';
import 'package:rango_app/screens/onboarding/widgets/choose_page.dart';
import 'package:rango_app/screens/onboarding/widgets/onboarding_progress.dart';
import 'package:rango_app/screens/onboarding/widgets/restaurants_page.dart';
import 'package:rango_app/screens/onboarding/widgets/swipe_page.dart';

/// First-open tour (and "Como funciona o app" in the Profile): choose between
/// sweet and savory, like or pass until a match, local restaurants of Porto
/// Alegre. Figma section "07 · Onboarding".
///
/// One clock drives the illustration of the page on screen and the progress
/// bar; it loops while the page is shown (and stands still at the end state
/// with reduced motion).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  static const List<double> _seconds = [
    ChoosePage.seconds,
    SwipePage.seconds,
    RestaurantsPage.seconds,
  ];

  final _pages = PageController();
  late final AnimationController _clock = AnimationController(vsync: this);
  bool _started = false;
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (!_started || reduce != _reduceMotion) {
      _started = true;
      _reduceMotion = reduce;
      _play(ref.read(onboardingViewModelProvider));
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    _clock.dispose();
    super.dispose();
  }

  void _play(int page) {
    _clock.duration = Duration(milliseconds: (_seconds[page] * 1000).round());
    if (_reduceMotion) {
      _clock.value = 1;
    } else {
      _clock
        ..value = 0
        ..repeat();
    }
  }

  void _onPageChanged(int page) {
    ref.read(onboardingViewModelProvider.notifier).pageChanged(page);
    _play(page);
  }

  void _next() {
    final next = (_pages.page ?? 0).round() + 1;
    if (_reduceMotion) {
      // `animateToPage` rejects a zero duration, so jump.
      _pages.jumpToPage(next);
    } else {
      // Future<void> that needs no await: the page change arrives through
      // `onPageChanged`.
      _pages.animateToPage(
        next,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    }
  }

  /// First open: there is nothing behind, go home. Reopened from the Profile:
  /// go back to where it was.
  Future<void> _leave() async {
    await ref.read(onboardingViewModelProvider.notifier).finish();
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = ref.watch(onboardingViewModelProvider);
    final isLast = page == OnboardingViewModel.pageCount - 1;

    return Scaffold(
      backgroundColor: context.colors.bgCanvas,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.lg,
                AppSpace.xs,
                AppSpace.sm,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OnboardingProgress(
                    page: page,
                    pageCount: OnboardingViewModel.pageCount,
                    clock: _clock,
                  ),
                  Visibility(
                    visible: !isLast,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: RangoButton(
                      label: 'Pular',
                      style: RangoButtonStyle.ghost,
                      size: RangoButtonSize.medium,
                      onPressed: () => unawaited(_leave()),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: _onPageChanged,
                children: [
                  ChoosePage(clock: _clock),
                  SwipePage(clock: _clock),
                  RestaurantsPage(clock: _clock),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpace.lg),
              child: RangoButton(
                label: isLast ? 'Começar' : 'Próximo',
                expand: true,
                onPressed: isLast ? () => unawaited(_leave()) : _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
