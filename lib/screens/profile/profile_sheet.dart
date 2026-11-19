import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/core/widgets/list_row.dart';
import 'package:rango_app/core/widgets/rango_button.dart';
import 'package:rango_app/core/widgets/rango_icon_button.dart';
import 'package:rango_app/core/widgets/rango_loading_view.dart';
import 'package:rango_app/core/widgets/scrim.dart';
import 'package:rango_app/core/widgets/terms_acceptance.dart';
import 'package:rango_app/screens/profile/profile_state.dart';
import 'package:rango_app/screens/profile/profile_view_model.dart';
import 'package:rango_app/screens/profile/widgets/delete_account_dialog.dart';
import 'package:rango_app/screens/profile/widgets/profile_avatar.dart';
import 'package:rango_app/screens/profile/widgets/profile_stats_section.dart';
import 'package:rango_app/screens/profile/widgets/verification_notice.dart';

/// Opens the Profile Sheet over the whole app, Tab Bar included. It closes
/// through the X, by dragging it down or by tapping the veil.
Future<void> showProfileSheet(BuildContext context) {
  final colors = context.colors;
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: colors.bgCanvas,
    elevation: 0,
    barrierColor: colors.bgInverse.withValues(alpha: Scrim.modalOpacity),
    barrierLabel: 'Fechar',
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheet),
      ),
    ),
    clipBehavior: Clip.antiAlias,
    sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
        ? AnimationStyle.noAnimation
        : const AnimationStyle(
            duration: Duration(milliseconds: 350),
            curve: Curves.easeOut,
          ),
    builder: (_) => const ProfileSheet(),
  );
}

/// Figma `Profile Sheet`. A guest sees only the invitation to sign in: nothing
/// of theirs is saved, so there are no statistics or preferences (R1).
class ProfileSheet extends ConsumerWidget {
  const ProfileSheet({super.key});

  static const double _handleTop = 10;
  static const double _gap = 20;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The session already exists behind the startup gate, so this resolves at
    // once. Guest is also the honest answer if it ever fails: nothing is saved.
    final state =
        ref.watch(profileViewModelProvider).value ?? ProfileState.guest;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.lg,
          _handleTop,
          AppSpace.lg,
          AppSpace.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: _gap,
          children: [
            const _Handle(),
            _Header(state: state),
            if (state.needsVerification)
              VerificationNotice(
                email: state.subtitle ?? state.name,
                onResend: () => unawaited(_resend(context, ref)),
              ),
            if (!state.isGuest) const ProfileStatsSection(),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (state.isGuest)
                      const _GuestInvitation()
                    else ...[
                      ListRow(
                        icon: Icons.logout,
                        label: 'Sair da conta',
                        onTap: () => unawaited(
                          ref.read(profileViewModelProvider.notifier).signOut(),
                        ),
                      ),
                      ListRow(
                        icon: Icons.delete_outline,
                        label: 'Excluir conta',
                        destructive: true,
                        onTap: () => unawaited(
                          _delete(context, ref),
                        ),
                      ),
                    ],
                    // Always readable, with or without an account (stores
                    // require the privacy policy inside the app).
                    ListRow(
                      icon: Icons.description_outlined,
                      label: 'Termos e Privacidade',
                      onTap: () => unawaited(showTermsSheet(context)),
                    ),
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

Future<void> _delete(BuildContext context, WidgetRef ref) async {
  if (!await showDeleteAccountDialog(context)) return;
  if (!context.mounted) return;
  final sheet = Navigator.of(context);
  final root = Navigator.of(context, rootNavigator: true);
  // The splash covers the whole app, not the sheet, and nothing can be
  // tapped or dismissed until the account is gone.
  showGeneralDialog<void>(
    context: context,
    transitionDuration: Duration.zero,
    pageBuilder: (_, _, _) => const PopScope(
      canPop: false,
      child: RangoLoadingView(message: 'Excluindo sua conta…'),
    ),
  );
  final error = await ref
      .read(profileViewModelProvider.notifier)
      .deleteAccount();
  root.pop();
  if (error != null) {
    if (root.mounted) await showDeleteAccountError(root.context, error);
    return;
  }
  // No SnackBar: the splash and the guest mode already say it, and the
  // SnackBar would sit under the Tab Bar's blur.
  sheet.pop();
}

Future<void> _resend(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final sent = await ref
      .read(profileViewModelProvider.notifier)
      .resendVerification();
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        sent ? 'Link reenviado.' : 'Não foi possível reenviar. Tente de novo.',
      ),
    ),
  );
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: context.colors.borderDefault,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state});

  final ProfileState state;

  @override
  Widget build(BuildContext context) {
    final subtitle = state.subtitle;

    return Row(
      spacing: AppSpace.md,
      children: [
        ProfileAvatar(photoUrl: state.photoUrl),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpace.xxs,
            children: [
              Semantics(
                header: true,
                child: Text(
                  state.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.displayMedium.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.caption.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        RangoIconButton(
          icon: Icons.close,
          semanticLabel: 'Fechar perfil',
          style: RangoIconButtonStyle.outline,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _GuestInvitation extends StatelessWidget {
  const _GuestInvitation();

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppSpace.xs,
      children: [
        RangoButton(
          label: 'Entrar ou criar conta',
          icon: Icons.person_outline,
          style: RangoButtonStyle.secondary,
          expand: true,
          onPressed: () {
            final router = GoRouter.of(context);
            Navigator.of(context).pop();
            unawaited(router.push('/login'));
          },
        ),
        Text(
          'Sem conta, seus rangos não ficam salvos.',
          textAlign: TextAlign.center,
          style: context.textStyles.caption.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
