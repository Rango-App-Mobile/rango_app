import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/data/fake_onboarding_repository.dart';
import 'package:rango_app/data/onboarding_repository.dart';
import 'package:rango_app/screens/onboarding/onboarding_view_model.dart';

void main() {
  ProviderContainer containerWith(FakeOnboardingRepository repository) {
    final container = ProviderContainer.test(
      overrides: [onboardingRepositoryProvider.overrideWithValue(repository)],
    )..listen(onboardingViewModelProvider, (_, _) {});
    return container;
  }

  test('starts on the first page', () {
    final container = containerWith(FakeOnboardingRepository(seen: false));

    expect(container.read(onboardingViewModelProvider), 0);
  });

  test('follows the page being shown and knows the last one', () {
    final container = containerWith(FakeOnboardingRepository(seen: false));
    final viewModel = container.read(onboardingViewModelProvider.notifier)
      ..pageChanged(1);
    expect(container.read(onboardingViewModelProvider), 1);
    expect(viewModel.isLast, isFalse);

    viewModel.pageChanged(OnboardingViewModel.pageCount - 1);
    expect(viewModel.isLast, isTrue);
  });

  test('never goes past the last page', () {
    final container = containerWith(FakeOnboardingRepository(seen: false));
    container.read(onboardingViewModelProvider.notifier).pageChanged(99);

    expect(container.read(onboardingViewModelProvider), 2);
  });

  test('never goes before the first page', () {
    final container = containerWith(FakeOnboardingRepository(seen: false));
    container.read(onboardingViewModelProvider.notifier).pageChanged(-3);

    expect(container.read(onboardingViewModelProvider), 0);
  });

  test('finish remembers that the onboarding was seen', () async {
    final repository = FakeOnboardingRepository(seen: false);
    final container = containerWith(repository);

    await container.read(onboardingViewModelProvider.notifier).finish();

    expect(repository.hasSeen, isTrue);
  });
}
