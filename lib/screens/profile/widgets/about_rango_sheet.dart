import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/core/widgets/rango_button.dart';
import 'package:rango_app/core/widgets/rango_icon_button.dart';
import 'package:rango_app/screens/profile/profile_view_model.dart';

Future<void> showAboutRangoSheet(BuildContext context) {
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
    builder: (_) => const AboutRangoSheet(),
  );
}

class AboutRangoSheet extends ConsumerWidget {
  const AboutRangoSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final version = ref.watch(appVersionProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, controller) => Padding(
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
                      'Sobre o Rango',
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
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpace.md,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        'Rango',
                        style: context.textStyles.displayMedium.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      'O Rango ajuda você a decidir o que comer e encontrar '
                      'restaurantes próximos.',
                      style: context.textStyles.body.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const Divider(),
                    switch (version) {
                      AsyncData(:final value) => Text(
                        'Versão $value',
                        style: context.textStyles.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      AsyncError() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: AppSpace.xs,
                        children: [
                          Text(
                            'Não foi possível carregar a versão.',
                            style: context.textStyles.caption.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          RangoButton(
                            label: 'Tentar novamente',
                            size: RangoButtonSize.medium,
                            style: RangoButtonStyle.ghost,
                            onPressed: () => ref.invalidate(appVersionProvider),
                          ),
                        ],
                      ),
                      _ => Semantics(
                        label: 'Carregando versão',
                        child: const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    },
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
