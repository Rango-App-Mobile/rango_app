import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/core/widgets/rango_text_field.dart';

/// Asks whether to delete the account. Null when the person cancels;
/// otherwise the password they typed (null for accounts without one).
Future<({String? password})?> showDeleteAccountDialog(
  BuildContext context, {
  required bool askPassword,
}) => showAdaptiveDialog<({String? password})>(
  context: context,
  builder: (_) => _DeleteAccountDialog(askPassword: askPassword),
);

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({required this.askPassword});

  final bool askPassword;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _confirm() => Navigator.of(context).pop((
    password: widget.askPassword ? _password.text : null,
  ));

  @override
  Widget build(BuildContext context) {
    final isCupertino = switch (Theme.of(context).platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => true,
      _ => false,
    };
    final danger = context.colors.textDanger;

    return AlertDialog.adaptive(
      title: const Text('Excluir sua conta?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpace.md,
        children: [
          const Text(
            'Seu histórico e seus dados serão apagados. '
            'Isso não pode ser desfeito.',
          ),
          if (widget.askPassword)
            RangoTextField(
              label: 'Senha',
              controller: _password,
              isPassword: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _confirm(),
            ),
        ],
      ),
      actions: [
        if (isCupertino) ...[
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: _confirm,
            child: const Text('Excluir'),
          ),
        ] else ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: _confirm,
            child: Text('Excluir', style: TextStyle(color: danger)),
          ),
        ],
      ],
    );
  }
}
