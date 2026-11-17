import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/theme_context.dart';

/// Asks whether to delete the account. True only when the person confirms.
Future<bool> showDeleteAccountDialog(BuildContext context) async =>
    await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => const _AdaptiveAlert(
        title: 'Excluir sua conta?',
        message:
            'Seu histórico e seus dados serão apagados. '
            'Isso não pode ser desfeito.',
        actions: [
          ('Cancelar', false, false),
          ('Excluir', true, true),
        ],
      ),
    ) ??
    false;

/// Why the account could not be deleted.
Future<void> showDeleteAccountError(BuildContext context, String message) =>
    showAdaptiveDialog<void>(
      context: context,
      builder: (context) => _AdaptiveAlert(
        title: 'Não deu para excluir',
        message: message,
        actions: const [('OK', null, false)],
      ),
    );

class _AdaptiveAlert extends StatelessWidget {
  const _AdaptiveAlert({
    required this.title,
    required this.message,
    required this.actions,
  });

  final String title;
  final String message;

  /// Label, the value it pops with, and whether it is destructive.
  final List<(String, bool?, bool)> actions;

  @override
  Widget build(BuildContext context) {
    final isCupertino = switch (Theme.of(context).platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => true,
      _ => false,
    };
    final danger = context.colors.textDanger;

    return AlertDialog.adaptive(
      title: Text(title),
      content: Text(message),
      actions: [
        for (final (label, value, destructive) in actions)
          if (isCupertino)
            CupertinoDialogAction(
              isDestructiveAction: destructive,
              onPressed: () => Navigator.of(context).pop(value),
              child: Text(label),
            )
          else
            TextButton(
              onPressed: () => Navigator.of(context).pop(value),
              child: Text(
                label,
                style: destructive ? TextStyle(color: danger) : null,
              ),
            ),
      ],
    );
  }
}
