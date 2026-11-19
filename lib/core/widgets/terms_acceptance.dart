import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/core/widgets/rango_icon_button.dart';

/// Switch plus "Li e aceito os Termos de Uso e a Política de Privacidade".
/// Tapping the label opens the text in a bottom sheet. [error] shows below.
class TermsAcceptance extends StatefulWidget {
  const TermsAcceptance({
    required this.value,
    required this.onChanged,
    this.error,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? error;

  @override
  State<TermsAcceptance> createState() => _TermsAcceptanceState();
}

class _TermsAcceptanceState extends State<TermsAcceptance> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.textStyles.body.copyWith(color: colors.textPrimary);
    final error = widget.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpace.xxs,
      children: [
        Row(
          spacing: AppSpace.sm,
          children: [
            Switch.adaptive(
              value: widget.value,
              onChanged: widget.onChanged,
              activeTrackColor: colors.textDanger,
            ),
            Expanded(
              // The whole label opens the text, not only the link words.
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => unawaited(showTermsSheet(context)),
                child: Text.rich(
                  TextSpan(
                    style: style,
                    children: [
                      const TextSpan(text: 'Li e aceito os '),
                      TextSpan(
                        text: 'Termos de Uso e a Política de Privacidade',
                        style: style.copyWith(
                          color: colors.textAccent,
                          decoration: TextDecoration.underline,
                          decorationColor: colors.textAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (error != null)
          Semantics(
            liveRegion: true,
            child: Text(
              error,
              style: context.textStyles.caption.copyWith(
                color: colors.textDanger,
              ),
            ),
          ),
      ],
    );
  }
}

/// Opens the Termos de Uso e Política de Privacidade over the app. Also
/// reachable from the Profile Sheet at any time.
Future<void> showTermsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.colors.bgCanvas,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheet),
      ),
    ),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, controller) => _TermsSheet(controller: controller),
    ),
  );
}

/// Presentation only: the text is a bundled asset, read when the sheet opens.
class _TermsSheet extends StatelessWidget {
  const _TermsSheet({required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.all(AppSpace.lg),
      child: Column(
        spacing: AppSpace.md,
        children: [
          Row(
            spacing: AppSpace.md,
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    'Termos de Uso e Política de Privacidade',
                    style: context.textStyles.heading.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ),
              RangoIconButton(
                icon: Icons.close,
                semanticLabel: 'Fechar',
                style: RangoIconButtonStyle.outline,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<String>(
              future: rootBundle.loadString('assets/legal/terms.txt'),
              builder: (context, snapshot) => SingleChildScrollView(
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpace.md,
                  children: [
                    for (final block in _blocks(
                      snapshot.data ??
                          (snapshot.hasError
                              ? 'Não foi possível abrir o texto.'
                              : ''),
                    ))
                      Text(
                        block,
                        style:
                            (_isSectionTitle(block)
                                    ? context.textStyles.bodyStrong
                                    : context.textStyles.body)
                                .copyWith(color: colors.textPrimary),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The text is paragraphs separated by a blank line.
List<String> _blocks(String text) => [
  for (final block in text.split('\n\n'))
    if (block.trim().isNotEmpty) block.trim(),
];

/// Section titles are numbered: "1. Quem somos".
bool _isSectionTitle(String block) =>
    !block.contains('\n') && RegExp(r'^\d+\. ').hasMatch(block);
