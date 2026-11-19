import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/widgets/inline_alert.dart';
import 'package:rango_app/core/widgets/page_header.dart';
import 'package:rango_app/core/widgets/rango_button.dart';
import 'package:rango_app/core/widgets/rango_loading_view.dart';
import 'package:rango_app/core/widgets/rango_text_field.dart';
import 'package:rango_app/core/widgets/terms_acceptance.dart';
import 'package:rango_app/screens/accept_terms/accept_terms_view_model.dart';

/// "Quase lá": name and terms, right after a sign-in. Leaving it signs out.
class AcceptTermsScreen extends ConsumerStatefulWidget {
  const AcceptTermsScreen({super.key});

  @override
  ConsumerState<AcceptTermsScreen> createState() => _AcceptTermsScreenState();
}

class _AcceptTermsScreenState extends ConsumerState<AcceptTermsScreen> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(acceptTermsViewModelProvider);
    final viewModel = ref.read(acceptTermsViewModelProvider.notifier);
    final alert = state.alert;

    ref
      ..listen(acceptTermsViewModelProvider.select((s) => s.initialName), (
        _,
        name,
      ) {
        if (name != null && _name.text.isEmpty) _name.text = name;
      })
      ..listen(acceptTermsViewModelProvider.select((s) => s.done), (_, done) {
        // Login (and the sign-up pushed on it) may still be underneath:
        // close the whole auth flow, back to where it was opened.
        if (done) Navigator.of(context).popUntil((route) => route.isFirst);
      });

    final form = Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpace.md,
            children: [
              const PageHeader(
                title: 'Quase lá',
                subtitle:
                    'Confirme seu nome e aceite os termos para usar sua conta.',
                size: PageHeaderSize.medium,
              ),
              if (alert != null) InlineAlert(message: alert),
              RangoTextField(
                label: 'Nome',
                hint: 'Como podemos te chamar',
                controller: _name,
                error: state.nameError,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.name],
                onChanged: (_) => viewModel.edited(),
              ),
              TermsAcceptance(
                value: state.termsAccepted,
                error: state.termsError,
                onChanged: (accepted) =>
                    viewModel.termsAccepted(accepted: accepted),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpace.xxs,
                children: [
                  RangoButton(
                    label: 'Continuar',
                    expand: true,
                    onPressed: state.submitting
                        ? null
                        : () => unawaited(viewModel.submit(_name.text)),
                  ),
                  RangoButton(
                    label: 'Agora não',
                    style: RangoButtonStyle.ghost,
                    size: RangoButtonSize.medium,
                    expand: true,
                    onPressed: state.submitting
                        ? null
                        : () => unawaited(viewModel.decline()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // System back counts as "Agora não"; ignored while a request runs.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !state.submitting) unawaited(viewModel.decline());
      },
      child: Stack(
        children: [
          form,
          if (state.submitting)
            const Positioned.fill(
              child: RangoLoadingView(message: 'Salvando…'),
            ),
        ],
      ),
    );
  }
}
