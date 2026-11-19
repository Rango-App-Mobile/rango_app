import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/core/widgets/apple_sign_in_button.dart';
import 'package:rango_app/core/widgets/google_sign_in_button.dart';
import 'package:rango_app/core/widgets/inline_alert.dart';
import 'package:rango_app/core/widgets/page_header.dart';
import 'package:rango_app/core/widgets/rango_button.dart';
import 'package:rango_app/core/widgets/rango_divider.dart';
import 'package:rango_app/core/widgets/rango_loading_view.dart';
import 'package:rango_app/core/widgets/rango_text_field.dart';
import 'package:rango_app/core/widgets/terms_acceptance.dart';
import 'package:rango_app/core/widgets/top_bar.dart';
import 'package:rango_app/core/widgets/top_bar_layout.dart';
import 'package:rango_app/core/widgets/top_bar_scroll_view.dart';
import 'package:rango_app/screens/sign_up/sign_up_view_model.dart';

/// "Criar conta" (Figma 14 and 14b): turns the guest into an account.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _confirmEmail = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _confirmEmail.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signUpViewModelProvider);
    final viewModel = ref.read(signUpViewModelProvider.notifier);
    final alert = state.alert;

    ref.listen(signUpViewModelProvider.select((s) => s.done), (_, done) {
      // The login screen is underneath: the app is the destination, not it.
      if (done) Navigator.of(context).popUntil((route) => route.isFirst);
    });
    ref.listen(signUpViewModelProvider.select((s) => s.needsTerms), (_, needs) {
      if (needs) context.pushReplacement('/accept-terms');
    });

    void submit() => unawaited(
      viewModel.submit(
        name: _name.text,
        email: _email.text,
        confirmEmail: _confirmEmail.text,
        password: _password.text,
        confirmPassword: _confirmPassword.text,
      ),
    );

    final form = Scaffold(
      body: TopBarLayout(
        topBar: Stack(
          alignment: Alignment.center,
          children: [
            TopBar.flow(onBack: context.pop),
            ExcludeSemantics(
              child: Text(
                'Rango',
                style: context.textStyles.brandLogo.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        body: TopBarScrollView(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpace.md,
            children: [
              const PageHeader(
                title: 'Criar conta',
                size: PageHeaderSize.medium,
              ),
              if (alert != null) InlineAlert(message: alert),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpace.sm,
                children: [
                  if (viewModel.offersApple)
                    AppleSignInButton(
                      onPressed: state.submitting
                          ? null
                          : () => unawaited(viewModel.continueWithApple()),
                    ),
                  GoogleSignInButton(
                    onPressed: state.submitting
                        ? null
                        : () => unawaited(viewModel.continueWithGoogle()),
                  ),
                ],
              ),
              const RangoDivider(),
              AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpace.sm,
                  children: [
                    RangoTextField(
                      label: 'Nome',
                      hint: 'Como quer ser chamado',
                      controller: _name,
                      error: state.nameError,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.name],
                      onChanged: (_) => viewModel.edited(),
                    ),
                    RangoTextField(
                      label: 'E-mail',
                      hint: 'voce@email.com',
                      controller: _email,
                      error: state.emailError,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      onChanged: (_) => viewModel.edited(),
                    ),
                    RangoTextField(
                      label: 'Confirmar e-mail',
                      hint: 'Digite o e-mail de novo',
                      controller: _confirmEmail,
                      error: state.confirmEmailError,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => viewModel.edited(),
                    ),
                    RangoTextField(
                      label: 'Senha',
                      hint: 'Crie uma senha',
                      helper: 'Pelo menos 8 caracteres.',
                      controller: _password,
                      error: state.passwordError,
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      onChanged: (_) => viewModel.edited(),
                    ),
                    RangoTextField(
                      label: 'Confirmar senha',
                      hint: 'Digite a senha de novo',
                      controller: _confirmPassword,
                      error: state.confirmPasswordError,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => viewModel.edited(),
                      onSubmitted: (_) => submit(),
                    ),
                  ],
                ),
              ),
              TermsAcceptance(
                value: state.termsAccepted,
                error: state.termsError,
                onChanged: (accepted) =>
                    viewModel.termsAccepted(accepted: accepted),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpace.xs,
                children: [
                  RangoButton(
                    label: 'Criar conta',
                    expand: true,
                    onPressed: state.submitting ? null : submit,
                  ),
                  RangoButton(
                    label: 'Já tem conta? Entrar',
                    style: RangoButtonStyle.ghost,
                    size: RangoButtonSize.medium,
                    expand: true,
                    // Replaces this screen, so back always leaves the flow.
                    onPressed: () => context.pushReplacement('/login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // Covers the whole screen while a sign-in is running; back is blocked so
    // the request cannot be abandoned half-way.
    return PopScope(
      canPop: !state.submitting,
      child: Stack(
        children: [
          form,
          if (state.submitting)
            const Positioned.fill(
              child: RangoLoadingView(message: 'Criando sua conta…'),
            ),
        ],
      ),
    );
  }
}
