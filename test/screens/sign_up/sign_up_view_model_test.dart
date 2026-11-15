import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/account_repository.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/data/fake_account_repository.dart';
import 'package:rango_app/data/fake_auth_repository.dart';
import 'package:rango_app/models/auth_form_state.dart';
import 'package:rango_app/screens/sign_up/sign_up_view_model.dart';

class _FailingAccountRepository extends FakeAccountRepository {
  @override
  Future<void> acceptTerms(String uid) async => throw const NetworkFailure();
}

void main() {
  late FakeAuthRepository auth;
  late FakeAccountRepository account;
  late ProviderContainer container;

  ProviderContainer build(AccountRepository accounts) {
    return ProviderContainer.test(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        accountRepositoryProvider.overrideWithValue(accounts),
      ],
    )..listen(signUpViewModelProvider, (_, _) {});
  }

  SignUpViewModel viewModel() =>
      container.read(signUpViewModelProvider.notifier);
  AuthFormState state() => container.read(signUpViewModelProvider);

  Future<void> submit({
    String name = 'Joana',
    String email = 'joana@email.com',
    String confirmEmail = 'joana@email.com',
    String password = '12345678',
    String confirmPassword = '12345678',
  }) => viewModel().submit(
    name: name,
    email: email,
    confirmEmail: confirmEmail,
    password: password,
    confirmPassword: confirmPassword,
  );

  setUp(() {
    auth = FakeAuthRepository();
    account = FakeAccountRepository();
    container = build(account);
  });

  test(
    'different e-mails and passwords are reported on the confirms',
    () async {
      viewModel().termsAccepted(accepted: true);
      await submit(
        confirmEmail: 'outro@email.com',
        confirmPassword: '87654321',
      );

      expect(state().confirmEmailError, 'Os e-mails não são iguais.');
      expect(state().confirmPasswordError, 'As senhas não são iguais.');
      expect(state().submitting, isFalse);
    },
  );

  test('the terms must be accepted', () async {
    await submit();

    expect(state().termsError, 'Aceite os termos para criar a conta.');
    expect(state().done, isFalse);
  });

  test('accepting the terms clears the terms error and keeps the switch', () {
    viewModel().termsAccepted(accepted: true);
    expect(state().termsAccepted, isTrue);
    viewModel().edited();
    expect(state().termsAccepted, isTrue);
  });

  test('a valid form signs up, records the terms and is done', () async {
    viewModel().termsAccepted(accepted: true);
    await submit();

    expect(state().done, isTrue);
    final user = await auth.ensureSignedIn();
    expect(user.isAnonymous, isFalse);
    expect(await account.hasAcceptedTerms(user.uid), isTrue);
  });

  test('a failure recording the terms does not undo the sign-up', () async {
    container = build(_FailingAccountRepository());
    viewModel().termsAccepted(accepted: true);
    await submit();

    expect(state().done, isTrue);
  });

  test('an e-mail in use shows on the e-mail field', () async {
    await auth.signUp(
      name: 'J',
      email: 'joana@email.com',
      password: '12345678',
    );
    viewModel().termsAccepted(accepted: true);
    await submit();

    expect(state().emailError, isNotNull);
    expect(state().termsAccepted, isTrue);
  });
}
