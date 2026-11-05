import 'package:flutter/material.dart';

/// The scrolling body of a `TopBarLayout`: it fills the screen, so its content
/// starts right below the bar and passes behind it and the home indicator
/// instead of being cut in a straight line at their edges.
class TopBarScrollView extends StatelessWidget {
  const TopBarScrollView({
    required this.child,
    this.padding = EdgeInsets.zero,
    this.safeBottom = true,
    super.key,
  });

  final Widget child;

  /// Padding of the content, on top of the room the bar takes.
  final EdgeInsets padding;

  /// Whether the content ends above the home indicator. False on the tab
  /// screens, which leave their own room for the floating Tab Bar.
  final bool safeBottom;

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);

    return SingleChildScrollView(
      padding: padding.copyWith(
        top: padding.top + insets.top,
        bottom: padding.bottom + (safeBottom ? insets.bottom : 0),
      ),
      child: child,
    );
  }
}
