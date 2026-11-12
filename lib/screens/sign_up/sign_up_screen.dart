import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/core/widgets/inline_alert.dart';
import 'package:rango_app/core/widgets/page_header.dart';
import 'package:rango_app/core/widgets/rango_button.dart';
import 'package:rango_app/core/widgets/rango_divider.dart';
import 'package:rango_app/core/widgets/rango_text_field.dart';
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
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signUpViewModelProvider);
    final viewModel = ref.read(signUpViewModelProvider.notifier);
    final alert = state.alert;

    ref.listen(signUpViewModelProvider.select((s) => s.done), (_, done) {
      if (done) context.pop();
    });

    void submit() => unawaited(
      viewModel.submit(
        name: _name.text,
        email: _email.text,
        password: _password.text,
      ),
    );

    return Scaffold(
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
              // Apple and Google arrive with their own story.
              const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpace.sm,
                children: [
                  RangoButton(
                    label: 'Continuar com a Apple',
                    style: RangoButtonStyle.secondary,
                    expand: true,
                    onPressed: null,
                  ),
                  RangoButton(
                    label: 'Continuar com o Google',
                    style: RangoButtonStyle.secondary,
                    expand: true,
                    onPressed: null,
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
                      label: 'Senha',
                      hint: 'Crie uma senha',
                      helper: 'Pelo menos 8 caracteres.',
                      controller: _password,
                      error: state.passwordError,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      onChanged: (_) => viewModel.edited(),
                      onSubmitted: (_) => submit(),
                    ),
                  ],
                ),
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
  }
}
