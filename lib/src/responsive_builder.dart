import 'package:flutter/widgets.dart';
import 'breakpoints.dart';

/// A builder widget that provides the current [RrBreakpoint] to its child.
///
/// Uses [MediaQuery.sizeOf] (window-level) for efficient rebuilds — only
/// triggers when the window size changes, not on other MediaQuery changes.
///
/// ```dart
/// RrResponsiveBuilder(
///   compact: (context) => MobileLayout(),
///   expanded: (context) => DesktopLayout(),
/// )
/// ```
class RrResponsiveBuilder extends StatelessWidget {
  const RrResponsiveBuilder({
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

  /// Generic builder that receives the current [RrBreakpoint].
  /// Used when you need custom logic beyond the per-breakpoint callbacks.
  final Widget Function(BuildContext context, RrBreakpoint breakpoint)? builder;

  @override
  Widget build(BuildContext context) {
    final breakpoint = RrBreakpoint.of(context);

    if (builder != null) {
      return builder!(context, breakpoint);
    }

    // Cascade fallback: larger breakpoints fall back to smaller ones.
    final resolved = switch (breakpoint) {
      RrBreakpoint.extraLarge =>
        extraLarge ?? large ?? expanded ?? medium ?? compact,
      RrBreakpoint.large => large ?? expanded ?? medium ?? compact,
      RrBreakpoint.expanded => expanded ?? medium ?? compact,
      RrBreakpoint.medium => medium ?? compact,
      RrBreakpoint.compact => compact,
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
/// RrConstraintResponsiveBuilder(
///   compact: (context, constraints) => CompactCard(),
///   expanded: (context, constraints) => WideCard(),
/// )
/// ```
class RrConstraintResponsiveBuilder extends StatelessWidget {
  const RrConstraintResponsiveBuilder({
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
        final breakpoint = RrBreakpoint.fromWidth(constraints.maxWidth);

        final resolved = switch (breakpoint) {
          RrBreakpoint.extraLarge ||
          RrBreakpoint.large =>
            large ?? expanded ?? medium ?? compact,
          RrBreakpoint.expanded => expanded ?? medium ?? compact,
          RrBreakpoint.medium => medium ?? compact,
          RrBreakpoint.compact => compact,
        };

        assert(resolved != null, 'No layout builder for $breakpoint');
        return resolved!(context, constraints);
      },
    );
  }
}
