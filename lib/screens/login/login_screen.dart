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
import 'package:rango_app/screens/login/login_view_model.dart';

/// "Entrar" (Figma 13, 13b and 13c): signs in to an account. Optional: back
/// keeps the person as a guest.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginViewModelProvider);
    final viewModel = ref.read(loginViewModelProvider.notifier);
    final alert = state.alert;

    ref.listen(loginViewModelProvider.select((s) => s.done), (_, done) {
      if (done) context.pop();
    });

    void submit() => unawaited(
      viewModel.submit(email: _email.text, password: _password.text),
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
              // The subtitle gives its place to the alert, so the form still
              // fits the screen.
              PageHeader(
                title: 'Entrar',
                subtitle: alert == null
                    ? 'Entre para salvar seus rangos e ver seu histórico em '
                          'qualquer aparelho.'
                    : null,
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
                      hint: 'Sua senha',
                      controller: _password,
                      error: state.passwordError,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onChanged: (_) => viewModel.edited(),
                      onSubmitted: (_) => submit(),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: RangoButton(
                        label: 'Esqueci minha senha',
                        style: RangoButtonStyle.ghost,
                        size: RangoButtonSize.medium,
                        onPressed: () => unawaited(
                          context.push(
                            '/password-reset',
                            extra: _email.text.trim(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpace.xxs,
                children: [
                  RangoButton(
                    label: 'Entrar',
                    expand: true,
                    onPressed: state.submitting ? null : submit,
                  ),
                  RangoButton(
                    label: 'Ainda não tem conta? Criar conta',
                    style: RangoButtonStyle.ghost,
                    size: RangoButtonSize.medium,
                    expand: true,
                    // Replaces this screen, so back always leaves the flow.
                    onPressed: () => context.pushReplacement('/signup'),
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
