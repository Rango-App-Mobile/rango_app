import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/core/widgets/rango_button.dart';

/// Compact notice for an account whose e-mail is not confirmed yet.
class VerificationNotice extends StatelessWidget {
  const VerificationNotice({
    required this.email,
    required this.onResend,
    super.key,
  });

  final String email;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.photo),
        border: Border.all(
          color: colors.borderDefault,
          width: AppRadius.stroke,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.sm),
        child: Row(
          spacing: AppSpace.sm,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirme seu e-mail',
                    style: context.textStyles.bodyStrong.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    'Enviamos um link para $email.',
                    style: context.textStyles.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            RangoButton(
              label: 'Reenviar',
              style: RangoButtonStyle.ghost,
              size: RangoButtonSize.medium,
              onPressed: onResend,
            ),
          ],
        ),
      ),
    );
  }
}
