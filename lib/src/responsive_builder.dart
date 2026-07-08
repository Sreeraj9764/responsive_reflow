import 'package:flutter/widgets.dart';
import 'breakpoints.dart';

/// A builder widget that provides the current [ReflowBreakpoint] to its child.
///
/// Uses [MediaQuery.sizeOf] (window-level) for efficient rebuilds — only
/// triggers when the window size changes, not on other MediaQuery changes.
///
/// ```dart
/// ReflowResponsiveBuilder(
///   compact: (context) => MobileLayout(),
///   expanded: (context) => DesktopLayout(),
/// )
/// ```
class ReflowResponsiveBuilder extends StatelessWidget {
  const ReflowResponsiveBuilder({
    super.key,
    this.compact,
    this.medium,
    this.expanded,
    this.large,
    this.extraLarge,
    this.builder,
  }) : assert(
          builder != null ||
              compact != null ||
              medium != null ||
              expanded != null,
          'Provide at least one layout builder (compact, medium, expanded) or a generic builder.',
        );

  /// Layout for compact screens (<640px). Falls back to this if larger
  /// breakpoints are not provided.
  final WidgetBuilder? compact;

  /// Layout for medium screens (640–767px). Falls back to [compact].
  final WidgetBuilder? medium;

  /// Layout for expanded screens (768–1023px). Falls back to [medium] → [compact].
  final WidgetBuilder? expanded;

  /// Layout for large screens (1024–1279px). Falls back to [expanded] → [medium] → [compact].
  final WidgetBuilder? large;

  /// Layout for extra large screens (≥1280px). Falls back to [large] → [expanded] → [medium] → [compact].
  final WidgetBuilder? extraLarge;

  /// Generic builder that receives the current [ReflowBreakpoint].
  /// Used when you need custom logic beyond the per-breakpoint callbacks.
  final Widget Function(BuildContext context, ReflowBreakpoint breakpoint)?
      builder;

  @override
  Widget build(BuildContext context) {
    final breakpoint = ReflowBreakpoint.of(context);

    if (builder != null) {
      return builder!(context, breakpoint);
    }

    // Cascade fallback: larger breakpoints fall back to smaller ones.
    final resolved = switch (breakpoint) {
      ReflowBreakpoint.extraLarge =>
        extraLarge ?? large ?? expanded ?? medium ?? compact,
      ReflowBreakpoint.large => large ?? expanded ?? medium ?? compact,
      ReflowBreakpoint.expanded => expanded ?? medium ?? compact,
      ReflowBreakpoint.medium => medium ?? compact,
      ReflowBreakpoint.compact => compact,
    };

    assert(resolved != null, 'No layout builder available for $breakpoint');
    return resolved!(context);
  }
}

/// A [LayoutBuilder]-based responsive widget that branches on the
/// **parent constraints** rather than the window size.
///
/// Use this for reusable components that need to adapt to their
/// available space regardless of window size.
///
/// ```dart
/// ReflowConstraintResponsiveBuilder(
///   compact: (context, constraints) => CompactCard(),
///   expanded: (context, constraints) => WideCard(),
/// )
/// ```
class ReflowConstraintResponsiveBuilder extends StatelessWidget {
  const ReflowConstraintResponsiveBuilder({
    super.key,
    this.compact,
    this.medium,
    this.expanded,
    this.large,
  }) : assert(
          compact != null || medium != null || expanded != null,
          'Provide at least one layout builder.',
        );

  final Widget Function(BuildContext context, BoxConstraints constraints)?
      compact;
  final Widget Function(BuildContext context, BoxConstraints constraints)?
      medium;
  final Widget Function(BuildContext context, BoxConstraints constraints)?
      expanded;
  final Widget Function(BuildContext context, BoxConstraints constraints)?
      large;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = ReflowBreakpoint.fromWidth(constraints.maxWidth);

        final resolved = switch (breakpoint) {
          ReflowBreakpoint.extraLarge ||
          ReflowBreakpoint.large =>
            large ?? expanded ?? medium ?? compact,
          ReflowBreakpoint.expanded => expanded ?? medium ?? compact,
          ReflowBreakpoint.medium => medium ?? compact,
          ReflowBreakpoint.compact => compact,
        };

        assert(resolved != null, 'No layout builder for $breakpoint');
        return resolved!(context, constraints);
      },
    );
  }
}
