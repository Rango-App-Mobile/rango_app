import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/data/onboarding_repository.dart';

/// The state is the page being shown. Auto-dispose, so opening the onboarding
/// again from the Profile starts on the first page.
final NotifierProvider<OnboardingViewModel, int> onboardingViewModelProvider =
    NotifierProvider.autoDispose<OnboardingViewModel, int>(
      OnboardingViewModel.new,
    );

class OnboardingViewModel extends Notifier<int> {
  static const pageCount = 3;

  @override
  int build() => 0;

  bool get isLast => state == pageCount - 1;

  void pageChanged(int page) => state = page.clamp(0, pageCount - 1);

  /// Called by "Começar" and by "Pular": either way the person has seen it.
  Future<void> finish() => ref.read(onboardingRepositoryProvider).markSeen();
}
