import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/core/widgets/rango_button.dart';
import 'package:rango_app/core/widgets/rango_icon_button.dart';
import 'package:rango_app/core/widgets/scrim.dart';
import 'package:rango_app/screens/profile/profile_state.dart';
import 'package:rango_app/screens/profile/profile_view_model.dart';
import 'package:rango_app/screens/profile/widgets/profile_avatar.dart';

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
            if (state.isGuest)
              const Flexible(
                child: SingleChildScrollView(child: _GuestInvitation()),
              ),
          ],
        ),
      ),
    );
  }
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
        const RangoButton(
          label: 'Entrar ou criar conta',
          icon: Icons.person_outline,
          style: RangoButtonStyle.secondary,
          expand: true,
          // Sign-in arrives with E1-S3 (Figma flow 06).
          onPressed: null,
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
