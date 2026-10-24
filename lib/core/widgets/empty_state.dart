import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/food_theme.dart';
import 'package:rango_app/core/widgets/page_header.dart';

/// Figma "Empty State": a circular mustard badge with an icon, plus title and
/// text through a medium [PageHeader].
///
/// Actions are not part of this component: the screen places its Buttons in
/// the footer.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    this.message,
    super.key,
  });

  static const double badgeSize = 96;
  static const double iconSize = 40;

  final IconData icon;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpace.md,
      children: [
        Container(
          width: badgeSize,
          height: badgeSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: FoodTheme.mustard.background,
          ),
          alignment: Alignment.center,
          child: ExcludeSemantics(
            child: Icon(
              icon,
              size: iconSize,
              color: FoodTheme.mustard.foreground,
            ),
          ),
        ),
        PageHeader(
          title: title,
          subtitle: message,
          size: PageHeaderSize.medium,
        ),
      ],
    );
  }
}
