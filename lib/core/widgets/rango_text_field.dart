import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';

/// Figma `Text Field`: a 56-high input with the label always visible above it
/// and a helper or error message below.
class RangoTextField extends StatefulWidget {
  const RangoTextField({
    required this.label,
    required this.controller,
    this.hint,
    this.helper,
    this.error,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;

  /// Shown below the field while there is no [error].
  final String? helper;

  /// Figma `State=Error`: replaces [helper] and paints the border.
  final String? error;

  /// Hides the text and adds the eye button that reveals it.
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<RangoTextField> createState() => _RangoTextFieldState();
}

class _RangoTextFieldState extends State<RangoTextField> {
  late bool _obscured = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    final error = widget.error;
    final message = error ?? widget.helper;

    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.photo),
      borderSide: BorderSide(color: color, width: AppRadius.stroke),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpace.xs,
      children: [
        ExcludeSemantics(
          child: Text(
            widget.label,
            style: text.label.copyWith(color: colors.textPrimary),
          ),
        ),
        Semantics(
          label: widget.label,
          child: TextField(
            controller: widget.controller,
            obscureText: _obscured,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            autofillHints: widget.autofillHints,
            autocorrect: false,
            enableSuggestions: !widget.isPassword,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            cursorColor: colors.textPrimary,
            style: text.body.copyWith(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: text.body.copyWith(color: colors.textSecondary),
              filled: true,
              fillColor: colors.bgSurface,
              isDense: true,
              contentPadding: const EdgeInsets.all(AppSpace.md),
              enabledBorder: border(
                error == null ? colors.borderDefault : colors.textDanger,
              ),
              focusedBorder: border(
                error == null ? colors.borderStrong : colors.textDanger,
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      onPressed: () => setState(() => _obscured = !_obscured),
                      tooltip: _obscured ? 'Mostrar senha' : 'Esconder senha',
                      color: colors.iconDefault,
                      icon: Icon(
                        _obscured
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        if (message != null)
          Semantics(
            liveRegion: error != null,
            child: Text(
              message,
              style: text.caption.copyWith(
                color: error == null ? colors.textSecondary : colors.textDanger,
              ),
            ),
          ),
      ],
    );
  }
}
