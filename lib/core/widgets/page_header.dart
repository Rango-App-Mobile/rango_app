import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/theme_context.dart';

/// Size of the [PageHeader] title: `Display/Large` or `Display/Medium`.
enum PageHeaderSize { large, medium }

/// Figma "Page Header": title and optional subtitle at the top of a screen.
///
/// Large on choice and collection screens; medium on confirmation, error and
/// empty screens. The screen sets the horizontal margins, not this widget.
class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    this.subtitle,
    this.size = PageHeaderSize.large,
    super.key,
  });

  final String title;
  final String? subtitle;
  final PageHeaderSize size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final titleStyle = switch (size) {
      PageHeaderSize.large => styles.displayLarge,
      PageHeaderSize.medium => styles.displayMedium,
    };
    final subtitle = this.subtitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpace.xs,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: titleStyle.copyWith(color: colors.textPrimary),
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: styles.body.copyWith(color: colors.textSecondary),
          ),
      ],
    );
  }
}
