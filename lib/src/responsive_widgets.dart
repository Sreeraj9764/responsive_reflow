import 'package:flutter/widgets.dart';
import 'breakpoints.dart';

/// Selects a value of type [T] based on the current [RrBreakpoint].
///
/// Provide a [compact] base value and override at larger breakpoints as
/// needed; smaller-to-larger cascade fallback fills the gaps.
///
/// ```dart
/// final columns = RrResponsiveValue<int>(
///   compact: 1,
///   medium: 2,
///   expanded: 3,
/// ).resolve(context);
/// ```
@immutable
class RrResponsiveValue<T> {
  const RrResponsiveValue({
    required this.compact,
    this.medium,
    this.expanded,
    this.large,
    this.extraLarge,
  });

  /// Value for compact (required base).
  final T compact;

  /// Value for medium. Falls back to [compact].
  final T? medium;

  /// Value for expanded. Falls back to [medium] → [compact].
  final T? expanded;

  /// Value for large. Falls back to [expanded] → [medium] → [compact].
  final T? large;

  /// Value for extra large. Falls back to [large] → … → [compact].
  final T? extraLarge;

  /// Resolves the value for [breakpoint] using cascade fallback.
  T resolveFor(RrBreakpoint breakpoint) => switch (breakpoint) {
        RrBreakpoint.extraLarge =>
          extraLarge ?? large ?? expanded ?? medium ?? compact,
        RrBreakpoint.large => large ?? expanded ?? medium ?? compact,
        RrBreakpoint.expanded => expanded ?? medium ?? compact,
        RrBreakpoint.medium => medium ?? compact,
        RrBreakpoint.compact => compact,
      };

  /// Resolves the value for the current window breakpoint.
  T resolve(BuildContext context) => resolveFor(RrBreakpoint.of(context));
}

/// Shows or hides [child] based on the current breakpoint.
///
/// By default the widget is visible everywhere; restrict visibility with
/// [visibleFrom] and/or [hiddenFrom]. When hidden, [replacement] is shown
/// (defaults to [SizedBox.shrink]).
///
/// ```dart
/// // Only show on expanded and larger:
/// RrResponsiveVisibility(
///   visibleFrom: RrBreakpoint.expanded,
///   child: SecondaryPanel(),
/// )
/// ```
class RrResponsiveVisibility extends StatelessWidget {
  const RrResponsiveVisibility({
    super.key,
    required this.child,
    this.visibleFrom,
    this.hiddenFrom,
    this.replacement = const SizedBox.shrink(),
  });

  /// The widget shown when visible.
  final Widget child;

  /// Inclusive lower bound at which [child] becomes visible.
  final RrBreakpoint? visibleFrom;

  /// Inclusive lower bound at which [child] becomes hidden again.
  final RrBreakpoint? hiddenFrom;

  /// Widget shown while hidden.
  final Widget replacement;

  bool _isVisible(RrBreakpoint bp) {
    if (visibleFrom != null && bp < visibleFrom!) return false;
    if (hiddenFrom != null && bp >= hiddenFrom!) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return _isVisible(RrBreakpoint.of(context)) ? child : replacement;
  }
}

/// Lays children out as a [Row] on wide windows and a [Column] on narrow ones,
/// switching at [breakpoint].
///
/// Ideal for forms, key/value rows, and card content that should stack on
/// phones but sit side-by-side on tablets and desktops.
///
/// ```dart
/// RrResponsiveRowColumn(
///   rowFrom: RrBreakpoint.medium,
///   spacing: RrSpacing.lg,
///   children: [LabelField(), ValueField()],
/// )
/// ```
class RrResponsiveRowColumn extends StatelessWidget {
  const RrResponsiveRowColumn({
    super.key,
    required this.children,
    this.rowFrom = RrBreakpoint.medium,
    this.spacing = 0,
    this.rowMainAxisAlignment = MainAxisAlignment.start,
    this.rowCrossAxisAlignment = CrossAxisAlignment.center,
    this.columnMainAxisAlignment = MainAxisAlignment.start,
    this.columnCrossAxisAlignment = CrossAxisAlignment.start,
    this.rowMainAxisSize = MainAxisSize.max,
    this.columnMainAxisSize = MainAxisSize.min,
  });

  /// Children laid out in either axis.
  final List<Widget> children;

  /// Inclusive breakpoint at and above which a [Row] is used; below it a
  /// [Column] is used.
  final RrBreakpoint rowFrom;

  /// Gap inserted between children along the active axis.
  final double spacing;

  final MainAxisAlignment rowMainAxisAlignment;
  final CrossAxisAlignment rowCrossAxisAlignment;
  final MainAxisAlignment columnMainAxisAlignment;
  final CrossAxisAlignment columnCrossAxisAlignment;
  final MainAxisSize rowMainAxisSize;
  final MainAxisSize columnMainAxisSize;

  @override
  Widget build(BuildContext context) {
    final isRow = RrBreakpoint.of(context) >= rowFrom;

    if (isRow) {
      return Row(
        mainAxisAlignment: rowMainAxisAlignment,
        crossAxisAlignment: rowCrossAxisAlignment,
        mainAxisSize: rowMainAxisSize,
        spacing: spacing,
        children: children,
      );
    }

    return Column(
      mainAxisAlignment: columnMainAxisAlignment,
      crossAxisAlignment: columnCrossAxisAlignment,
      mainAxisSize: columnMainAxisSize,
      spacing: spacing,
      children: children,
    );
  }
}
