import 'package:flutter/widgets.dart';

/// Thin convenience wrapper around [SafeArea] with named side toggles and
/// MediaQuery inset accessors.
///
/// Wrap a `Scaffold.body` (not the whole `Scaffold`) so the app bar keeps
/// managing its own insets, per the Flutter adaptive guidance.
class RrSafeArea extends StatelessWidget {
  const RrSafeArea({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.minimum = EdgeInsets.zero,
    this.maintainBottomViewPadding = false,
  });

  /// The protected child.
  final Widget child;

  /// Whether to avoid intrusions on each side.
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;

  /// Minimum padding to apply regardless of intrusions.
  final EdgeInsets minimum;

  /// Whether to maintain bottom view padding (e.g. when a keyboard is shown).
  final bool maintainBottomViewPadding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      minimum: minimum,
      maintainBottomViewPadding: maintainBottomViewPadding,
      child: child,
    );
  }
}

/// Contextual accessors for the common [MediaQuery] inset properties, using the
/// efficient specialised `*Of` lookups so widgets only rebuild on the relevant
/// change.
abstract final class RrInsets {
  /// Partially obscured areas (notches, status bar, rounded corners).
  static EdgeInsets paddingOf(BuildContext context) =>
      MediaQuery.paddingOf(context);

  /// Fully obscured areas (most commonly the on-screen keyboard).
  static EdgeInsets viewInsetsOf(BuildContext context) =>
      MediaQuery.viewInsetsOf(context);

  /// The complete obscured area regardless of overlap.
  static EdgeInsets viewPaddingOf(BuildContext context) =>
      MediaQuery.viewPaddingOf(context);

  /// Whether a keyboard (or similar bottom inset) is currently visible.
  static bool keyboardVisible(BuildContext context) =>
      MediaQuery.viewInsetsOf(context).bottom > 0;
}
