import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/widgets/empty_state.dart';
import 'package:rango_app/core/widgets/inline_alert.dart';
import 'package:rango_app/core/widgets/page_header.dart';
import 'package:rango_app/core/widgets/rango_button.dart';
import 'package:rango_app/core/widgets/rango_text_field.dart';
import 'package:rango_app/core/widgets/top_bar.dart';
import 'package:rango_app/core/widgets/top_bar_layout.dart';
import 'package:rango_app/core/widgets/top_bar_scroll_view.dart';
import 'package:rango_app/screens/password_reset/password_reset_view_model.dart';

/// "Recuperar senha" (Figma 15) and, once sent, "Link enviado" (Figma 15b).
/// The new password is typed on Firebase's page, outside the app.
class PasswordResetScreen extends ConsumerStatefulWidget {
  const PasswordResetScreen({this.initialEmail, super.key});

  /// What was already typed in "Entrar".
  final String? initialEmail;

  @override
  ConsumerState<PasswordResetScreen> createState() =>
      _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  late final _email = TextEditingController(text: widget.initialEmail);

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordResetViewModelProvider);
    final viewModel = ref.read(passwordResetViewModelProvider.notifier);
    final alert = state.alert;

    void submit() => unawaited(viewModel.submit(_email.text));

    return Scaffold(
      body: TopBarLayout(
        topBar: TopBar.flow(onBack: context.pop),
        body: TopBarScrollView(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpace.md,
            children: state.done
                ? [
                    const SizedBox(height: AppSpace.xxl),
                    EmptyState(
                      icon: Icons.mail_outline,
                      title: 'Confira seu e-mail',
                      message:
                          'Mandamos um link para ${_email.text.trim()}. Se '
                          'não chegar em alguns minutos, olhe a caixa de spam.',
                    ),
                    const SizedBox(height: AppSpace.xl),
                    if (alert != null) InlineAlert(message: alert),
                    RangoButton(
                      label: 'Voltar para entrar',
                      expand: true,
                      onPressed: context.pop,
                    ),
                    RangoButton(
                      label: 'Reenviar e-mail',
                      style: RangoButtonStyle.ghost,
                      size: RangoButtonSize.medium,
                      expand: true,
                      onPressed: state.submitting ? null : submit,
                    ),
                  ]
                : [
                    const PageHeader(
                      title: 'Recuperar senha',
                      subtitle:
                          'Mandamos um link para você criar uma senha nova.',
                      size: PageHeaderSize.medium,
                    ),
                    if (alert != null) InlineAlert(message: alert),
                    RangoTextField(
                      label: 'E-mail',
                      hint: 'voce@email.com',
                      controller: _email,
                      error: state.emailError,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.email],
                      onChanged: (_) => viewModel.edited(),
                      onSubmitted: (_) => submit(),
                    ),
                    RangoButton(
                      label: 'Enviar link',
                      expand: true,
                      onPressed: state.submitting ? null : submit,
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
